function Get-ForensicAttrDefPortableTest
{
    [CmdletBinding()]
    Param()

    DynamicParam
    {
       Get-DynamicParamForMethod -method ([PowerForensics.Ntfs.AttrDef]::GetInstances) 
    }

    end
    {
        Invoke-MethodOverloadFromBoundParam -method ([PowerForensics.Ntfs.AttrDef]::GetInstances) -parameterSet $PSCmdlet.ParameterSetName -Parameters $PSBoundParameters
    }
}