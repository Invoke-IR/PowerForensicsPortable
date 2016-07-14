function Get-ForensicTimezonePortable
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
            [PowerForensics.Artifacts.Timezone]::Get($VolumeName)
        }
        else
        {
            [PowerForensics.Artifacts.Timezone]::GetByPath($Path)
        }
    }
}