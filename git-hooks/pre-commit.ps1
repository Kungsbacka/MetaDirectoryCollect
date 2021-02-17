$nonEmpty = @()
Get-ChildItem  "$PSScriptRoot\..\..\*.dtsx" -Recurse | ForEach-Object {
    $package = $_.FullName
    if ($package -like '*\bin\Development\*' -or $package -like '*\obj\Development\*') {
        return # bin and obj folders are not included in the repository and can be excluded from this check
    }
    ([xml](gc $_.FullName)).Executable.PackageParameters.PackageParameter | ForEach-Object {
        if ($_.DataType -eq '8' -and $_.Property.'#text'.Length -gt 0) {
            $nonEmpty += [pscustomobject]@{
                Parameter = $_.ObjectName
                File = $package
            }
        }
    }   
}
Get-ChildItem  "$PSScriptRoot\..\..\*.params" -Recurse | ForEach-Object {
    $package = $_.FullName
    if ($package -like '*\bin\Development\*' -or $package -like '*\obj\Development\*') {
        return # bin and obj folders are not included in the repository and can be excluded from this check
    }
    ([xml](gc $_.FullName)).Parameters.Parameter | ForEach-Object {
        $dataType = $_.Properties.Property | Where-Object Name -EQ 'DataType' | Foreach-Object '#text'
        $value = $_.Properties.Property | Where-Object Name -EQ 'Value' | Foreach-Object '#text'
        if ($dataType -eq '18' -and $value.Length -gt 0) {
            $nonEmpty += [pscustomobject]@{
                Parameter = $_.Name
                File = $package
            }
        }
    }   
}
if ($nonEmpty.Count -gt 0) {
    Write-Host
    Write-Host 'Remove values for all project and package string parameters below before commiting:'
    $nonEmpty | Format-Table -AutoSize
    exit 1
}
