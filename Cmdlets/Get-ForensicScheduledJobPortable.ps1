function Get-ForensicScheduledJobPortable
{
    Param
    (
        [Parameter(ParameterSetName = 'ByVolume')]
        [ValidatePattern('^(\\\\\.\\)?([A-Za-z]:)$')]
        [string]$VolumeName = '\\.\C:',

        [Parameter(Mandatory, ParameterSetName = 'ByPath')]
        [Alias('FullName')]
        [string]$Path
    )
    
    begin{}
    
    process
    {
        if($PSCmdlet.ParameterSetName -eq 'ByVolume')
        {
            [PowerForensics.Artifacts.ScheduledJob]::GetInstances($VolumeName)
        }
        else
        {
            [PowerForensics.Artifacts.ScheduledJob]::Get($Path)
        }
    }
}