import netifaces

def check_network_status():
    interfaces = netifaces.interfaces()
    for interface in interfaces:
        try:
            if netifaces.AF_LINK in netifaces.ifaddresses(interface):
                if netifaces.ifaddresses(interface)[netifaces.AF_LINK]:
                    return "Up"  # At least one interface is up
        except ValueError:
            pass  # Ignore interfaces that raise ValueError

    return "Down"  # No interfaces are up

if __name__ == "__main__":
    print(check_network_status())
