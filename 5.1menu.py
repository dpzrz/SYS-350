import ssl
from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim
import getpass
import config

# Grabs Credentials from another file

VCENTER = config.vcenter1
USERNAME = config.username1
PASSWORD = getpass.getpass()

# Connect to vCenter

def connect_vcenter():
    ctx = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    ctx.verify_mode = ssl.CERT_NONE

    si = SmartConnect(host=VCENTER, user=USERNAME, pwd=PASSWORD, sslContext=ctx)

    # Pulls the Username and Source IP from the session.Manager Module ---> current Session Module
    session = si.content.sessionManager.currentSession
    domain_user = session.userName
    source_ip = session.ipAddress


    # Prints Session info fomratted for the user using the variables above
    print("\n=== Session Info ===")
    print(f"vCenter Server : {VCENTER}")
    print(f"Username       : {domain_user}")
    print(f"Source IP      : {source_ip}")
    print("====================\n")

    return si


# Search and filter VMs
def search_vms(si, name_filter=None):
    content = si.RetrieveContent()
    view = content.viewManager.CreateContainerView(content.rootFolder, [vim.VirtualMachine], True)
    vms = view.view
    view.Destroy()

    if name_filter:
        vms = [vm for vm in vms if name_filter.lower() in vm.name.lower()]
    return vms


# Get VM metadata
def get_vm_info(vm):
    s = vm.summary
    ip = s.guest.ipAddress or "No IP (VMware Tools off)"
    return {
        "VM Name": vm.name,
        "Power State": s.runtime.powerState,
        "vCPUs": s.config.numCpu,
        "Memory (GB)": round(s.config.memorySizeMB / 1024, 1),
        "IP Address": ip
    }



# Filters out VMs using the functionos above
def filter_vms(si):
    name = input("Enter the VM name to search for (press Enter for all): ")
    
    # If user presses Enter it will return all VMs
    vms = search_vms(si, name_filter=name if name else None)
    print(f"\n=== Found {len(vms)} VM(s) ===\n")
    for vm in vms:
        info = get_vm_info(vm)
        for k, v in info.items():
            print(f"{k:15}: {v}")
        print("-" * 40)

# Prints out info about Vsphere
def vcenterInfo(si):
    aboutInfo=si.content.about
    print(aboutInfo)
    print(aboutInfo.fullName)


# Main Menu
def main_menu(si):
    while True:
        print("\n=== VMware vCenter Menu ===")
        print("1. VM Search")
        print("2. Vcenter Info")
        print("3. Disconnect & Exit")

        choice = input("Enter choice (1 - 3): ")

        if choice == "1":
            filter_vms(si)
        elif choice == "2":
            vcenterInfo(si)
        elif choice == "3":
            Disconnect(si)
            print("Disconnected from vCenter")
            break
        else:
            print("Invalid choice. Please try again.")

# Run

if __name__ == "__main__":
    si = connect_vcenter()
    main_menu(si)