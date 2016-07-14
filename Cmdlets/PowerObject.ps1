
#region PowerObject
function New-PowerObject {
	[cmdletBinding()]
	Param (
		[Parameter(Mandatory=$true,ValueFromPipeLine=$false,ValueFromPipelineByPropertyName=$true, position=0)]
		[type]
		$TypeName
	)
	DynamicParam {
		function New-ParamAttribute {
			Param(
				[Parameter(Mandatory=$true,ValueFromPipeLine=$false,ValueFromPipelineByPropertyName=$true, position=0)]
				[string]
				$ParameterSetName,
				[Parameter(Mandatory=$true,ValueFromPipeLine=$false,ValueFromPipelineByPropertyName=$true, position=1)]
				[int]
				$paramPosition,
				[Parameter(Mandatory=$false,ValueFromPipeLine=$false,ValueFromPipelineByPropertyName=$true, position=2)]
				[switch]
				$DontShow,
				[bool]
				[Parameter(Mandatory=$false,ValueFromPipeLine=$false,ValueFromPipelineByPropertyName=$true, position=3)]
				$mandatory = $true
			)
			$newAttribute = New-Object System.Management.Automation.ParameterAttribute
				$newAttribute.Mandatory = $mandatory
				if($DontShow) {$newAttribute.DontShow = $false}
				$newAttribute.Position = $paramPosition #This is new attribute, so always 1 (first parameter defining type - non dynamic)
				$newAttribute.ParameterSetName = $ParameterSetName
				
				return $newAttribute
		}

		$paramRuntimeCollection = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
		
		$type = ($typeName -as [Type])
		foreach($constructorDefinition in $type.GetConstructors().Where({($_.GetParameters().ParameterType.name -join '') -notmatch '\*'})) {#removing constructors using pointers
			$paramListForParamSet = @()
			$ParamsInCtor = $constructorDefinition.GetParameters()
			$constructorIndex = $ParamsInCtor.Name -join '.'
			foreach ($ParamDefinition in $ParamsInCtor) {
				$paramPosition = 1
				if ($paramRuntimeCollection.keys -notcontains $ParamDefinition.Name) {
					$newRuntimeDefinedParameter = New-Object System.Management.Automation.RuntimeDefinedParameter
					$newRuntimeDefinedParameter.Name = $ParamDefinition.Name
					$newRuntimeDefinedParameter.ParameterType = $ParamDefinition.ParameterType
					$newRuntimeDefinedParameter.Attributes.Add((New-ParamAttribute -ParameterSetName "ctor_$constructorIndex" -paramPosition $paramPosition))
					if ($ParamDefinition.HasDefaultValue) {
						$newRuntimeDefinedParameter.Value = $ParamDefinition.DefaultValue
					}
					$paramRuntimeCollection.Add($newRuntimeDefinedParameter.Name,$newRuntimeDefinedParameter)
				}
				else {
					"$($ParamDefinition.Name) already present in Attribute collection" |  Write-Debug
					"Adding Attribute definition for ParameterSet $($constructorIndex) for Parameter $($ParamDefinition.Name)" |  Write-Debug
					$paramRuntimeCollection[$ParamDefinition.Name].Attributes.Add((New-ParamAttribute -ParameterSetName "ctor_$constructorIndex" -paramPosition $paramPosition))
					}
					$paramListForParamSet+= $ParamDefinition.Name
				}
				$paramPosition++
		}
		
		$writeableProperties = $type.GetProperties().Where({$_.CanWrite -and $_.Name -notin $paramRuntimeCollection.keys})
		foreach($propertyArgument in $writeableProperties){
			$newRuntimeDefinedParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter
					$newRuntimeDefinedParameter.Name = $propertyArgument.Name
					$newRuntimeDefinedParameter.ParameterType = $propertyArgument.PropertyType
					$newRuntimeDefinedParameter.Attributes.Add((New-ParamAttribute -ParameterSetName '__AllParameterSets' -paramPosition -2147483648 -mandatory $false))
					$paramRuntimeCollection.Add($newRuntimeDefinedParameter.Name,$newRuntimeDefinedParameter)
		}
		
		return $paramRuntimeCollection
	}
	
	Process {
		$ConstructorParameterNames = @()
		$parameters = @()
		if($PSCmdlet.ParameterSetName -match '^ctor_') {
			$ConstructorParameterNames = $PSCmdlet.ParameterSetName -replace '^ctor_' -split '\.'
			$ConstructorParameterNames.ForEach({$parameters+=$PSBoundParameters[$_];$PSBoundParameters.Remove($_)|Out-Null})
		}
		$instanceOfObject = New-Object -TypeName $type.ToString() -ArgumentList $parameters

		$setProperties = $PSBoundParameters.Keys.Where({$_ -ne 'typeName' -and $_ -notin [System.Management.Automation.PSCmdlet]::CommonParameters -and $_ -notin [System.Management.Automation.PSCmdlet]::OptionalCommonParameters})
		foreach ($ParamPropKey in $setProperties) {
			$instanceOfObject.($ParamPropKey) = $PSBoundParameters.($ParamPropKey)
		}
		$instanceOfObject
	}
}
#endregion