function Test-Administrator  
{  
    [OutputType([bool])]
    param()
    process {
        [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent();
        return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
    }
}

if(-not (Test-Administrator))
{
    # TODO: define proper exit codes for the given errors 
    Write-Error "This script must be executed as Administrator.";
    exit 1;
}

$Path_Acrobat = "C:\Program Files\Adobe\Acrobat DC\Acrobat\"
$bOriginal_Acrobat = [System.Byte[]](0xD8, 0xE8, 0x2A, 0x04, 0x00, 0x00, 0x66, 0x85, 0xC0, 0x74, 0x1A, 0x66, 0x85, 0xDB, 0x0F, 0x85, 0xAD, 0x02, 0x00, 0x00, 0x8B, 0xD6, 0xB9, 0x2C)
$bSubstitute_Acrobat = [System.Byte[]](0xD8, 0xE8, 0x2A, 0x04, 0x00, 0x00, 0x66, 0x85, 0xC0, 0x74, 0x00, 0x66, 0x85, 0xDB, 0x0F, 0x85, 0xAD, 0x02, 0x00, 0x00, 0x8B, 0xD6, 0xB9, 0x2C)
$bOriginal_acrodistdll = [System.Byte[]](0x3E, 0x00, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0x48, 0x89, 0x5C, 0x24, 0x10, 0x48, 0x89, 0x74, 0x24, 0x18, 0x48, 0x89, 0x7C, 0x24, 0x20, 0x55)
$bSubstitute_acrodistdll = [System.Byte[]](0x3E, 0x00, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0x33, 0xC0, 0xC3, 0x24, 0x10, 0x48, 0x89, 0x74, 0x24, 0x18, 0x48, 0x89, 0x7C, 0x24, 0x20, 0x55)

cd $Path_Acrobat
echo "Patching Acrobat.dll"
Copy-Item -Path Acrobat.dll -Destination Acrobat.dll.bak
$bInput_Acrobat = Get-Content -Path Acrobat.dll -Encoding Byte -Raw
$bOutput_Acrobat = "$bInput_Acrobat" -Replace "\b$bOriginal_Acrobat\b", "$bSubstitute_Acrobat" -Split '\s+' -as [System.Byte[]]
Set-Content -Path Acrobat.dll -Encoding Byte -Value $bOutput_Acrobat
echo "Patching acrodistdll.dll"
Copy-Item -Path acrodistdll.dll -Destination acrodistdll.dll.bak
$bInput_acrodistdll = Get-Content -Path acrodistdll.dll -Encoding Byte -Raw
$bOutput_acrodistdll = "$bInput_acrodistdll" -Replace "\b$bOriginal_acrodistdll\b", "$bSubstitute_acrodistdll" -Split '\s+' -as [System.Byte[]]
Set-Content -Path acrodistdll.dll -Encoding Byte -Value $bOutput_acrodistdll
echo "Done"
pause
