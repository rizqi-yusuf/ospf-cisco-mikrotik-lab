# Multi-Vendor OSPF Lab: MikroTik CHR ↔ Cisco IOS

A GNS3 lab for **OSPF area 0** between MikroTik CHR and Cisco IOS. This repository is separate from the static-routing/basic lab so topology, configurations, and learning objectives stay distinct.

> **Language:** [Dokumentasi Bahasa Indonesia](README.md)

## Learning objectives

- Understand OSPF as a link-state Interior Gateway Protocol (IGP).
- Establish OSPF adjacency between MikroTik RouterOS and Cisco IOS.
- Advertise each router's LAN and inspect dynamically learned routes.
- Verify end-to-end connectivity from VPCS, not merely interface state.
- Compare OSPF configuration on RouterOS and Cisco IOS.

## Topology and addressing

Screenshot: [`screenshots/ospf-topology.png`](screenshots/ospf-topology.png). The diagram shows MikroTik `MikrotikCHR-1` connected to Cisco `R1` on a network labeled `200.20.20.0`. The MikroTik LAN is labeled `192.168.20.0`; the Cisco LAN is labeled `192.168.10.0`. Each LAN has two VPCS hosts connected through an L2 switch.

| Segment | Devices | Visible network label | Purpose |
|---|---|---:|---|
| Inter-router WAN | `MikrotikCHR-1` e0 ↔ `R1` f0/0 | `200.20.20.0` | OSPF adjacency |
| MikroTik LAN | `MikrotikCHR-1` e1 ↔ L2 switch | `192.168.20.0` | PC1, PC2 |
| Cisco LAN | `R1` f0/1 ↔ L2 switch | `192.168.10.0` | PC3, PC4 |

The screenshot provides network labels only; `/24` prefixes and host addresses are not directly visible there. VPCS files and the Cisco startup config in the project store `/24` values and host addresses listed below. No MikroTik startup config was present when the project was inspected; the MikroTik config in this repository is an **example**, not a recovered running configuration.

### Example address plan

| Device/interface | Example address | Notes |
|---|---:|---|
| MikroTik `ether1` (WAN) | `200.20.20.1/24` | Assumption to complete the network label; Cisco peer is `200.20.20.2/24` |
| Cisco `FastEthernet0/0` (WAN) | `200.20.20.2/24` | From the Cisco startup config in the project |
| MikroTik `ether2` (LAN) | `192.168.20.1/24` | PC1–PC2 gateway; ether1/ether2 mapping follows GNS3 adapter links |
| Cisco `FastEthernet0/1` (LAN) | `192.168.10.1/24` | From the Cisco startup config in the project |
| PC1 / PC2 | `192.168.20.2/24`, `.3/24` | From VPCS startup files; gateway `.1` |
| PC3 / PC4 | `192.168.10.2/24`, `.3/24` | From VPCS startup files; gateway `.1` |

**Important:** RouterOS version/interface names and the MikroTik WAN address are example assumptions. Adjust for the CHR image and interfaces shown in its console. Cisco OSPF process/router ID are present in its startup file; MikroTik interface addressing/configuration has not been verified live.

## Repository contents

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

The project archive contains topology and GNS3 support files, not device images. Cisco credential hashes and private config files are excluded from the public copy. Configurations are separated by router and PC; Cisco config comes from the sanitized project startup config, while MikroTik config is illustrative.

## Opening the project

1. Install GNS3 and prepare a compatible compute/server.
2. Obtain Cisco IOS 3725/Dynamips, MikroTik CHR, and Cisco vIOS-L2 images lawfully. This repository does not include vendor images, runtime disks, or licenses.
3. Open `ospf-cisco-mikrotik.gns3project` using **File → Import portable project** or the import feature for your GNS3 version.
4. If GNS3 requests image/template mapping, select matching local images. Mappings can differ between computers.
5. Inspect node `Cloud1`; it is connected to an additional MikroTik adapter and is not needed for inter-router OSPF tests. Do not connect it to an external network unless required.
6. Check the actual interfaces/ports on each node before applying configuration. GNS3 adapter names may differ from operating-system interface names.
7. Start routers, switches, and VPCS. Apply configurations for your image versions, then verify adjacency and routing.

> A GNS3 project is not a self-contained virtual machine. Nodes cannot start without the required local images/templates.

## Configuration files

- [`configs/routers/R1-cisco.cfg`](configs/routers/R1-cisco.cfg): Cisco IOS startup config from the project, sanitized to remove username/credential hash. WAN/LAN interfaces and OSPF process 1 use area 0.
- [`configs/routers/MikrotikCHR-1-routeros.rsc`](configs/routers/MikrotikCHR-1-routeros.rsc): RouterOS v7 example. Check interface names, WAN addressing, and syntax before import.
- [`configs/pcs/`](configs/pcs/): one VPCS startup file per host, preserving the IP/gateway values found in the project.

### OSPF overview

Routers enable OSPF on links matching Cisco network statements or RouterOS interface/templates. On the WAN, both routers exchange Hello packets. Area, subnet, timers, authentication, and network type must be compatible for adjacency to form. Once Full, routers exchange link-state information, run SPF, and install remote prefixes as OSPF routes. LAN PCs do not run OSPF; their default gateways forward traffic to local routers.

## Verification and troubleshooting

Run these checks from each device console. Exact commands may vary by RouterOS/IOS version.

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

From a PC on the MikroTik LAN, ping a Cisco-LAN PC (for example `192.168.10.2`), then test in the reverse direction. If it fails, check in this order:

1. Router interfaces are `up/up`, and cables/adapters match the topology.
2. Both WAN endpoints share a subnet/mask; addresses are not duplicated.
3. LAN gateways match the default gateways configured on VPCS.
4. OSPF covers the correct WAN and LAN networks, and both routers use the same area on the WAN link.
5. Neighbor state is `Full` (Cisco) or established/visible (RouterOS).
6. Remote routes appear in the routing table; then test ping and inspect firewall/filter rules if needed.
7. Do not assume the `200.20.20.0` label determines the prefix. Confirm the subnet mask actually configured on both routers.

## Limitations and security

- MikroTik configuration is a **sample**, not verified on a live router. It assumes RouterOS v7 and a `/24` WAN.
- Cisco and VPCS startup files come from the available project files; they do not prove current runtime state.
- The screenshot documents topology only; it does not prove OSPF adjacency or successful ping.
- Do not use lab config directly in production. Change addressing, router IDs, authentication, and firewall policy as needed.
- Never commit passwords, credential hashes, private keys, tokens, `.env` files, or vendor images.

## License

Documentation and sample configurations are provided for learning. Cisco/MikroTik images and software remain the property of their respective vendors; obtain and use them under the applicable vendor terms.
