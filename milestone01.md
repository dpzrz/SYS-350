### Physical Installation of ESXI
- Plug USB into supermicro
- Hit F12 till boot selection screen appears
- Follow steps on-screen to configure your ESXI host. Make sure to tak enot of CLI controls when selecting options.
- Configure your IP using Assignmnet chart
- The ESXI address will be shown in the bottom of the start screen
  
  <img width="1030" height="675" alt="{DA8E8F7F-38A4-442D-BF71-100FBE34443D}" src="https://github.com/user-attachments/assets/094257e1-9668-4717-8225-3d51f62c90aa" />

- From here we can manage our vmware through the web

### Configuring datastores

The SSD number can vary but for my case there were two installed already. This meant I could create a second datastore called `datastore2-super20`
- Full disk with VMFS6
- With `datastore2-super20` selected hit browse and creata n ISOs folder inside of it
- Using cyber.local upload an Unbuntu and pfSense iso to the 2nd datastore

### Configuring Vswitch
First take a look at the default network topology and take note there is 1 uplink on the management network
- Removing the uplink as you create a vSwitch named `350-internal`
- Moving into our internal vSwitch we need to create a portgroup
-  Createa a port group by the same name `350-internal`
-  This should then show up in our Port groups tab inder our Netwokring Pane.


<img width="963" height="373" alt="{15FAD38B-CF2E-45AA-8635-9478FFB8490A}" src="https://github.com/user-attachments/assets/24f07026-53bb-48e7-b36e-fdd1d6f055a0" />

### Configuring pfSense
When iporting the ISO file we need to determine the parametrs of our box. Per the documentation the requieremtns are

Set Interface IP Addresses to the following 
* WAN/em0 (vmx0) 
    static ip of 192.168.3.x/24 
    gateway of 192.168.3.250 
* LAN/em1 (vmx1) 
    static ip of 10.0.17.2/24 

 Tis 

Name box pf-x
* ESXi7 Compatibility (You can export it later as an OVA if you want) 
* Other FreeBSD (64-bit) 12+
* Location on datastore2
* 1cpu, 2GiB RAM, 8gb disk
* THIN provision the disk 
* 2 Network Cards 
* One assigned to the VM Network 
* Another assigned to 350-Internal 

Follow prompts to install pfSense

Use the numbered options to Assign and Configure interfaces. All options are self explanitory when assigning IP addresses. The Assignmnets are 





1. ######  `Screenshot showing successful login to your ESXi host`
2. ######   `Screenshot showing your two datastores, where the second one has a directory of two iso files`
3. ######  `Screenshot from your mgmt1 box showing your 10.0.17.0/24 address as well as your successful ping to an internet host`
