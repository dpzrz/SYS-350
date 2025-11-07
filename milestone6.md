This kab focuses on the cretaion, instalation and configataion of the Microsoft serrvicec Hyper-V. This si sodne through a windows server manager base. In this lab we'll be going over the steps and configuration required to start a Hyper-V vm manager. 


### Boot Media

We start by creating a bootable usb drive that houses our windwos 2019 server manager image. This willbe the base of our services and network. 

<img width="341" height="481" alt="image" src="https://github.com/user-attachments/assets/9e4c63cc-dce4-44ac-be31-ce2167db4e92" />

With this bootable drive we then have to physically go over to our blade and reimage it using the basic steps. This will completly delete all data off the blades hardrives. All partitions and all information.

### Windows Server 2019

Using our normal setup for Windows 2019 we are now able to access server manager and configure our Hyper-V. Running through our checklist fro configuring our Windows server.

* Disabled DHCP and manually assigned the host IP from the course IP assignment sheet
* Verified DNS settings as `192.168.4.4` and `192.168.4.5`
* Checked network interface names. Mine shows up as Ethernet 8. I confirmed this by checking the adapter descriptions under Control Panel → Network and Internet → Network Connections
* Set the correct time zone and disabled automatic updates using `sconfig`

## Step 2. Installing Hyper-V and Management Tools

1. Opened Server Manager → Add Roles and Features
2. Selected Role-based or feature-based installation
3. Checked the Hyper-V role and included **Management Tools
4. Accepted default settings and rebooted when prompted

## Step 3. Configuring Hyper-V Networking

Hyper-V requires at least one external virtual switch to connect virtual machines to the physical network.
I opened Hyper-V Manager → Virtual Switch Manager and created two switches.

### External Switch (HyperV-WAN)

* Switch Type: External
* Connected to the physical adapter (Ethernet 8 on this host)
* Allows virtual machines to access the physical LAN and the Internet

### Internal Switch (LAN-INTERNAL)

* Switch Type: Internal
* Allows communication between the host and internal VMs but not the physical network
* This network will be used for internal communication and the pfSense LAN side


## Step 4. Installing Windows Admin Center (WAC)

### Download and Installation
 I downlaoded WAC from Google Chrome, I side stepped the IE firewall by tuniong it off in Server Manager. After downloading WAC we can run it and run its installation wizard. 

### Extension
My installtion had already been configured with Virtual Machine and Virtual Switch exetnsions.

## Step 5. Creating pfSense Virtual Machine

### VM Configuration

* Name: pfSense
* Processors: 2
* Hard Disk: 4 GB 
* Network Adapters:
  * Adapter 1: `HyperV-WAN`
  * Adapter 2: `LAN-INTERNAL`

### Installation

The VM was booted from the pfSense ISO.
During setup:

* Installed pfSense to the virtual hard disk.
* Assigned WAN to the external adapter and LAN to the internal adapter.
* Enabled DHCP on the LAN interface using subnet `10.0.5.0/24`.

## Step 6. Creating Windows 11 Virtual Machine

### VM Configuration

* Name: Windows11-Client
* Generation: 2
* Startup Memory: 4000 MB
* Processors: 2
* Hard Disk: 8 GB
* Network Adapter: `LAN-INTERNAL`
* Secure Boot: Disabled
* TPM: Enabled
* OS Source: Windows 11 vhd (provided by professor)

### Installation and Testing

1. Used the ipconfig /release and /renew to cycle our DHCP
2. Verified the VM received an IP address from pfSense via DHCP (e.g., `10.0.5.10`).
3. Opened Command Prompt and tested internet connectivity:
<img width="494" height="447" alt="image" src="https://github.com/user-attachments/assets/a8814bd0-b886-41c7-bc70-a990cfa4ea41" />







