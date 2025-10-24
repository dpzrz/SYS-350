


## Nested Virtualization

We first have to create our DNS entires on our DC so our soon to be created nested VMs have routes already set up. This is a pretty simple process that inlovles going into our Windows 2019 server manager and add these tou our PTR records.

We used the same naming convention used in the documentaiton
* nested1: 10.0.17.20    
* nested2: 10.0.17.30
* nested3: 10.0.17.40

In the screenshot below we can see the records have been added are named porperly with thte assigned IP addresses. 

<img width="583" height="284" alt="Screenshot 2025-10-06 180339" src="https://github.com/user-attachments/assets/b52ec384-4374-41df-b770-716632a1cdeb" />

Our next step invloves configuring autostart on our ESXI host. This step is only done tot the required boxes.
* Pfsense
* MGMT01
* DC
* vCenter

`It is to be configured and turned on in this exact order`

Adding our ESXI OVA is a process as we can only achieve this on oour vcenter ui interface. To work around this we can download the ova on our MGMT box and use that file on our vcenters ui all within MGMT.

Once its been downlaoed onto MGMT we can now deploy the OVA template file. This will create a new VM from the template.


<img width="933" height="559" alt="Screenshot 2025-10-06 at 7 07 33 PM" src="https://github.com/user-attachments/assets/2406348d-e634-4a8d-9fdb-0ef49f5f3ca2" />


From here we enter our basic setup for our vms and this includes:
* Datastore: Installed on 2
* Storage: This will always be thin provisions
* Hardware Specs: Allocate enough ram and a normal amount of storage
* Network Settings: Assign it the IP of our first nested box e.g. 10.0.17.20
    - DNS Domain Set to yourname.local
    - NTP set to pool.ntp.org
    - Gateway set to 10.0.17.2


After the setup has been completed it should look a little something like this. 

<img width="933" height="559" alt="Screenshot 2025-10-06 at 8 16 46 PM" src="https://github.com/user-attachments/assets/de6858ad-a6a7-48b8-ac2e-7891abcd917e" />














### Deliverables

Deliverable 1.  Provide a screenshot showing the A records for nested 1-3 similar to the one below.


Deliverable 2.  Provide a screenshot that shows your 4 hypervisors (the nested ones are virtual)


Deliverable 3.  Find the Cloning Task in the vCenter Task Console and provide a screenshot of the successful deployment similar to the one below.


Deliverable 4.  Create another VM and Custom specification for Rocky 8.  
Deploy the template with a custom IP address.  Provide a screenshot of both the cloning task as seen in Deliverable 3.  As well as a screenshot of the VMs powered on IP address that should match the one entered during New VM Creation.
