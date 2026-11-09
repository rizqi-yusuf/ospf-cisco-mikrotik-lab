import os
from netmiko import ConnectHandler

routers = [
    {"device_type": "cisco_ios_telnet", "host": os.environ["CISCO_HOST"], "username": os.environ["CISCO_USERNAME"], "password": os.environ["CISCO_PASSWORD"], "command": "show ip ospf neighbor"},
    {"device_type": "mikrotik_routeros", "host": os.environ["MIKROTIK_HOST"], "username": os.environ["MIKROTIK_USERNAME"], "password": os.environ["MIKROTIK_PASSWORD"], "command": "/routing ospf neighbor print"},
]

for router in routers:
    command = router.pop("command")
    try:
        with ConnectHandler(**router) as connection:
            print(f"=== {router['device_type']} OSPF neighbors ===")
            print(connection.send_command(command))
    except Exception as exc:
        print(f"Connection failed for {router['device_type']}: {exc}")
