function Get-ForensicVolumeNamePortable
{
    Param(
        [Parameter(ParameterSetName = 'ByVolume')]
        [ValidatePattern('^(\\\\\.\\)?([A-Za-z]:)$')]
        [string]$VolumeName = '\\.\C:',
    
        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]$Path
    )

    begin{}

    process
    {
        if($PSCmdlet.ParameterSetName -eq 'ByVolume')
        {
            [PowerForensics.Ntfs.VolumeName]::Get($VolumeName)
        }
        else
        {
            [PowerForensics.Ntfs.VolumeName]::GetByPath($Path)
        }
    }
}