if(-not ('Argument' -as [Type])) {
	if($PSVersionTable.PSVersion.Major -ge 5) {
		Enum Argument {}
	}
	else {
		
		$ArgEnum = @"

	public enum Argument 
	{

 }

"@
		
		Add-Type -TypeDefinition $ArgEnum
	}
}

#region Get-MethodOverloads returns list of customobject each one being a ParameterSet with its param definition (Name and type)
Function Get-MethodOverloads {
	[cmdletBinding()]
	Param (
		[parameter(ValueFromPipeline=$True)]
		[System.Management.Automation.PSMethod]
		$method
	)
	
	$ParameterSets = @()
	foreach ($signature in $method.OverloadDefinitions) {
		$parameterSet = [ordered]@{}
		($signature -match '(.*)\((.*)\)') | Out-Null
		$argumentsAsString = $Matches[2] -split ',\s*'
		foreach($arg in $argumentsAsString) {
			$argName = ($arg -replace '^Params ' -split ' ')[1]
			$argType = ($arg -replace '^Params ' -split ' ')[0]
			if($argName -ne $null) {
				$parameterSet.add($argName,($argType -as [Type]))
			}
			else {
				$parameterSet.add('No',([Argument])) #this is a dirty work around for now
			}
		}
		[PSCustomObject]@{ 'ParameterSetName'= ($parameterSet.Keys -join '.'); 'Params' = $parameterSet} | Add-Member -TypeName custom.method.parameterset -PassThru
	
	}
}

#endregion

#region Invoke Method based on it's definition and dynamically given parameters
function Invoke-MethodOverloadFromBoundParam {
	[cmdletBinding()]
	Param(
		[parameter(ValueFromPipeline=$false,Mandatory=$true)]
		[System.Management.Automation.PSMethod]
		$method,
		[parameter(ValueFromPipeline=$false,Mandatory=$true)]
		$Parameters,
		[parameter(ValueFromPipeline=$false,Mandatory=$true)]
		[string]
		$parameterSet
	)
	Process {
		$OverloadMethods = Get-MethodOverloads -method $method
		$AgumentList = @()
		$parameterNames = $parameterSet -split '\.'
		foreach($paramName in $parameterNames) {
			$ArgumentList += $Parameters[$paramName]
		}
		if($ArgumentList.count -ge 1) {
			return $method.Invoke($ArgumentList)
		}
		else {
			return $method.Invoke()
		}
	}
}
#endregion

#region Get-DynamicParameterForMethod to help construct function signature based on method
function Get-DynamicParamForMethod {
	[cmdletBinding()]
	Param(
		[parameter(ValueFromPipeline=$True,Mandatory=$true)]
		[System.Management.Automation.PSMethod]
		$method
	)
	
	Process {
		$paramRuntimeCollection = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
		$OverloadMethods = Get-MethodOverloads -method $method
		foreach($Overload in $OverloadMethods) {
			$parameterSetName = $Overload.ParameterSetName
			foreach($parameter in $Overload.params.keys) {
				if(-not $paramRuntimeCollection.ContainsKey($parameter)) {
					$attribute = (New-PowerObject -TypeName System.Management.Automation.ParameterAttribute -ParameterSetName $parameterSetName -Mandatory $true -Position 0)
					if($parameter -eq 'no' -and $Overload.Params[$Parameter].ToString() -eq 'Argument'){ #dirty workaround for signature Method() (as in no arguments)
						$attribute.Mandatory = $false
						$attribute.DontShow = $true
						$attribute.ParameterSetName = 'NoArguments'
					}
					$newParam = New-PowerObject -TypeName System.Management.Automation.RuntimeDefinedParameter -name $parameter -parameterType ($Overload.Params[$parameter] -as [Type])  -attributes @($attribute)
					$paramRuntimeCollection.Add($parameter,$newParam)
				}
				else {
					$attribute = (New-PowerObject -TypeName System.Management.Automation.ParameterAttribute -ParameterSetName $parameterSetName -Mandatory $true)
					#TODO: edit the position of the parameter for this parameterset
					$paramRuntimeCollection[$parameter].Attributes.Add($attribute)
				}
			}
		}
		return $paramRuntimeCollection
	
	}
}
#endregion
