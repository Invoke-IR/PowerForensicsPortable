function Get-ForensicMftSlackPortable
{
    Param
    (
        [Parameter(ParameterSetName = 'ByVolume')]
        [ValidatePattern('^(\\\\\.\\)?([A-Za-z]:)$')]
        [string]$VolumeName = '\\.\C:',
        
        [Parameter(Mandatory, ParameterSetName = 'ByVolume')]
        [long]$Index,

        [Parameter(Mandatory, ParameterSetName = 'ByPath')]
        [string]$Path
    )

    begin{}

    process
    {
        if($PSCmdlet.ParameterSetName -eq 'ByVolume')
        {
            [PowerForensics.Ntfs.FileRecord]::Get($VolumeName, $Index, $true).GetMftSlack()
        }
        else
        {
            [PowerForensics.Ntfs.FileRecord]::Get($Path, $true).GetMftSlack()
        }
    }
}