function Get-ForensicChildItemdPortable
{
    Param
    (
        [Parameter()]
        [Alias('FullName')]
        [string]$Path
    )
    
    begin{}
    
    process
    {
        if(!($PSBoundParameters.ContainsKey('Path')))
        {
            $Path = $PSCmdlet.SessionState.Path.CurrentFileSystemLocation.Path    
        }

        [PowerForensics.Ntfs.IndexEntry]::GetInstances($Path)
    }
}