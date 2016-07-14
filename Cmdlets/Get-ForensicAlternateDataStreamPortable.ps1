function Get-ForensicAlternateDataStreamPortable
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
            [PowerForensics.Artifacts.AlternateDataStream]::GetInstances($VolumeName)
        }
        else
        {
            [PowerForensics.Artifacts.AlternateDataStream]::GetInstancesByPath($Path)
        }
    }
}