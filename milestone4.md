


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
















### Deliverables

Deliverable 1.  Provide a screenshot showing the A records for nested 1-3 similar to the one below.


Deliverable 2.  Provide a screenshot that shows your 4 hypervisors (the nested ones are virtual)


Deliverable 3.  Find the Cloning Task in the vCenter Task Console and provide a screenshot of the successful deployment similar to the one below.


Deliverable 4.  Create another VM and Custom specification for Rocky 8.  
Deploy the template with a custom IP address.  Provide a screenshot of both the cloning task as seen in Deliverable 3.  As well as a screenshot of the VMs powered on IP address that should match the one entered during New VM Creation.
