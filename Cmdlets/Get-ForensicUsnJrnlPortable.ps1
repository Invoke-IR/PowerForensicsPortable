function Get-ForensicUsnJrnlPortable
{
    Param
    (
        [Parameter()]
        [ValidatePattern('^(\\\\\.\\)?([A-Za-z]:)$')]
        [string]$VolumeName = '\\.\C:',

        [Parameter()]
        [long]$Usn
    )
    
    begin{}
    
    process
    {
        if($PSBoundParameters.ContainsKey('Usn'))
        {
            [PowerForensics.Ntfs.UsnJrnl]::Get($VolumeName, $Usn)
        }
        else
        {
            [PowerForensics.Ntfs.UsnJrnl]::GetInstances($VolumeName)
        }
    }
}