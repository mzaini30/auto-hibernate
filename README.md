# Auto-Hibernate & Power Automation for Windows

Skrip batch sederhana untuk mengatur jadwal otomatisasi daya (Power Management) pada Windows menggunakan **Windows Task Scheduler** dan `powercfg`.

## Fitur Jadwal

1. **Auto-Restart**: Setiap hari **Rabu & Minggu** pukul **22:30**
2. **Auto-Hibernate**: Setiap hari pukul **23:00**
3. **Auto-Wake**: Setiap hari pukul **06:00** (membangunkan komputer dari mode tidur/hibernasi)
4. Otomatis mengaktifkan izin **Wake Timers** (`RTCWAKE`) pada Windows Power Plan.
5. Otomatis meminta izin Administrator (*UAC elevation*) jika dijalankan tanpa hak akses Administrator.

---

## File dalam Proyek

- **`pasang_jadwal.bat`** : Menyiapkan dan mendaftarkan jadwal ke Task Scheduler Windows.
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

## Persyaratan Sistem

- Windows 10 / Windows 11
- Mode Hibernasi aktif di Windows (`powercfg /h on`)
- Hak akses Administrator
