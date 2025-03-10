import netifaces

def check_network_status():
    interfaces = netifaces.interfaces()
    
    # Skip loopback interfaces
    active_interfaces = [iface for iface in interfaces if not iface.startswith('lo')]
    
    for interface in active_interfaces:
        try:
            # Check for IPv4 address
            if netifaces.AF_INET in netifaces.ifaddresses(interface):
                return "Up"
            # Alternatively check for IPv6 address
            if netifaces.AF_INET6 in netifaces.ifaddresses(interface):
                addresses = netifaces.ifaddresses(interface)[netifaces.AF_INET6]
                # Filter out link-local addresses
                global_addresses = [addr for addr in addresses if not addr['addr'].startswith('fe80:')]
                if global_addresses:
                    return "Up"
        except (ValueError, KeyError):
            pass
    
    return "Down"

if __name__ == "__main__":
    print(check_network_status())
