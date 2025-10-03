# Lab Instructions

## 1. Add New Virtual Networks
- Add 2 new virtual networks on your host: **DMZ** and **MGMT**
  <img width="823" height="351" alt="Screenshot 2025-09-23 171514" src="https://github.com/user-attachments/assets/bf4355bd-9758-43d6-9da1-e7d9fadf29d8" />

- Connect new adapters for those networks to your **pfSense firewall**  
- Select appropriate subnet/network addresses for those networks and assign IPs to the pfSense interfaces  
- Reference **M1** where we created our initial **SYS350 LAN** network  

---

## 2. Create a New VM: `web01-yourname`
- Place on **DMZ network**  
- Configure appropriate IP addresses/settings  
- Install a web service (e.g., Apache or NGINX)  
- Create a simple web page on each with:  
  - your name  
  - server name  

---

## 3. Create a New Ubuntu Server: `Backup01-yourname`
- Place on **MGMT network**  
- Configure appropriate IP addresses/settings  

---

## 4. Configure Firewall Settings
- Allow your new **DMZ** and **MGMT** networks to access the Internet  
- Allow **MGMT** and **LAN** to access **DMZ**  
- **But not vice versa!** (DMZ should not be able to initiate connections to MGMT and LAN)  
- Allow **web (80,443)** from anywhere to **DMZ**  

📖 Resource: *pfSense firewall rules guide*  



# Physical setup
## Add 2 new virtual networks on your host - DMZ and MGMT 

   -  Connect new adapters for those networks to your pfSense firewall
   -  Select appropriate subnet/network addresses for those networks and assign IPs to the pfSense interfaces
## Create a new VM: web01-yourname

  - Place on DMZ network
  - Configure appropriate IP addresses/settings
  - Install a web service (e.g. Apache or NGINX)
  - Create a simple web page on each with yourname, servername...

## Create new Ubuntu server: Backup01-yourname

  - Place on MGMT network
  - Configure appropriate IP addresses/settings
