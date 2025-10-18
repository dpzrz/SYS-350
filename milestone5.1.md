
# Milestone 5.1



## Deliverables

* Requirement 1:  Read your vmware username and vcenter hostname from a file.

* Requirement 2:  Provide data from your current pyvmomi session.  This must include DOMAIN/username, vcenter server and your source IP address.
Pull the domain/username and source ip from the connection information and vcenter_server can be the variable you read from your configuration file.

* Requirement 3:  Create a search function that filters all vms in vcenter by name. If no filter is added, return all VMs

* Requirement 4:  For each VM returned, provide the following meta-data
VM Name
Power State
Number of CPUs
Memory in GB
IP Address (don't forget to add vmware tools to pf and any other "on" system that does not have an IP address returned.


## Code Breakdown


### Imports

```python
import ssl
from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim
import getpass
import config
```


### Credential Handling

```python
VCENTER = config.vcenter1
USERNAME = config.username1
PASSWORD = getpass.getpass()
```
Reads **vCenter hostname** and **username** from the `config.py` file.

Securely requests the **password** using `getpass()` so it isn’t stored in plain text.


### Connect to vCenter

```python
def connect_vcenter():
    ctx = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    ctx.verify_mode = ssl.CERT_NONE

    si = SmartConnect(host=VCENTER, user=USERNAME, pwd=PASSWORD, sslContext=ctx)
```

Sets up an SSL context using **TLS 1.2** and ignores certificate validation (safe for test environments).

Connects to the vCenter Server with the given credentials and returns a **service instance (`si`) object.

---

### Retrieve Session Info

```python
session = si.content.sessionManager.currentSession
domain_user = session.userName
source_ip = session.ipAddress
```

* Accesses the current user session via the `sessionManager`.
* Extracts the **domain/username** and the **client’s source IP address**.

---

### Print Connection Summary

```python
print("\n=== Session Info ===")
print(f"vCenter Server : {VCENTER}")
print(f"Username       : {domain_user}")
print(f"Source IP      : {source_ip}")
print("====================\n")
```

Displays formatted session details confirming a successful login.

---

### Return the Session Instance

```python
    return si
```

Returns the active connection (`si`) for use by other functions.

---

### Search Virtual Machines

```python
def search_vms(si, name_filter=None):
    content = si.RetrieveContent()
    view = content.viewManager.CreateContainerView(content.rootFolder, [vim.VirtualMachine], True)
    vms = view.view
    view.Destroy()
```

* Retrieves all virtual machines from vCenter’s inventory.
* Creates a **ContainerView** that lists every `VirtualMachine` object.

```python
if name_filter:
  vms = [vm for vm in vms if name_filter.lower() in vm.name.lower()]
  return vms
```
s
* Optionally filters VMs by a name substring (case-insensitive).
* Returns either the filtered list or all VMs.

---

### Get VM Info Function

```python
def get_vm_info(vm):
    s = vm.summary
    ip = s.guest.ipAddress or "No IP (VMware Tools off)"
```

`vm.summary` gives a snapshot of the VM’s configuration and runtime info.

IP address is pulled from VMware Tools (or labeled if unavailable).

```python
    return {
        "VM Name": vm.name,
        "Power State": s.runtime.powerState,
        "vCPUs": s.config.numCpu,
        "Memory (GB)": round(s.config.memorySizeMB / 1024, 1),
        "IP Address": ip
    }
```
Returns a dictionary containing the infraomting formatted above.

### Interactive VM Filter

```python
def filter_vms(si):
    name = input("Enter the VM name to search for (press Enter for all): ")
    
    vms = search_vms(si, name_filter=name if name else None)
    print(f"\n=== Found {len(vms)} VM(s) ===\n")
```

Prompts the user for a name filter.
Calls the `search_vms()` function and counts results

```python
    for vm in vms:
        info = get_vm_info(vm)
        for k, v in info.items():
            print(f"{k:15}: {v}")
        print("-" * 40)
```

Prints each VM’s details in a formatted, human-readable layout.


### vCenter Information

```python
def vcenterInfo(si):
    aboutInfo = si.content.about
    print(aboutInfo)
    print(aboutInfo.fullName)
```

Retrieves the starter statemnt we usde in the begginging of the activity. This simply prints the about vCenter Server info.

### Main Menu System

```python
def main_menu(si):
    while True:
        print("\n=== VMware vCenter Menu ===")
        print("1. VM Search")
        print("2. Vcenter Info")
        print("3. Disconnect & Exit")

        choice = input("Enter choice (1 - 3): ")
```

Displays a simple interactive menu for the user to select an action.

```python
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
```


### Script Main

```python
if __name__ == "__main__":
    si = connect_vcenter()
    main_menu(si)
```

When run directly, the script:

  1. Connects to vCenter using `connect_vcenter()`.
  2. Launches the main interactive menu.
  3. Keeps the session alive until the user chooses to disconnect.

  ---

  Resources:

  [Lisiting VM's](https://read.virtualizeplanet.com/?p=1869)
  
  [VM Properties](https://gist.github.com/kurtn3x/5984f007796af987686dd875a638bdf0)
  
  [Pyvmomi Info](https://vcloudnine.de/first-steps-with-python-and-pyvmomi-vsphere-sdk-for-python/)
  
  [VM Scan](https://vthinkbeyondvm.com/pyvmomi-tutorial-how-to-get-all-the-core-vcenter-server-inventory-objects-and-play-around/)

  [Python Menu](https://www.youtube.com/watch?v=63nw00JqHo0)
  
  

