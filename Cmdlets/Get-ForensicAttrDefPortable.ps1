function Get-ForensicAttrDefPortable
{
    Param(
        [Parameter(ParameterSetName = 'ByVolume')]
        [ValidatePattern('^(\\\\\.\\)?([A-Za-z]:)$')]
        [string]$VolumeName = '\\.\C:',

        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [string]$Path
    )

    begin{}

    process
    {
        if($PSCmdlet.ParameterSetName -eq 'ByVolume')
        {
            [PowerForensics.Ntfs.AttrDef]::GetInstances($VolumeName)
        }
        else
        {
            [PowerForensics.Ntfs.AttrDef]::GetInstancesByPath($Path)
        }
    }
}