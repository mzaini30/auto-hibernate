@echo off
title Hapus Jadwal Daya Otomatis
:: Cek apakah dijalankan sebagai Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Meminta izin Administrator...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

echo ========================================================
echo   MENGHAPUS JADWAL OTOMATISASI DAYA WINDOWS
echo ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Unregister-ScheduledTask -TaskName 'AutoHibernate_Malam' -Confirm:$false -ErrorAction SilentlyContinue; " ^
  "Unregister-ScheduledTask -TaskName 'AutoRestart_RabuMinggu' -Confirm:$false -ErrorAction SilentlyContinue; " ^
  "Unregister-ScheduledTask -TaskName 'AutoWake_06Pagi' -Confirm:$false -ErrorAction SilentlyContinue; " ^
  "Write-Host 'Semua jadwal berhasil dihapus dari sistem.' -ForegroundColor Green;"

echo.
pause
