# Lab OSPF Cisco dan MikroTik di GNS3

Project lab OSPF multi-vendor. Dokumentasi ini hanya Bahasa Indonesia.

## Isi lab

`ospf-cisco-mikrotik.gns3project` berisi Cisco 3725, dua MikroTik CHR, dua Cisco vIOS-L2, empat VPCS, dan node Cloud GNS3. Ada satu startup config Cisco yang sudah disanitasi serta konfigurasi IP VPCS. Sebagian router tidak memiliki startup config tersimpan; cek dan konfigurasi ulang sebelum tes.

## Image dan import

Arsip tidak menyertakan image vendor atau disk runtime. Siapkan image MikroTik CHR, Cisco IOS 3725 Dynamips, dan Cisco vIOS-L2 yang didapat secara sah. Import project di GNS3; sesuaikan mapping image/template dan port Cloud jika perlu. Arsip topology bukan VM mandiri.

## Otomasi OSPF dengan Netmiko

Script `netmiko-ospf-example.py` mengambil kredensial dan alamat dari environment, bukan source code. Install dependency `netmiko`, salin `.env.example` sebagai referensi lokal (jangan commit `.env`), lalu ekspor variabel lingkungan sebelum menjalankan. Cisco memakai IOS Telnet dan MikroTik memakai RouterOS API/SSH sesuai konfigurasi Netmiko. Jalankan hanya dalam lab terisolasi.

## Sanitasi dan keamanan

Project sumber berisi password hash Cisco dan RSA private key; keduanya dibuang. Script sumber menyimpan password terang-terangan; script pengganti memakai environment variables. Anggap password lama terekspos dan ganti jika masih dipakai. Jangan commit password, hash kredensial, private key, `.env`, atau konfigurasi produksi.
