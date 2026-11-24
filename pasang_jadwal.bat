@echo off
setlocal
title Pasang Jadwal Daya Otomatis

:: Cek apakah dijalankan sebagai Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Meminta izin Administrator...
    set "BAT_PATH=%~f0"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', 'call', ([char]34 + $env:BAT_PATH + [char]34)) -Verb RunAs"
    exit /b
)

echo ========================================================
echo   MEMASANG JADWAL OTOMATISASI DAYA WINDOWS
echo ========================================================
echo  1. Auto-Restart   : Rabu ^& Minggu (22:30)
echo  2. Auto-Hibernate : Setiap Hari (23:00)
echo  3. Auto-Wake      : Setiap Hari (06:00)
echo ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop'; " ^
  "try { " ^
  "  Write-Host '[1/5] Mengaktifkan mode Hibernate di sistem...' -ForegroundColor Cyan; " ^
  "  powercfg /h on; " ^
  "  if ($LASTEXITCODE -ne 0) { throw 'Gagal mengaktifkan Hibernate (powercfg /h on).' }; " ^
  "  $avail = (powercfg /a) -join ' '; " ^
  "  if ($avail -notmatch 'Hibernat|Hibernasi') { throw 'Sistem atau BIOS ini tidak mendukung atau memblokir Hibernate.' }; " ^
  "  Write-Host '[2/5] Mengaktifkan izin Wake Timers (AC & DC)...' -ForegroundColor Cyan; " ^
  "  powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP RTCWAKE 1; " ^
  "  if ($LASTEXITCODE -ne 0) { throw 'Gagal mengaktifkan Wake Timers pada mode listrik (AC).' }; " ^
  "  powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP RTCWAKE 1; " ^
  "  if ($LASTEXITCODE -ne 0) { Write-Warning 'Gagal mengaktifkan Wake Timers pada mode baterai (DC).' }; " ^
  "  powercfg /SETACTIVE SCHEME_CURRENT; " ^
  "  if ($LASTEXITCODE -ne 0) { throw 'Gagal menerapkan skema daya aktif.' }; " ^
  "  Write-Host '[3/5] Menjadwalkan Auto-Restart (Rabu & Minggu 22:30)...' -ForegroundColor Cyan; " ^
  "  $actRest = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '/r /f /t 60'; " ^
  "  $trigRest = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday,Sunday -At (Get-Date -Hour 22 -Minute 30 -Second 0); " ^
  "  $setRest = New-ScheduledTaskSettingsSet -WakeToRun -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; " ^
  "  Register-ScheduledTask -TaskName 'AutoRestart_RabuMinggu' -Action $actRest -Trigger $trigRest -Settings $setRest -User 'SYSTEM' -RunLevel Highest -Force | Out-Null; " ^
  "  Write-Host '[4/5] Menjadwalkan Auto-Hibernate (Setiap Hari 23:00)...' -ForegroundColor Cyan; " ^
  "  $actHib = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '/h /f'; " ^
  "  $trigHib = New-ScheduledTaskTrigger -Daily -At (Get-Date -Hour 23 -Minute 0 -Second 0); " ^
  "  $setHib = New-ScheduledTaskSettingsSet -WakeToRun -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; " ^
  "  Register-ScheduledTask -TaskName 'AutoHibernate_Malam' -Action $actHib -Trigger $trigHib -Settings $setHib -User 'SYSTEM' -RunLevel Highest -Force | Out-Null; " ^
  "  Write-Host '[5/5] Menjadwalkan Auto-Wake (Setiap Hari 06:00)...' -ForegroundColor Cyan; " ^
  "  $actWake = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument '/c exit'; " ^
  "  $trigWake = New-ScheduledTaskTrigger -Daily -At (Get-Date -Hour 6 -Minute 0 -Second 0); " ^
  "  $setWake = New-ScheduledTaskSettingsSet -WakeToRun -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; " ^
  "  Register-ScheduledTask -TaskName 'AutoWake_06Pagi' -Action $actWake -Trigger $trigWake -Settings $setWake -User 'SYSTEM' -RunLevel Highest -Force | Out-Null; " ^
  "  Write-Host ''; " ^
  "  Write-Host 'BERHASIL! Ringkasan jadwal terdaftar:' -ForegroundColor Green; " ^
  "  Get-ScheduledTask -TaskName 'AutoRestart_RabuMinggu','AutoHibernate_Malam','AutoWake_06Pagi' | ForEach-Object { $info = $_ | Get-ScheduledTaskInfo; [PSCustomObject]@{ Task = $_.TaskName; State = $_.State; WakeToRun = $_.Settings.WakeToRun; NextRun = $info.NextRunTime } } | Format-Table -AutoSize; " ^
  "} catch { " ^
  "  Write-Host ('GAGAL: ' + $_.Exception.Message) -ForegroundColor Red; " ^
  "  exit 1; " ^
  "}"

if %errorLevel% neq 0 (
    echo.
    echo Pemasangan jadwal GAGAL. Periksa pesan kesalahan di atas.
)

echo.
pause
