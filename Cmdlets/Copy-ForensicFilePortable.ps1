function Copy-ForensicFilePortable
{
    Param
    (
        [Parameter(Mandatory, ParameterSetName = 'ByPath')]
        [string]$Path,
        
        [Parameter(ParameterSetName = 'ByVolume')]
        [ValidatePattern('^(\\\\\.\\)?([A-Za-z]:)$')]
        [string]$VolumeName = '\\.\C:',
        
        [Parameter(Mandatory, ParameterSetName = 'ByVolume')]
        [long]$Index,
        
        [Parameter(Mandatory)]
        [string]$Destination
    )

    begin{}

    process
    {
        if($PSCmdlet.ParameterSetName -eq 'ByPath')
        {
            $record = [PowerForensics.Ntfs.FileRecord]::Get($Path, $True)
        }
        else
        {
            $record = [PowerForensics.Ntfs.FileRecord]::Get($VolumeName, $Index, $True)
        }

        $record.CopyFile($Destination)
    }
}