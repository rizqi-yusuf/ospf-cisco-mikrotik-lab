# EXAMPLE ONLY — MikroTik startup config was not present in source project.
# Assumptions: RouterOS v7; ether1 is WAN; ether2 is LAN; both links use /24.
# WAN host 200.20.20.1 is inferred; topology screenshot labels network only.
# Verify interface names and version before importing.
/interface bridge
add name=bridge-lan
/interface bridge port
add bridge=bridge-lan interface=ether2
/ip address
add address=200.20.20.1/24 interface=ether1 comment="WAN to Cisco R1"
add address=192.168.20.1/24 interface=bridge-lan comment="LAN gateway"
/routing ospf instance
add name=ospf-v2 version=2 router-id=1.1.1.1
/routing ospf area
add name=backbone instance=ospf-v2 area-id=0.0.0.0
/routing ospf interface-template
add area=backbone networks=200.20.20.0/24
add area=backbone networks=192.168.20.0/24
