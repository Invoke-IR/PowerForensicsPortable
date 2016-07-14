#requires -Version 3
#Usage:
#Invoke-command -computername $server -scriptblock {FunctionName -param1 -param2}
# Author: Matt Graeber
# @mattifestation 
# www.exploit-monday.com

function Invoke-Command
{
    [CmdletBinding(DefaultParameterSetName='InProcess', HelpUri='http://go.microsoft.com/fwlink/?LinkID=135225', RemotingCapability='OwnedByCommand')]
    param(
        [Parameter(ParameterSetName='FilePathRunspace', Position=0)]
        [Parameter(ParameterSetName='Session', Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Runspaces.PSSession[]]
        ${Session},
 
        [Parameter(ParameterSetName='FilePathComputerName', Position=0)]
        [Parameter(ParameterSetName='ComputerName', Position=0)]
        [Alias('Cn')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${ComputerName},
 
        [Parameter(ParameterSetName='Uri', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='FilePathUri', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='ComputerName', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='FilePathComputerName', ValueFromPipelineByPropertyName=$true)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},
 
        [Parameter(ParameterSetName='ComputerName')]
        [Parameter(ParameterSetName='FilePathComputerName')]
        [ValidateRange(1, 65535)]
        [int]
        ${Port},
 
        [Parameter(ParameterSetName='ComputerName')]
        [Parameter(ParameterSetName='FilePathComputerName')]
        [switch]
        ${UseSSL},
 
        [Parameter(ParameterSetName='FilePathComputerName', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='ComputerName', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='FilePathUri', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Uri', ValueFromPipelineByPropertyName=$true)]
        [string]
        ${ConfigurationName},
 
        [Parameter(ParameterSetName='ComputerName', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='FilePathComputerName', ValueFromPipelineByPropertyName=$true)]
        [string]
        ${ApplicationName},
 
        [Parameter(ParameterSetName='FilePathComputerName')]
        [Parameter(ParameterSetName='Session')]
        [Parameter(ParameterSetName='ComputerName')]
        [Parameter(ParameterSetName='FilePathRunspace')]
        [Parameter(ParameterSetName='FilePathUri')]
        [Parameter(ParameterSetName='Uri')]
        [int]
        ${ThrottleLimit},
 
        [Parameter(ParameterSetName='Uri', Position=0)]
        [Parameter(ParameterSetName='FilePathUri', Position=0)]
        [Alias('URI','CU')]
        [ValidateNotNullOrEmpty()]
        [uri[]]
        ${ConnectionUri},
 
        [Parameter(ParameterSetName='FilePathComputerName')]
        [Parameter(ParameterSetName='Uri')]
        [Parameter(ParameterSetName='ComputerName')]
        [Parameter(ParameterSetName='FilePathRunspace')]
        [Parameter(ParameterSetName='FilePathUri')]
        [Parameter(ParameterSetName='Session')]
        [switch]
        ${AsJob},
 
        [Parameter(ParameterSetName='Uri')]
        [Parameter(ParameterSetName='FilePathComputerName')]
        [Parameter(ParameterSetName='FilePathUri')]
        [Parameter(ParameterSetName='ComputerName')]
        [Alias('Disconnected')]
        [switch]
        ${InDisconnectedSession},
 
        [Parameter(ParameterSetName='FilePathComputerName')]
        [Parameter(ParameterSetName='ComputerName')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${SessionName},
 
        [Parameter(ParameterSetName='FilePathComputerName')]
        [Parameter(ParameterSetName='Session')]
        [Parameter(ParameterSetName='FilePathRunspace')]
        [Parameter(ParameterSetName='ComputerName')]
        [Parameter(ParameterSetName='FilePathUri')]
        [Parameter(ParameterSetName='Uri')]
        [Alias('HCN')]
        [switch]
        ${HideComputerName},
 
        [Parameter(ParameterSetName='Session')]
        [Parameter(ParameterSetName='FilePathRunspace')]
        [Parameter(ParameterSetName='FilePathComputerName')]
        [Parameter(ParameterSetName='ComputerName')]
        [Parameter(ParameterSetName='FilePathUri')]
        [Parameter(ParameterSetName='Uri')]
        [string]
        ${JobName},
 
        [Parameter(ParameterSetName='Session', Mandatory=$true, Position=1)]
        [Parameter(ParameterSetName='Uri', Mandatory=$true, Position=1)]
        [Parameter(ParameterSetName='InProcess', Mandatory=$true, Position=0)]
        [Parameter(ParameterSetName='ComputerName', Mandatory=$true, Position=1)]
        [Alias('Command')]
        [ValidateNotNull()]
        [scriptblock]
        ${ScriptBlock},
 
        [Parameter(ParameterSetName='InProcess')]
        [switch]
        ${NoNewScope},
 
        [Parameter(ParameterSetName='FilePathUri', Mandatory=$true, Position=1)]
        [Parameter(ParameterSetName='FilePathComputerName', Mandatory=$true, Position=1)]
        [Parameter(ParameterSetName='FilePathRunspace', Mandatory=$true, Position=1)]
        [Alias('PSPath')]
        [ValidateNotNull()]
        [string]
        ${FilePath},
 
        [Parameter(ParameterSetName='Uri')]
        [Parameter(ParameterSetName='FilePathUri')]
        [switch]
        ${AllowRedirection},
 
        [Parameter(ParameterSetName='FilePathComputerName')]
        [Parameter(ParameterSetName='ComputerName')]
        [Parameter(ParameterSetName='Uri')]
        [Parameter(ParameterSetName='FilePathUri')]
        [System.Management.Automation.Remoting.PSSessionOption]
        ${SessionOption},
 
        [Parameter(ParameterSetName='Uri')]
        [Parameter(ParameterSetName='ComputerName')]
        [Parameter(ParameterSetName='FilePathComputerName')]
        [Parameter(ParameterSetName='FilePathUri')]
        [System.Management.Automation.Runspaces.AuthenticationMechanism]
        ${Authentication},
 
        [Parameter(ParameterSetName='FilePathComputerName')]
        [Parameter(ParameterSetName='ComputerName')]
        [Parameter(ParameterSetName='Uri')]
        [Parameter(ParameterSetName='FilePathUri')]
        [switch]
        ${EnableNetworkAccess},
 
        [Parameter(ValueFromPipeline=$true)]
        [psobject]
        ${InputObject},
 
        [Alias('Args')]
        [System.Object[]]
        ${ArgumentList},
 
        [Parameter(ParameterSetName='ComputerName')]
        [Parameter(ParameterSetName='Uri')]
        [string]
        ${CertificateThumbprint})
 
    begin
    {
        function Get-ScriptblockFunctions
        {
            Param (
                [Parameter(Mandatory=$True)]
                [ValidateNotNull()]
                [Scriptblock]
                $Scriptblock
            )
 
            # Return all user-defined function names contained within the supplied scriptblock
 
            $Scriptblock.Ast.FindAll({$args[0] -is [Management.Automation.Language.CommandAst]}, $True) |
                % { $_.CommandElements[0] } | Sort-Object Value -Unique | ForEach-Object { $_.Value } |
                    ? { ls Function:\$_ -ErrorAction Ignore }
        }
 
        function Get-FunctionDefinition
        {
            Param (
                [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
                [String[]]
                [ValidateScript({Get-Command $_})]
                $FunctionName
            )
 
            BEGIN
            {
                # We want to output a single string versus an array of strings
                $FunctionCollection = ''    
            }
 
            PROCESS
            {
                foreach ($Function in $FunctionName)
                {
                    $FunctionInfo = Get-Command $Function
 
                    $FunctionCollection += "function $($FunctionInfo.Name) {`n$($FunctionInfo.Definition)`n}`n"
                }
            }
 
            END
            {
                $FunctionCollection
            }
        }
 
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Invoke-Command', [System.Management.Automation.CommandTypes]::Cmdlet)
            if($PSBoundParameters['ScriptBlock'])
            {
                $FunctionDefinitions = Get-ScriptblockFunctions $ScriptBlock | Get-FunctionDefinition
                $PSBoundParameters['ScriptBlock'] = [ScriptBlock]::Create($FunctionDefinitions + $ScriptBlock.ToString())
            }
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }
 
    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }
 
    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
    <#
 
    .ForwardHelpTargetName Invoke-Command
    .ForwardHelpCategory Cmdlet
 
    #>
}