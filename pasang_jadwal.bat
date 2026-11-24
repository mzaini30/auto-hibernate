@echo off
title Pasang Jadwal Daya Otomatis
:: Cek apakah dijalankan sebagai Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Meminta izin Administrator...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
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
  "Write-Host '[1/4] Mengaktifkan izin Wake Timers di sistem...' -ForegroundColor Cyan; " ^
  "powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP RTCWAKE 1; " ^
  "powercfg /SETACTIVE SCHEME_CURRENT; " ^
  "Write-Host '[2/4] Menjadwalkan Auto-Restart (Rabu & Minggu 22:30)...' -ForegroundColor Cyan; " ^
  "$actRest = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '/r /f /t 60'; " ^
  "$trigRest = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday,Sunday -At 10:30PM; " ^
  "$setRest = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; " ^
  "Register-ScheduledTask -TaskName 'AutoRestart_RabuMinggu' -Action $actRest -Trigger $trigRest -Settings $setRest -User 'SYSTEM' -Force | Out-Null; " ^
  "Write-Host '[3/4] Menjadwalkan Auto-Hibernate (Setiap Hari 23:00)...' -ForegroundColor Cyan; " ^
  "$actHib = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '/h'; " ^
  "$trigHib = New-ScheduledTaskTrigger -Daily -At 11:00PM; " ^
  "$setHib = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; " ^
  "Register-ScheduledTask -TaskName 'AutoHibernate_Malam' -Action $actHib -Trigger $trigHib -Settings $setHib -User 'SYSTEM' -Force | Out-Null; " ^
  "Write-Host '[4/4] Menjadwalkan Auto-Wake (Setiap Hari 06:00)...' -ForegroundColor Cyan; " ^
  "$actWake = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument '/c exit'; " ^
  "$trigWake = New-ScheduledTaskTrigger -Daily -At 6:00AM; " ^
  "$setWake = New-ScheduledTaskSettingsSet -WakeToRun -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; " ^
  "Register-ScheduledTask -TaskName 'AutoWake_06Pagi' -Action $actWake -Trigger $trigWake -Settings $setWake -User 'SYSTEM' -Force | Out-Null; " ^
  "Write-Host 'BERHASIL! Semua jadwal otomatisasi telah diperbarui.' -ForegroundColor Green;"

echo.
pause
