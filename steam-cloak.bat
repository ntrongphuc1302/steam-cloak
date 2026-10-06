@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Steam Cloak

:: ============================================================
:: CHECK ADMIN
:: ============================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo   Requesting Administrator privileges...
    echo ============================================================
    echo.

    powershell -NoProfile -Command ^
        "Start-Process -FilePath '%~f0' -Verb RunAs"

    exit /b
)

:: ============================================================
:: MAIN MENU
:: ============================================================

:MENU
cls

echo ============================================================
echo.
echo         STEAM DNS UNLOCK TOOL
echo.
echo ============================================================
echo.
echo  If your goal is to access Steam, recommended order:
echo.
echo     [1] Cloudflare DNS      <-- TRY FIRST
echo       IPv4 + IPv6
echo       DoH disabled
echo.
echo     [2] Google DNS          <-- TRY FIRST
echo       IPv4 + IPv6
echo       DoH disabled
echo.
echo     [3] Cloudflare + DoH    <-- TRY AFTER THE FIRST TWO
echo.
echo     [4] Google + DoH        <-- TRY IF OPTION 3 DOES NOT WORK
echo.
echo  If none of the 4 options unblock Steam:
echo     Your ISP may be blocking beyond DNS.
echo.
echo ============================================================
echo.
echo   [1] Cloudflare DNS
echo       IPv4 + IPv6
echo       DoH disabled
echo.
echo   [2] Google DNS
echo       IPv4 + IPv6
echo       DoH disabled
echo.
echo   [3] Cloudflare DNS + DoH
echo       Recommended for Steam
echo.
echo   [4] Google DNS + DoH
echo       Try if Cloudflare does not work
echo.
echo   [5] Automatic / DHCP
echo       Restore default DNS
echo.
echo   [6] Show current DNS
echo.
echo   [7] Test DNS + Steam
echo.
echo   [0] Exit
echo.
echo ============================================================
echo.

choice /C 12345670 /N /M "Select [1/2/3/4/5/6/7/0]: "

if errorlevel 8 goto EXIT
if errorlevel 7 goto TEST_ALL
if errorlevel 6 goto SHOW_DNS
if errorlevel 5 goto AUTO_DNS
if errorlevel 4 goto GOOGLE_DOH
if errorlevel 3 goto CLOUDFLARE_DOH
if errorlevel 2 goto GOOGLE_DNS
if errorlevel 1 goto CLOUDFLARE_DNS

goto MENU


:: ============================================================
:: CLOUDFLARE NORMAL
:: ============================================================

:CLOUDFLARE_DNS
cls

set "DNS4_1=1.1.1.1"
set "DNS4_2=1.0.0.1"

set "DNS6_1=2606:4700:4700::1111"
set "DNS6_2=2606:4700:4700::1001"

echo ============================================================
echo   CLOUDFLARE DNS - IPv4 + IPv6
echo ============================================================
echo.

call :SET_BASIC_DNS
call :FLUSH_DNS

echo.
echo [OK] Cloudflare DNS has been applied.
echo.
echo Notes:
echo   This mode does NOT enable DNS over HTTPS.
echo   If Steam is still blocked, try Option [3].
echo.

pause
goto MENU


:: ============================================================
:: GOOGLE NORMAL
:: ============================================================

:GOOGLE_DNS
cls

set "DNS4_1=8.8.8.8"
set "DNS4_2=8.8.4.4"

set "DNS6_1=2001:4860:4860::8888"
set "DNS6_2=2001:4860:4860::8844"

echo ============================================================
echo   GOOGLE DNS - IPv4 + IPv6
echo ============================================================
echo.

call :SET_BASIC_DNS
call :FLUSH_DNS

echo.
echo [OK] Google DNS has been applied.
echo.
echo Notes:
echo   This mode does NOT enable DNS over HTTPS.
echo   If Steam is still blocked, try Option [4].
echo.

pause
goto MENU


:: ============================================================
:: CLOUDFLARE + DOH
:: ============================================================

:CLOUDFLARE_DOH
cls

echo ============================================================
echo   CLOUDFLARE DNS + DNS OVER HTTPS
echo ============================================================
echo.
echo This is the recommended choice if you want to try opening Steam.
echo.

set "DNS4_1=1.1.1.1"
set "DNS4_2=1.0.0.1"

set "DNS6_1=2606:4700:4700::1111"
set "DNS6_2=2606:4700:4700::1001"

call :SET_BASIC_DNS

echo.
echo [*] Enabling DNS over HTTPS for Cloudflare...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference='SilentlyContinue';" ^
    "Set-DnsClientDohServerAddress -ServerAddress '1.1.1.1' -DohTemplate 'https://cloudflare-dns.com/dns-query' -AllowFallbackToUdp $false -AutoUpgrade $true;" ^
    "Set-DnsClientDohServerAddress -ServerAddress '1.0.0.1' -DohTemplate 'https://cloudflare-dns.com/dns-query' -AllowFallbackToUdp $false -AutoUpgrade $true;" ^
    "Set-DnsClientDohServerAddress -ServerAddress '2606:4700:4700::1111' -DohTemplate 'https://cloudflare-dns.com/dns-query' -AllowFallbackToUdp $false -AutoUpgrade $true;" ^
    "Set-DnsClientDohServerAddress -ServerAddress '2606:4700:4700::1001' -DohTemplate 'https://cloudflare-dns.com/dns-query' -AllowFallbackToUdp $false -AutoUpgrade $true;"

call :FLUSH_DNS

echo.
echo ============================================================
echo   [OK] CLOUDFLARE + DoH HAS BEEN INSTALLED
echo ============================================================
echo.
echo Next steps:
echo   1. Fully close Steam
echo   2. Reopen Steam
echo   3. Try Store and Community
echo.
echo If it still does not work:
echo   Try Option [4] Google + DoH.
echo.

pause
goto MENU


:: ============================================================
:: GOOGLE + DOH
:: ============================================================

:GOOGLE_DOH
cls

echo ============================================================
echo   GOOGLE DNS + DNS OVER HTTPS
echo ============================================================
echo.
echo Try this mode if Cloudflare + DoH does not work.
echo.

set "DNS4_1=8.8.8.8"
set "DNS4_2=8.8.4.4"

set "DNS6_1=2001:4860:4860::8888"
set "DNS6_2=2001:4860:4860::8844"

call :SET_BASIC_DNS

echo.
echo [*] Enabling DNS over HTTPS for Google...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference='SilentlyContinue';" ^
    "Set-DnsClientDohServerAddress -ServerAddress '8.8.8.8' -DohTemplate 'https://dns.google/dns-query' -AllowFallbackToUdp $false -AutoUpgrade $true;" ^
    "Set-DnsClientDohServerAddress -ServerAddress '8.8.4.4' -DohTemplate 'https://dns.google/dns-query' -AllowFallbackToUdp $false -AutoUpgrade $true;" ^
    "Set-DnsClientDohServerAddress -ServerAddress '2001:4860:4860::8888' -DohTemplate 'https://dns.google/dns-query' -AllowFallbackToUdp $false -AutoUpgrade $true;" ^
    "Set-DnsClientDohServerAddress -ServerAddress '2001:4860:4860::8844' -DohTemplate 'https://dns.google/dns-query' -AllowFallbackToUdp $false -AutoUpgrade $true;"

call :FLUSH_DNS

echo.
echo ============================================================
echo   [OK] GOOGLE + DoH HAS BEEN INSTALLED
echo ============================================================
echo.
echo Fully close Steam and reopen it.
echo.

pause
goto MENU


:: ============================================================
:: AUTO DNS
:: ============================================================

:AUTO_DNS
cls

echo ============================================================
echo   RESTORE DNS TO AUTOMATIC / DHCP
echo ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.HardwareInterface -eq $true };" ^
    "if (-not $adapters) {" ^
    " Write-Host '[ERROR] No active adapter found.' -ForegroundColor Red;" ^
    " exit 1" ^
    "};" ^
    "foreach ($adapter in $adapters) {" ^
    " Write-Host ('[+] ' + $adapter.Name) -ForegroundColor Cyan;" ^
    " try {" ^
    "  Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ResetServerAddresses -ErrorAction Stop;" ^
    "  Write-Host '    [OK] DNS -> Automatic / DHCP' -ForegroundColor Green" ^
    " } catch {" ^
    "  Write-Host ('    [ERROR] ' + $_.Exception.Message) -ForegroundColor Red" ^
    " }" ^
    "}"

call :FLUSH_DNS

echo.
echo [OK] DNS has been restored to Automatic / DHCP.
echo.

pause
goto MENU


:: ============================================================
:: SHOW DNS
:: ============================================================

:SHOW_DNS
cls

echo ============================================================
echo   CURRENT DNS
echo ============================================================
echo.

call :DISPLAY_DNS

echo.
pause
goto MENU


:: ============================================================
:: TEST DNS + STEAM
:: ============================================================

:TEST_ALL
cls

echo ============================================================
echo   TEST DNS + STEAM
echo ============================================================
echo.

echo [1/5] Test DNS resolution...
echo.

nslookup store.steampowered.com
echo.

echo ------------------------------------------------------------
echo [2/5] Test Steam Community...
echo.

nslookup steamcommunity.com
echo.

echo ------------------------------------------------------------
echo [3/5] Test TCP HTTPS Steam Store...
echo.

powershell -NoProfile -Command ^
    "$r = Test-NetConnection store.steampowered.com -Port 443 -WarningAction SilentlyContinue;" ^
    "Write-Host ('Remote IP   : ' + $r.RemoteAddress);" ^
    "Write-Host ('TCP 443 OK  : ' + $r.TcpTestSucceeded)"

echo.

echo ------------------------------------------------------------
echo [4/5] Test TCP HTTPS Steam Community...
echo.

powershell -NoProfile -Command ^
    "$r = Test-NetConnection steamcommunity.com -Port 443 -WarningAction SilentlyContinue;" ^
    "Write-Host ('Remote IP   : ' + $r.RemoteAddress);" ^
    "Write-Host ('TCP 443 OK  : ' + $r.TcpTestSucceeded)"

echo.

echo ------------------------------------------------------------
echo [5/5] Test HTTPS request...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "try {" ^
    " $r = Invoke-WebRequest -Uri 'https://store.steampowered.com' -Method Head -UseBasicParsing -TimeoutSec 10;" ^
    " Write-Host ('Steam Store HTTP: ' + $r.StatusCode) -ForegroundColor Green" ^
    "} catch {" ^
    " Write-Host ('Steam Store error: ' + $_.Exception.Message) -ForegroundColor Red" ^
    "}"

echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "try {" ^
    " $r = Invoke-WebRequest -Uri 'https://steamcommunity.com' -Method Head -UseBasicParsing -TimeoutSec 10;" ^
    " Write-Host ('Steam Community HTTP: ' + $r.StatusCode) -ForegroundColor Green" ^
    "} catch {" ^
    " Write-Host ('Steam Community error: ' + $_.Exception.Message) -ForegroundColor Red" ^
    "}"

echo.
echo ============================================================
echo   HOW TO READ THE RESULTS
echo ============================================================
echo.
echo If nslookup succeeds AND TCP 443 = True:
echo   DNS and basic connectivity are working.
echo.
echo If nslookup succeeds but TCP 443 = False:
echo   Your ISP may be blocking at a layer beyond DNS.
echo.
echo If both Cloudflare + DoH and Google + DoH fail:
echo   Plain DNS switching will not be enough to open Steam.
echo.

pause
goto MENU


:: ============================================================
:: SET BASIC DNS
:: ============================================================

:SET_BASIC_DNS

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$dns4 = @('%DNS4_1%','%DNS4_2%');" ^
    "$dns6 = @('%DNS6_1%','%DNS6_2%');" ^
    "$adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.HardwareInterface -eq $true };" ^
    "if (-not $adapters) {" ^
    " Write-Host '[ERROR] No active physical adapter found.' -ForegroundColor Red;" ^
    " exit 1" ^
    "};" ^
    "foreach ($adapter in $adapters) {" ^
    " Write-Host ('[+] Adapter: ' + $adapter.Name) -ForegroundColor Cyan;" ^
    " try {" ^
    "  Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ($dns4 + $dns6) -ErrorAction Stop;" ^
    "  Write-Host '    [OK] IPv4 + IPv6 DNS applied.' -ForegroundColor Green" ^
    " } catch {" ^
    "  Write-Host ('    [ERROR] ' + $_.Exception.Message) -ForegroundColor Red" ^
    " }" ^
    "}"

goto :eof


:: ============================================================
:: SHOW DNS FUNCTION
:: ============================================================

:DISPLAY_DNS

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.HardwareInterface -eq $true };" ^
    "foreach ($adapter in $adapters) {" ^
    " Write-Host '';" ^
    " Write-Host ('Adapter : ' + $adapter.Name) -ForegroundColor Cyan;" ^
    " Write-Host ('Index   : ' + $adapter.ifIndex);" ^
    " Write-Host '';" ^
    " $v4 = Get-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue;" ^
    " Write-Host 'IPv4 DNS:' -ForegroundColor Yellow;" ^
    " if ($v4.ServerAddresses) {" ^
    "   $v4.ServerAddresses | ForEach-Object { Write-Host ('  - ' + $_) }" ^
    " } else {" ^
    "   Write-Host '  - Automatic / DHCP'" ^
    " };" ^
    " Write-Host '';" ^
    " $v6 = Get-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv6 -ErrorAction SilentlyContinue;" ^
    " Write-Host 'IPv6 DNS:' -ForegroundColor Yellow;" ^
    " if ($v6.ServerAddresses) {" ^
    "   $v6.ServerAddresses | ForEach-Object { Write-Host ('  - ' + $_) }" ^
    " } else {" ^
    "   Write-Host '  - Automatic / DHCP'" ^
    " }" ^
    "}"

goto :eof


:: ============================================================
:: FLUSH DNS
:: ============================================================

:FLUSH_DNS

echo.
echo [*] Flushing DNS cache...

ipconfig /flushdns >nul 2>&1

if %errorlevel% equ 0 (
    echo [OK] DNS cache cleared.
) else (
    echo [WARNING] DNS flush failed.
)

goto :eof


:: ============================================================
:: EXIT
:: ============================================================

:EXIT
cls

echo.
echo Exiting Steam Cloak.
echo.

timeout /t 2 >nul
exit /b