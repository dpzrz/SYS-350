import ssl
import getpass
import time
from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim
import config

# Credentials from config 
VCENTER = config.vcenter1
USERNAME = config.username1
PASSWORD = getpass.getpass(f"Password for {USERNAME}@{VCENTER}: ")

# Connect to vCenter 
def connect_vcenter():
    ctx = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    ctx.verify_mode = ssl.CERT_NONE
    si = SmartConnect(host=VCENTER, user=USERNAME, pwd=PASSWORD, sslContext=ctx)

    session = si.content.sessionManager.currentSession
    domain_user = session.userName
    source_ip = session.ipAddress

    print("\n=== Session Info ===")
    print(f"vCenter Server : {VCENTER}")
    print(f"Username       : {domain_user}")
    print(f"Source IP      : {source_ip}")
    print("====================\n")

    return si

# Search/filter VMs 
def search_vms(si, name_filter=None):
    content = si.RetrieveContent()
    view = content.viewManager.CreateContainerView(content.rootFolder, [vim.VirtualMachine], True)
    vms = view.view
    view.Destroy()

    if name_filter:
        vms = [vm for vm in vms if name_filter.lower() in vm.name.lower()]
    return vms


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


def list_vms(si):
    name = input("VM name (leave blank for all): ")
    vms = search_vms(si, name_filter=name if name else None)
    for vm in vms:
        info = get_vm_info(vm)
        for k, v in info.items():
            print(f"{k:15}: {v}")
        print("-" * 40)

def power_on_off(si):
    name = input("VM name: ")
    vms = search_vms(si, name)
    action = input("1=Power On, 2=Power Off: ")
    for vm in vms:
        if action == "1":
            vm.PowerOn()
        else:
            vm.PowerOff()
        print(f"{vm.name} done")

def create_snapshot(si):
    name = input("VM name: ")
    vms = search_vms(si, name)
    snap_name = input("Snapshot name: ")
    for vm in vms:
        vm.CreateSnapshot(snap_name, "", False, False)
        print(f"Snapshot created for {vm.name}")

def delete_snapshot(si):
    name = input("VM name: ")
    snap_name = input("Snapshot name: ")
    vms = search_vms(si, name)
    if vms:
        vm = vms[0]
        if vm.snapshot:
            for snap in vm.snapshot.rootSnapshotList:
                if snap.name == snap_name:
                    snap.snapshot.RemoveSnapshot_Task(False)
                    print(f"Deleted snapshot {snap_name}")
                    break
        else:
            print("No snapshots found")

def full_clone(si):
    vm_name = input("VM to clone: ")
    clone_name = input("Clone name: ")
    vms = search_vms(si, vm_name)
    if vms:
        vm = vms[0]
        clonespec = vim.vm.CloneSpec()
        clonespec.location = vim.vm.RelocateSpec()
        clonespec.powerOn = False
        clonespec.template = False
        vm.Clone(folder=vm.parent, name=clone_name, spec=clonespec)
        print("Creating full clone...")

def rename_vm(si):
    
    vms = search_vms(si)
    print("\nVMs managed by vCenter:")
    for vm in vms:
        print(f"  - {vm.name}")
    
    vm_name = input("\nEnter VM name to rename: ").strip()
    
    target_vms = [vm for vm in vms if vm_name.lower() in vm.name.lower()]
    if not target_vms:
        print(f"No VM found matching '{vm_name}'")
        return
    
    vm = target_vms[0]
    
    confirm = input(f"Rename '{vm.name}'? (Y/N): ").strip().upper()
    if confirm != 'Y':
        print("Cancelled.")
        return
    
    new_name = input("Enter new VM name: ").strip()
    if not new_name:
        print("Name cannot be empty")
        return
    
    print(f"\nRenaming {vm.name} to {new_name}...")
    try:
        task = vm.Rename(newName=new_name)
        print(f"VM renamed successfully to '{new_name}'")
    except Exception as e:
        print(f"Failed to rename VM: {e}")


def delete_vm(si):
    name = input("VM name: ")
    vms = search_vms(si, name)
    for vm in vms:
        if vm.runtime.powerState == vim.VirtualMachinePowerState.poweredOn:
            vm.PowerOff()
        vm.Destroy()
        print(f"Deleted {vm.name}")

#vCenter Info 
def vcenter_info(si):
    about = si.content.about
    print(f"Full Name: {about.fullName}")
    print(f"Vendor: {about.vendor}")
    print(f"Version: {about.version}")
    print(f"API Type: {about.apiType}")


def main_menu(si):
    menu = {
        '1': ("List/Search VMs", list_vms),
        '2': ("Power On/Off VM", power_on_off),
        '3': ("Create Snapshot", create_snapshot),
        '4': ("Delete Snapshot", delete_snapshot),
        '5': ("Full Clone VM", full_clone),
        '6': ("Rename VM", rename_vm),
        '7': ("Delete VM", delete_vm),
        '8': ("vCenter Info", vcenter_info),
        '9': ("Disconnect & Exit", None)
    }

    while True:
        print("\nVMware vCenter Menu")
        for key in sorted(menu.keys()):
            print(f"{key}. {menu[key][0]}")

        choice = input("Enter choice: ")
        if choice in menu:
            if choice == "9":
                Disconnect(si)
                print("Disconnected from vCenter")
                break
            else:
                menu[choice][1](si)
        else:
            print("Invalid choice, please enter 1-9.")

# --- Run Script ---
if __name__ == "__main__":
    si = connect_vcenter()
    main_menu(si)
