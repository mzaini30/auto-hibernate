# Auto-Hibernate & Power Automation for Windows

Skrip batch sederhana untuk mengatur jadwal otomatisasi daya (Power Management) pada Windows menggunakan **Windows Task Scheduler** dan `powercfg`.

## Fitur Jadwal

1. **Auto-Restart**: Setiap hari **Rabu & Minggu** pukul **22:30** (`WakeToRun` aktif)
2. **Auto-Hibernate**: Setiap hari pukul **23:00** menggunakan `shutdown.exe /h /f` (`WakeToRun` aktif agar tetap berjalan meski komputer sudah masuk mode Sleep)
3. **Auto-Wake**: Setiap hari pukul **06:00** (membangunkan komputer dari mode Sleep/Hibernate)
4. Otomatis mengaktifkan mode **Hibernate** (`powercfg /h on`) dan izin **Wake Timers** (`RTCWAKE`) pada mode listrik (AC) maupun baterai (DC).
5. Otomatis meminta izin Administrator (*UAC elevation*) jika dijalankan tanpa hak akses Administrator, termasuk untuk path folder yang mengandung spasi.

---

## File dalam Proyek

- **`pasang_jadwal.bat`** : Menyiapkan Hibernate, mengaktifkan Wake Timers, dan mendaftarkan jadwal ke Task Scheduler Windows beserta ringkasan jadwal aktif.
- **`hapus_jadwal.bat`** : Menghapus semua jadwal otomatisasi daya yang telah dipasang.

---

## Cara Penggunaan

### 1. Memasang Jadwal
Klik kanan pada file `pasang_jadwal.bat` lalu pilih **Run as administrator** (atau langsung klik dua kali, skrip akan meminta hak akses Administrator otomatis).

Skrip akan mendaftarkan 3 task ke Windows Task Scheduler:
- `AutoRestart_RabuMinggu`
- `AutoHibernate_Malam`
- `AutoWake_06Pagi`

### 2. Menghapus Jadwal
Jika sewaktu-waktu ingin membatalkan jadwal yang sudah dipasang, klik dua kali file `hapus_jadwal.bat` (atau **Run as administrator**).

---

## Persyaratan & Catatan Sistem

- Windows 10 / Windows 11 dengan hak akses Administrator
- Fitur Hibernate didukung oleh sistem/BIOS (`powercfg /h on` dijalankan otomatis oleh skrip)
- Untuk fitur **Auto-Wake (06:00)** dari kondisi Hibernate (S4), pastikan BIOS/UEFI motherboard mengizinkan **RTC Alarm / Wake Timers** (sejumlah laptop modern dengan *Modern Standby S0* atau kebijakan IT kantor mungkin membatasi bangun otomatis dari S4)
