@echo off
setlocal
title Cek Status Jadwal ^& Wake Up Daya Windows

:: Cek apakah dijalankan sebagai Administrator
fltmc >nul 2>&1
if errorlevel 1 (
    echo Meminta izin Administrator...
    set "BAT_PATH=%~f0"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', 'call', ([char]34 + $env:BAT_PATH + [char]34)) -Verb RunAs } catch { Write-Host ('Gagal meminta izin Administrator: ' + $_.Exception.Message) -ForegroundColor Red; exit 1 }"
    if errorlevel 1 (
        echo.
        echo Tidak dapat menjalankan sebagai Administrator.
        echo Coba klik kanan file ini lalu pilih "Run as administrator".
        pause
        exit /b 1
    )
    exit /b
)

echo ========================================================
echo   DIAGNOSTIK JADWAL OTOMATISASI DAYA ^& WAKE UP
echo ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Continue'; " ^
  "Write-Host '--- [1] Status Task Scheduler ---' -ForegroundColor Cyan; " ^
  "$names = @('AutoRestart_RabuMinggu', 'AutoHibernate_Malam', 'AutoWake_06Pagi'); " ^
  "$tasks = Get-ScheduledTask -TaskName $names -ErrorAction SilentlyContinue; " ^
  "if ($tasks) { " ^
  "  $tasks | ForEach-Object { $i = $_ | Get-ScheduledTaskInfo; [PSCustomObject]@{ Task = $_.TaskName; State = $_.State; WakeToRun = $_.Settings.WakeToRun; LastRun = $i.LastRunTime; LastResult = ('0x{0:X}' -f $i.LastTaskResult); NextRun = $i.NextRunTime } } | Format-Table -AutoSize; " ^
  "} else { Write-Host 'Tidak ada task yang terdaftar.' -ForegroundColor Yellow }; " ^
  "Write-Host '--- [2] Konfigurasi Power Plan Aktif ---' -ForegroundColor Cyan; " ^
  "$rtc = [regex]::Matches((powercfg /q SCHEME_CURRENT SUB_SLEEP RTCWAKE | Out-String), '0x[0-9a-fA-F]{8}'); " ^
  "$unatt = [regex]::Matches((powercfg /qh SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 7bc4a2f9-d8fc-4469-b07b-33eb785aaca0 | Out-String), '0x[0-9a-fA-F]{8}'); " ^
  "$idle = [regex]::Matches((powercfg /q SCHEME_CURRENT SUB_SLEEP STANDBYIDLE | Out-String), '0x[0-9a-fA-F]{8}'); " ^
  "$rtcAc = if ($rtc.Count -ge 2) { $rtc[$rtc.Count - 2].Value } else { 'N/A' }; " ^
  "$unattAc = if ($unatt.Count -ge 2) { [Convert]::ToInt64($unatt[$unatt.Count - 2].Value, 16) } else { 'N/A' }; " ^
  "$idleAc = if ($idle.Count -ge 2) { [Convert]::ToInt64($idle[$idle.Count - 2].Value, 16) } else { 'N/A' }; " ^
  "Write-Host ('Allow wake timers (RTCWAKE AC)        : ' + $rtcAc + ' (0x00000001 = Enable)'); " ^
  "Write-Host ('Unattended sleep timeout (AC, detik)  : ' + $unattAc + ' (0 = Never)'); " ^
  "Write-Host ('Normal Sleep timeout (STANDBYIDLE AC) : ' + $idleAc + ' detik (0 = Never)'); " ^
  "Write-Host ''; " ^
  "Write-Host '--- [3] Wake Timers Aktif (powercfg /waketimers) ---' -ForegroundColor Cyan; " ^
  "powercfg /waketimers; " ^
  "Write-Host ''; " ^
  "Write-Host '--- [4] Histori Bangun Terakhir (Power-Troubleshooter) ---' -ForegroundColor Cyan; " ^
  "$ev = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Power-Troubleshooter'; Id=1} -MaxEvents 5 -ErrorAction SilentlyContinue; " ^
  "if ($ev) { $ev | ForEach-Object { Write-Host ('[' + $_.TimeCreated + ']'); (($_.Message -split '\r?\n' | Where-Object { $_.Trim() } | Select-Object -First 6) -join [Environment]::NewLine) | Write-Host -ForegroundColor Gray; Write-Host '---' } } else { Write-Host 'Belum ada event wake-up tercatat.' -ForegroundColor Yellow }; " ^
  "Write-Host '--- [5] Status Sleep Didukung (powercfg /a) ---' -ForegroundColor Cyan; " ^
  "powercfg /a"

echo.
pause
