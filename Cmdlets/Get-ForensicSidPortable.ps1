function Get-ForensicSidPortable
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
            [PowerForensics.Artifacts.Sid]::Get($VolumeName)
        }
        else
        {
            [PowerForensics.Artifacts.Sid]::GetByPath($Path)
        }
    }
}