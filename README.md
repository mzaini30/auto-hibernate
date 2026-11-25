# Auto-Hibernate & Power Automation for Windows

Skrip batch sederhana untuk mengatur jadwal otomatisasi daya (Power Management) pada Windows menggunakan **Windows Task Scheduler** dan `powercfg`.

## Fitur Jadwal

1. **Auto-Restart**: Setiap hari **Rabu & Minggu** pukul **22:30** (`WakeToRun` aktif)
2. **Auto-Hibernate**: Setiap hari pukul **23:00** menggunakan `shutdown.exe /h /f` (`WakeToRun` aktif agar tetap berjalan meski komputer sudah masuk mode Sleep)
3. **Auto-Wake**: Setiap hari pukul **06:00** (membangunkan komputer dari mode Sleep/Hibernate dengan `WakeToRun` dan `StartWhenAvailable` aktif)
4. Otomatis mengaktifkan mode **Hibernate penuh** (`powercfg /h on` & `powercfg /h /type full`), izin **Wake Timers** (`RTCWAKE = 1`), dan menonaktifkan **Unattended Sleep Timeout** (`7bc4a2f9-d8fc-4469-b07b-33eb785aaca0 = 0`) pada semua Power Plan agar PC tidak otomatis tidur lagi setelah 2 menit saat bangun tanpa sentuhan user.
5. Otomatis memverifikasi apakah `RTCWAKE` tidak tertimpa GPO dan apakah `AutoWake_06Pagi` terdaftar di `powercfg /waketimers`.
6. Otomatis meminta izin Administrator (*UAC elevation*) jika dijalankan tanpa hak akses Administrator, termasuk untuk path folder yang mengandung spasi.

---

## File dalam Proyek

- **`pasang_jadwal.bat`** : Menyiapkan Hibernate penuh, mengaktifkan Wake Timers, menonaktifkan Unattended Sleep Timeout pada semua Power Plan, mendaftarkan jadwal ke Task Scheduler Windows, serta memverifikasi Wake Timers.
- **`cek_jadwal.bat`** : Menampilkan status task (`LastRun`, `NextRun`), nilai `RTCWAKE` & `Unattended Sleep Timeout`, daftar `powercfg /waketimers`, dan histori bangun terakhir (`Power-Troubleshooter`).
- **`hapus_jadwal.bat`** : Menghapus semua jadwal otomatisasi daya yang telah dipasang.

---

## Cara Penggunaan

### 1. Memasang Jadwal
Klik kanan pada file `pasang_jadwal.bat` lalu pilih **Run as administrator** (atau langsung klik dua kali, skrip akan meminta hak akses Administrator otomatis).

Skrip akan mendaftarkan 3 task ke Windows Task Scheduler:
- `AutoRestart_RabuMinggu`
- `AutoHibernate_Malam`
- `AutoWake_06Pagi`

### 2. Mengecek Status & Histori Wake Up
Jalankan `cek_jadwal.bat` (klik dua kali / **Run as administrator**) untuk memeriksa `LastRun` pada `AutoWake_06Pagi`, status `RTCWAKE`, `Unattended Sleep Timeout`, `powercfg /waketimers`, dan log bangun terakhir Windows.

### 3. Menghapus Jadwal
Jika sewaktu-waktu ingin membatalkan jadwal yang sudah dipasang, klik dua kali file `hapus_jadwal.bat` (atau **Run as administrator**).

---

## Persyaratan & Catatan Sistem

- Windows 10 / Windows 11 dengan hak akses Administrator
- Fitur Hibernate didukung oleh sistem/BIOS (`powercfg /h on` dan `/type full` dijalankan otomatis oleh skrip)
- Untuk fitur **Auto-Wake (06:00)** dari kondisi Hibernate (S4) di komputer kantor:
  - Pastikan **listrik/colokan/UPS tidak dimatikan** pada malam hari.
  - Pastikan BIOS/UEFI motherboard mengizinkan **RTC Alarm / Wake Timers** dari S4 (matikan opsi **ErP Ready / EuP 2013 / Deep Sleep S4-S5** di BIOS jika tersedia, karena fitur tersebut memutus daya wake timer saat Hibernate).
  - Sejumlah laptop modern dengan *Modern Standby S0* atau kebijakan **Group Policy (GPO)** IT kantor mungkin membatasi bangun otomatis dari S4.
  - Jika PC tetap menyala jam 06:00 tetapi tidur lagi setelah beberapa belas menit karena setting *Sleep after* (`STANDBYIDLE`) kantor pendek, setel **Sleep** di Power Options ke **Never** (karena malam hari sudah ditangani `AutoHibernate_Malam`).
