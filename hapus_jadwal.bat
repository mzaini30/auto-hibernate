@echo off
setlocal
title Hapus Jadwal Daya Otomatis

:: Cek apakah dijalankan sebagai Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Meminta izin Administrator...
    set "BAT_PATH=%~f0"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', 'call', ([char]34 + $env:BAT_PATH + [char]34)) -Verb RunAs"
    exit /b
)

echo ========================================================
echo   MENGHAPUS JADWAL OTOMATISASI DAYA WINDOWS
echo ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop'; " ^
  "try { " ^
  "  $names = @('AutoHibernate_Malam', 'AutoRestart_RabuMinggu', 'AutoWake_06Pagi'); " ^
  "  foreach ($name in $names) { " ^
  "    if (Get-ScheduledTask -TaskName $name -ErrorAction SilentlyContinue) { " ^
  "      Unregister-ScheduledTask -TaskName $name -Confirm:$false; " ^
  "      Write-Host ('[DIHAPUS] ' + $name) -ForegroundColor Yellow; " ^
  "    } else { " ^
  "      Write-Host ('[TIDAK ADA] ' + $name) -ForegroundColor DarkGray; " ^
  "    } " ^
  "  } " ^
  "  Write-Host ''; " ^
  "  Write-Host 'Selesai memproses penghapusan jadwal.' -ForegroundColor Green; " ^
  "} catch { " ^
  "  Write-Host ('GAGAL: ' + $_.Exception.Message) -ForegroundColor Red; " ^
  "  exit 1; " ^
  "}"

echo.
pause
