function Get-ForensicRunKeyPortable
{
    Param
    (
        [Parameter(ParameterSetName = 'ByVolume')]
        [ValidatePattern('^(\\\\\.\\)?([A-Za-z]:)$')]
        [string]$VolumeName = '\\.\C:',

        [Parameter(Mandatory, ParameterSetName = 'ByPath')]
        [string]$Path
    )
    
    begin{}
    
    process
    {
        if($PSCmdlet.ParameterSetName -eq 'ByVolume')
        {
            [PowerForensics.Artifacts.Persistence.RunKey]::GetInstances($VolumeName)
        }
        else
        {
            [PowerForensics.Artifacts.Persistence.RunKey]::Get($Path)
        }
    }
}