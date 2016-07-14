function Get-ForensicFileRecordIndexPortable
{
    Param
    (
        [Parameter(Mandatory)]
        [Alias('FullName')]
        [string]$Path
    )
    
    begin{}
    
    process
    {
        [PowerForensics.Ntfs.IndexEntry]::Get($Path).RecordNumber
    }
}