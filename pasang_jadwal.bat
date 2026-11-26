@echo off
setlocal
title Pasang Jadwal Daya Otomatis

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
  "  Write-Host '[1/6] Mengaktifkan mode Hibernate penuh di sistem...' -ForegroundColor Cyan; " ^
  "  powercfg /h on; " ^
  "  if ($LASTEXITCODE -ne 0) { throw 'Gagal mengaktifkan Hibernate (powercfg /h on).' }; " ^
  "  powercfg /h /type full 2>$null; " ^
  "  if ($LASTEXITCODE -ne 0) { Write-Warning 'Tidak dapat menyetel tipe hiberfile ke full; melanjutkan dengan konfigurasi default.' }; " ^
  "  $availLines = @(); $seenState = $false; " ^
  "  foreach ($line in (powercfg /a)) { " ^
  "    if ($line -match 'not available|tidak tersedia') { break }; " ^
  "    if ($seenState -and [string]::IsNullOrWhiteSpace($line)) { break }; " ^
  "    if ($line -match '^\s+\S') { $seenState = $true }; " ^
  "    $availLines += $line; " ^
  "  }; " ^
  "  $avail = $availLines -join ' '; " ^
  "  if ($avail -notmatch 'Hibernat|Hibernasi') { throw 'Sistem atau BIOS ini tidak mendukung atau memblokir Hibernate.' }; " ^
  "  if ($avail -match 'S0 Low Power Idle') { Write-Warning 'Sistem menggunakan Modern Standby (S0). Beberapa perangkat S0 membatasi bangun otomatis dari Hibernate (S4).' }; " ^
  "  Write-Host '[2/6] Mengaktifkan Wake Timers & menonaktifkan Unattended Sleep (semua Power Plan)...' -ForegroundColor Cyan; " ^
  "  $schemes = [regex]::Matches((powercfg /list | Out-String), '[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}') | ForEach-Object { $_.Value } | Select-Object -Unique; " ^
  "  if (-not $schemes) { $schemes = @('SCHEME_CURRENT') }; " ^
  "  foreach ($s in $schemes) { " ^
  "    powercfg /SETACVALUEINDEX $s SUB_SLEEP RTCWAKE 1; " ^
  "    if ($LASTEXITCODE -ne 0) { throw ('Gagal mengaktifkan Wake Timers (AC) pada skema ' + $s) }; " ^
  "    powercfg /SETDCVALUEINDEX $s SUB_SLEEP RTCWAKE 1; " ^
  "    if ($LASTEXITCODE -ne 0) { Write-Warning ('Gagal mengaktifkan Wake Timers (DC) pada skema ' + $s) }; " ^
  "    powercfg /SETACVALUEINDEX $s 238c9fa8-0aad-41ed-83f4-97be242c8f20 7bc4a2f9-d8fc-4469-b07b-33eb785aaca0 0; " ^
  "    if ($LASTEXITCODE -ne 0) { Write-Warning ('Gagal menyetel Unattended Sleep Timeout (AC) pada skema ' + $s) }; " ^
  "    powercfg /SETDCVALUEINDEX $s 238c9fa8-0aad-41ed-83f4-97be242c8f20 7bc4a2f9-d8fc-4469-b07b-33eb785aaca0 0; " ^
  "    if ($LASTEXITCODE -ne 0) { Write-Warning ('Gagal menyetel Unattended Sleep Timeout (DC) pada skema ' + $s) }; " ^
  "  }; " ^
  "  powercfg /SETACTIVE SCHEME_CURRENT; " ^
  "  if ($LASTEXITCODE -ne 0) { throw 'Gagal menerapkan skema daya aktif.' }; " ^
  "  $rtcIdx = [regex]::Matches((powercfg /q SCHEME_CURRENT SUB_SLEEP RTCWAKE | Out-String), '0x[0-9a-fA-F]{8}'); " ^
  "  $rtcAcOk = ($rtcIdx.Count -ge 2 -and $rtcIdx[$rtcIdx.Count - 2].Value -eq '0x00000001'); " ^
  "  if ($rtcIdx.Count -ge 2 -and -not $rtcAcOk) { Write-Warning ('RTCWAKE AC terbaca ' + $rtcIdx[$rtcIdx.Count - 2].Value + ' (bukan 0x00000001). Kemungkinan dibatasi Group Policy (GPO) kantor.') }; " ^
  "  $idleIdx = [regex]::Matches((powercfg /q SCHEME_CURRENT SUB_SLEEP STANDBYIDLE | Out-String), '0x[0-9a-fA-F]{8}'); " ^
  "  if ($idleIdx.Count -ge 2) { $idleSec = [Convert]::ToInt64($idleIdx[$idleIdx.Count - 2].Value, 16); if ($idleSec -gt 0) { Write-Host ('  [INFO] Sleep otomatis normal (STANDBYIDLE) saat ini: ' + [math]::Round($idleSec / 60, 1) + ' menit.') -ForegroundColor DarkYellow } }; " ^
  "  Write-Host '[3/6] Menjadwalkan Auto-Restart (Rabu & Minggu 22:30)...' -ForegroundColor Cyan; " ^
  "  $actRest = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '/r /f /t 60'; " ^
  "  $trigRest = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday,Sunday -At (Get-Date -Hour 22 -Minute 30 -Second 0); " ^
  "  $setRest = New-ScheduledTaskSettingsSet -WakeToRun -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; " ^
  "  Register-ScheduledTask -TaskName 'AutoRestart_RabuMinggu' -Action $actRest -Trigger $trigRest -Settings $setRest -User 'SYSTEM' -RunLevel Highest -Force | Out-Null; " ^
  "  Write-Host '[4/6] Menjadwalkan Auto-Hibernate (Setiap Hari 23:00)...' -ForegroundColor Cyan; " ^
  "  $actHib = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '/h /f'; " ^
  "  $trigHib = New-ScheduledTaskTrigger -Daily -At (Get-Date -Hour 23 -Minute 0 -Second 0); " ^
  "  $setHib = New-ScheduledTaskSettingsSet -WakeToRun -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; " ^
  "  Register-ScheduledTask -TaskName 'AutoHibernate_Malam' -Action $actHib -Trigger $trigHib -Settings $setHib -User 'SYSTEM' -RunLevel Highest -Force | Out-Null; " ^
  "  Write-Host '[5/6] Menjadwalkan Auto-Wake (Setiap Hari 06:00)...' -ForegroundColor Cyan; " ^
  "  $wakeAt = Get-Date -Hour 6 -Minute 0 -Second 0; " ^
  "  if ((Get-Date) -ge $wakeAt) { $wakeAt = $wakeAt.AddDays(1) }; " ^
  "  $actWake = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument '/c exit'; " ^
  "  $trigWake = New-ScheduledTaskTrigger -Daily -At $wakeAt; " ^
  "  $setWake = New-ScheduledTaskSettingsSet -WakeToRun -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; " ^
  "  Register-ScheduledTask -TaskName 'AutoWake_06Pagi' -Action $actWake -Trigger $trigWake -Settings $setWake -User 'SYSTEM' -RunLevel Highest -Force | Out-Null; " ^
  "  Write-Host '[6/6] Memverifikasi jadwal & Wake Timers...' -ForegroundColor Cyan; " ^
  "  Write-Host ''; " ^
  "  Write-Host 'BERHASIL! Ringkasan jadwal terdaftar:' -ForegroundColor Green; " ^
  "  Get-ScheduledTask -TaskName 'AutoRestart_RabuMinggu','AutoHibernate_Malam','AutoWake_06Pagi' | ForEach-Object { $info = $_ | Get-ScheduledTaskInfo; [PSCustomObject]@{ Task = $_.TaskName; State = $_.State; WakeToRun = $_.Settings.WakeToRun; NextRun = $info.NextRunTime; LastRun = $info.LastRunTime } } | Format-Table -AutoSize; " ^
  "  $timers = powercfg /waketimers | Out-String; " ^
  "  if ($timers -match 'AutoWake_06Pagi') { Write-Host '[OK] Wake timer AutoWake_06Pagi terdeteksi aktif di Windows.' -ForegroundColor Green } elseif (-not $rtcAcOk) { Write-Warning 'AutoWake_06Pagi tidak terlihat di powercfg /waketimers dan RTCWAKE AC tidak aktif. Cek apakah Wake Timers dibatasi GPO.' } else { Write-Host '[INFO] RTCWAKE sudah aktif (0x00000001) dan AutoWake_06Pagi siap (WakeToRun=True). Windows kadang tidak menampilkan wake timer task masa depan di powercfg /waketimers sebelum mendekati jadwal atau saat masuk Sleep/Hibernate. Cek hasil bangun via cek_jadwal.bat setelah pukul 06:00.' -ForegroundColor Yellow }; " ^
  "  Write-Host 'Catatan PC Kantor: Pastikan listrik/UPS tetap menyala malam hari dan BIOS tidak memblokir Wake from S4 (matikan ErP/Deep Sleep jika ada).' -ForegroundColor Gray; " ^
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
