function Get-ForensicFileRecordPortable
{
    Param
    (
        [Parameter(ParameterSetName = 'ByVolume')]
        [ValidatePattern('^(\\\\\.\\)?([A-Za-z]:)$')]
        [string]$VolumeName = '\\.\C:',

        [Parameter(ParameterSetName = 'ByVolume')]
        [long]$Index,

        [Parameter(Mandatory, ParameterSetName = 'ByPath')]
        [string]$Path
    )
    
    begin{}
    
    process
    {
        if($PSCmdlet.ParameterSetName -eq 'ByVolume')
        {
            if($PSBoundParameters.ContainsKey('Index'))
            {
                [PowerForensics.Ntfs.FileRecord]::Get($VolumeName, $Index, $False)
            }
            else
            {
                [PowerForensics.Ntfs.FileRecord]::GetInstances($VolumeName)
            }
        }
        else
        {
            [PowerForensics.Ntfs.FileRecord]::Get($Path, $False)
        }
    }
}