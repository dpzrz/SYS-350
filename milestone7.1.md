# Milestone 7 — Hyper-V: Linked Clones & Automation  


## Overview

This milestone explores **Linked Clones** in Microsoft Hyper-V, their practical uses, and the automation of VM lifecycle operations using **PowerShell**.

Linked Clones are extremely efficient for rapid deployments when most of the OS disk remains unchanged — but become less useful when frequent feature or security updates rewrite large portions of the base OS.

By the end of this milestone, we go from **manually creating linked clones** to **automating the entire process using PowerShell one-liners and scripts**.


`Deliverable 1.`  Hunt down the VHD file associated with your Ubuntu Base Image and give that file read only permissions. Provide a screenshot similar to the one below.
<img width="622" height="545" alt="image" src="https://github.com/user-attachments/assets/13cd3aee-06bd-4027-ac2e-ab9464fa97a1" />

`Deliverable 2.` Provide a screenshot similar to the one below that shows ‘sonofubuntu’ running as well as the very tiny difference disk attributes similar to the screenshot below.
<img width="611" height="448" alt="image" src="https://github.com/user-attachments/assets/5760b4f4-a268-45e3-bbc5-1fd736b688c8" />

Were then tasked, with creating ascript that will do all of the following:

`Deliverable 3.`  stop sonofubuntu
`Deliverable 4.`  take a checkpoint of sonofubuntu called snapshot1
`Deliverable 5.`  start sonofubuntu
`Deliverable 6.`  switch sonofubuntu to another network
<img width="622" height="438" alt="image" src="https://github.com/user-attachments/assets/3ca41d11-8319-4b4e-8367-39b814ffe5f0" />

<img width="626" height="440" alt="image" src="https://github.com/user-attachments/assets/7070aef0-b0f1-4341-aa4e-040df96c2ab5" />

<img width="626" height="441" alt="image" src="https://github.com/user-attachments/assets/a9328b64-44d1-4ca8-bb11-c1f5361ef1bd" />


### Deliverable 7.  Create a new Base VM using an OS that is not Ubuntu. Research & write a script to automate the creation of a Linked Clone of your new OS base image using Powershell. Provide a screenshot of your successful script/command(s) and a screenshot of your running OS and the virtual properties of your child disk.

<img width="532" height="386" alt="image" src="https://github.com/user-attachments/assets/405579d8-363c-47de-856e-130970d373a5" />
