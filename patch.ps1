function Test-Administrator  
{  
    [OutputType([bool])]
    param()
    process {
        [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent();
        return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
    }
}

if (-not (Test-Administrator))
{
    # TODO: define proper exit codes for the given errors 
    Write-Error "This script must be executed as Administrator.";
    exit 1;
}

$Path_Acrobat = "C:\Program Files\Adobe\Acrobat DC\Acrobat\"
$bOriginal_Acrobat = [System.Byte[]](0x00, 0x00, 0x66, 0x85, 0xC0, 0x74, 0x1A, 0x66, 0x85, 0xDB, 0x0F, 0x85)
$bSubstitute_Acrobat = [System.Byte[]](0x00, 0x00, 0x66, 0x85, 0xC0, 0x74, 0x00, 0x66, 0x85, 0xDB, 0x0F, 0x85)
$bOriginal_acrodistdll = [System.Byte[]](0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0x48, 0x89, 0x5C, 0x24, 0x10, 0x48, 0x89, 0x74, 0x24, 0x18, 0x48, 0x89, 0x7C, 0x24, 0x20, 0x55, 0x41, 0x54, 0x41, 0x55, 0x41, 0x56, 0x41, 0x57, 0x48, 0x8D, 0xAC, 0x24, 0x00)
$bSubstitute_acrodistdll = [System.Byte[]](0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0x33, 0xC0, 0xC3, 0x24, 0x10, 0x48, 0x89, 0x74, 0x24, 0x18, 0x48, 0x89, 0x7C, 0x24, 0x20, 0x55, 0x41, 0x54, 0x41, 0x55, 0x41, 0x56, 0x41, 0x57, 0x48, 0x8D, 0xAC, 0x24, 0x00)


cd $Path_Acrobat
echo "Patching Acrobat.dll"
Copy-Item -Path Acrobat.dll -Destination Acrobat.dll.bak
$bInput_Acrobat = Get-Content -Path Acrobat.dll -Encoding Byte -Raw
$Offset_Acrobat = $bInput_Acrobat.Length - $bOriginal_Acrobat.Length
$sum_find_Acrobat = 0
for ($j = 0; $j -lt $bOriginal_Acrobat.Length; $j++)
{
    $sum_find_Acrobat = $sum_find_Acrobat + $bOriginal_Acrobat[$j]
}
$sum_input_Acrobat = 0
for ($j = 0; $j -lt $bOriginal_Acrobat.Length; $j++)
{
    $sum_input_Acrobat = $sum_input_Acrobat + $bInput_Acrobat[$j]
}
$i = 0
for(; $i -lt $Offset_Acrobat; $i++)
{
    if ($sum_input_Acrobat -eq $sum_find_Acrobat)
    {
        $j = 0
        for (; $j -lt $bOriginal_Acrobat.Length; $j++)
        {
            if ($bInput_Acrobat[$i+$j] -ne $bOriginal_Acrobat[$j])
            {
                break
            }
        }
        if ($j -eq $bOriginal_Acrobat.Length)
        {
            break
        }
    }
    $sum_input_Acrobat = $sum_input_Acrobat - $bInput_Acrobat[$i] + $bInput_Acrobat[$i+$bOriginal_Acrobat.Length]
}
if ($i -lt $Offset_Acrobat)
{
    for ($j = 0; $j -lt $bOriginal_Acrobat.Length; $j++)
    {
        $bInput_Acrobat[$i+$j] = $bSubstitute_Acrobat[$j]
    }
    Set-Content -Path Acrobat.dll -Encoding Byte -Value $bInput_Acrobat
    echo "Done"
}
else
{
    echo "Fail"
}

echo "Patching acrodistdll.dll"
Copy-Item -Path acrodistdll.dll -Destination acrodistdll.dll.bak
$bInput_acrodistdll = Get-Content -Path acrodistdll.dll -Encoding Byte -Raw
$Offset_acrodistdll = $bInput_acrodistdll.Length - $bOriginal_acrodistdll.Length
$sum_find_acrodistdll = 0
for ($j = 0; $j -lt $bOriginal_acrodistdll.Length; $j++)
{
    $sum_find_acrodistdll = $sum_find_acrodistdll + $bOriginal_acrodistdll[$j]
}
$sum_input_acrodistdll = 0
for ($j = 0; $j -lt $bOriginal_acrodistdll.Length; $j++)
{
    $sum_input_acrodistdll = $sum_input_acrodistdll + $bInput_acrodistdll[$j]
}
$i = 0
for(; $i -lt $Offset_acrodistdll; $i++)
{
    if ($sum_input_acrodistdll -eq $sum_find_acrodistdll)
    {
        $j = 0
        for (; $j -lt $bOriginal_acrodistdll.Length; $j++)
        {
            if ($bInput_acrodistdll[$i+$j] -ne $bOriginal_acrodistdll[$j])
            {
                break
            }
        }
        if ($j -eq $bOriginal_acrodistdll.Length)
        {
            break
        }
    }
    $sum_input_acrodistdll = $sum_input_acrodistdll - $bInput_acrodistdll[$i] + $bInput_acrodistdll[$i+$bOriginal_acrodistdll.Length]
}
if ($i -lt $Offset_acrodistdll)
{
    for ($j = 0; $j -lt $bOriginal_acrodistdll.Length; $j++)
    {
        $bInput_acrodistdll[$i+$j] = $bSubstitute_acrodistdll[$j]
    }
    Set-Content -Path acrodistdll.dll -Encoding Byte -Value $bInput_acrodistdll
    echo "Done"
}
else
{
    echo "Fail"
}

pause
exit 0
