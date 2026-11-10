# Lab OSPF Multi-Vendor: MikroTik CHR ↔ Cisco IOS

Dokumentasi lab routing dinamis **OSPF area 0** antara MikroTik CHR dan Cisco IOS di GNS3. Repository ini dipisah dari lab static routing/basic agar topologi, konfigurasi, dan tujuan pembelajaran tidak tercampur.

> **Bahasa:** [English documentation](README.en.md)

## Tujuan belajar

- Memahami peran OSPF sebagai Interior Gateway Protocol (IGP) link-state.
- Membentuk adjacency OSPF antara RouterOS MikroTik dan Cisco IOS.
- Mengiklankan LAN dari masing-masing router dan mempelajari route yang dipelajari secara dinamis.
- Memvalidasi konektivitas end-to-end dari VPCS, bukan hanya melihat status interface.
- Membandingkan konfigurasi OSPF RouterOS dengan Cisco IOS.

## Topologi dan addressing

Screenshot: [`screenshots/ospf-topology.png`](screenshots/ospf-topology.png). Diagram menunjukkan MikroTik `MikrotikCHR-1` terhubung ke Cisco `R1` pada jaringan berlabel `200.20.20.0`. LAN MikroTik berlabel `192.168.20.0`; LAN Cisco berlabel `192.168.10.0`. Masing-masing LAN berisi dua VPCS melalui switch L2.

| Segmen | Perangkat | Network yang terlihat | Fungsi |
|---|---|---:|---|
| WAN antar-router | `MikrotikCHR-1` e0 ↔ `R1` f0/0 | `200.20.20.0` | OSPF adjacency |
| LAN MikroTik | `MikrotikCHR-1` e1 ↔ switch L2 | `192.168.20.0` | PC1, PC2 |
| LAN Cisco | `R1` f0/1 ↔ switch L2 | `192.168.10.0` | PC3, PC4 |

Screenshot hanya menyatakan network label; prefix `/24` dan host IP tidak terbaca langsung dari label. File VPCS dan startup config Cisco pada project menyimpan nilai `/24` serta alamat host di bawah. File startup MikroTik tidak tersedia dalam project saat inspeksi; konfigurasi MikroTik yang disediakan di repo adalah **contoh**, bukan export config router yang sudah berjalan.

### Address plan untuk contoh konfigurasi

| Device/interface | Alamat contoh | Catatan |
|---|---:|---|
| MikroTik `ether1` (WAN) | `200.20.20.1/24` | Asumsi untuk melengkapi network label; peer Cisco `200.20.20.2/24` |
| Cisco `FastEthernet0/0` (WAN) | `200.20.20.2/24` | Diambil dari startup config Cisco pada project |
| MikroTik `ether2` (LAN) | `192.168.20.1/24` | Gateway PC1–PC2; pemetaan ether1/ether2 berdasarkan link adapter GNS3 |
| Cisco `FastEthernet0/1` (LAN) | `192.168.10.1/24` | Diambil dari startup config Cisco pada project |
| PC1 / PC2 | `192.168.20.2/24`, `.3/24` | Dari startup VPCS; gateway `.1` |
| PC3 / PC4 | `192.168.10.2/24`, `.3/24` | Dari startup VPCS; gateway `.1` |

**Penting:** RouterOS version/interface names dan alamat MikroTik WAN adalah asumsi contoh. Sesuaikan dengan image CHR dan port yang tampil di console. OSPF process/router ID Cisco dikonfigurasi di startup file; interface address/config MikroTik belum diverifikasi live.

## Isi repository

```text
.
├── README.md
├── README.en.md
├── ospf-cisco-mikrotik.gns3project
├── screenshots/
│   └── ospf-topology.png
└── configs/
    ├── routers/
    │   ├── R1-cisco.cfg
    │   └── MikrotikCHR-1-routeros.rsc
    └── pcs/
        ├── PC1.vpc
        ├── PC2.vpc
        ├── PC3.vpc
        └── PC4.vpc
```

Project archive menyimpan topology dan file pendukung GNS3, bukan image perangkat. Credential hash dan file private config Cisco dibuang dari salinan publik. Semua konfigurasi di `configs/` dipisah berdasarkan router dan PC; Cisco config bersumber dari startup config project setelah sanitasi, sedangkan MikroTik config berupa contoh.

## Membuka project

1. Install GNS3 dan siapkan compute/server yang sesuai.
2. Siapkan image Cisco IOS 3725/Dynamips, MikroTik CHR, dan Cisco vIOS-L2 yang diperoleh secara sah. Repository tidak menyertakan image, disk runtime, atau lisensi.
3. Buka `ospf-cisco-mikrotik.gns3project` lewat **File → Import portable project** atau fungsi import yang sesuai versi GNS3.
4. Jika GNS3 meminta image/template mapping, pilih image lokal yang cocok. Mapping bisa berbeda antar-komputer.
5. Periksa node `Cloud1`; node ini terhubung ke adapter tambahan MikroTik dan tidak diperlukan untuk uji OSPF antar-router. Jangan hubungkan ke jaringan eksternal kecuali memang diperlukan.
6. Periksa port/interface aktual pada tiap node sebelum menempelkan konfigurasi. Nama adapter GNS3 tidak selalu sama dengan nama interface OS.
7. Start router, switch, dan VPCS. Terapkan konfigurasi sesuai versi image, lalu validasi adjacency dan routing.

> GNS3 project bukan mesin virtual mandiri. Ketiadaan image atau template lokal akan mencegah node tertentu start.

## Konfigurasi

- [`configs/routers/R1-cisco.cfg`](configs/routers/R1-cisco.cfg): startup config Cisco IOS dari project, dibersihkan dari username/hash credential. Interface WAN/LAN dan OSPF process 1 memakai area 0.
- [`configs/routers/MikrotikCHR-1-routeros.rsc`](configs/routers/MikrotikCHR-1-routeros.rsc): konfigurasi contoh RouterOS v7. Periksa nama interface, addressing WAN, dan syntax sebelum import.
- [`configs/pcs/`](configs/pcs/): satu startup VPCS per PC; file mempertahankan IP/gateway yang ditemukan di project.

### Ringkasan cara kerja OSPF

Router mengaktifkan OSPF pada link yang cocok dengan network statement (Cisco) atau interface/template (RouterOS). Di link WAN, kedua router bertukar Hello packet; parameter area, subnet, timer, authentication, dan network type harus kompatibel agar adjacency terbentuk. Setelah adjacency Full, router bertukar link-state information, menjalankan SPF, lalu memasang prefix remote sebagai route OSPF. PC di LAN tidak menjalankan OSPF; gateway default mereka mengirim trafik ke router lokal.

## Validasi dan troubleshooting

Jalankan pemeriksaan berikut dari console masing-masing perangkat. Perintah tepat dapat berbeda menurut versi RouterOS/IOS.

**Cisco IOS**

```text
enable
show ip interface brief
show ip ospf neighbor
show ip ospf interface brief
show ip route ospf
show ip protocols
```

**MikroTik RouterOS v7**

```routeros
/interface print
/ip address print
/routing ospf instance print
/routing ospf interface-template print
/routing ospf neighbor print
/ip route print where protocol=ospf
```

**VPCS**

```text
show
ping 192.168.10.2
```

Dari PC LAN MikroTik, ping PC LAN Cisco (misalnya `192.168.10.2`); lakukan juga arah sebaliknya. Jika gagal, cek bertahap:

1. Interface router `up/up` dan kabel/adapter sesuai topology.
2. IP/mask kedua ujung WAN berada pada subnet yang sama; alamat tidak duplikat.
3. LAN gateway cocok dengan IP gateway yang diset di VPCS.
4. OSPF mencakup WAN dan LAN yang benar, serta kedua router memakai area yang sama pada link WAN.
5. Neighbor berstatus `Full` (Cisco) atau muncul sebagai neighbor established (RouterOS).
6. Route remote muncul di routing table; setelah itu uji ping dan periksa firewall/filter bila perlu.
7. Jangan menganggap label `200.20.20.0` memastikan prefix. Cocokkan subnet mask yang benar-benar dipakai di kedua router.

## Batasan dan keamanan

- Konfigurasi MikroTik adalah **sample**, belum dibuktikan pada router live. Contoh memakai RouterOS v7 dan `/24` WAN sebagai asumsi.
- Startup Cisco dan VPCS berasal dari file project yang tersedia; file router tidak otomatis membuktikan kondisi runtime terbaru.
- Screenshot merekam topology; screenshot tidak membuktikan adjacency OSPF atau ping sukses.
- Jangan gunakan konfigurasi lab langsung di jaringan produksi. Ganti addressing, router ID, authentication, dan kebijakan firewall sesuai kebutuhan.
- Jangan commit password, hash, private key, token, `.env`, atau image vendor.

## Lisensi

Materi dokumentasi dan contoh konfigurasi disediakan untuk pembelajaran. Hak atas image Cisco/MikroTik dan perangkat lunaknya tetap milik masing-masing vendor; dapatkan dan gunakan sesuai ketentuan vendor.
