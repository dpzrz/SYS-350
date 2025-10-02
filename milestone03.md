
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


# pfSense Firewall Rules Milestone 03

## 1. Allow DMZ and MGMT networks to access the Internet

**On DMZ interface rules:**
- Action: Pass  
- Protocol: Any  
- Source: DMZ net  
- Destination: Any (or "not DMZ net")  
- Description: Allow DMZ → Internet  

**On MGMT interface rules:**
- Action: Pass  
- Protocol: Any  
- Source: MGMT net  
- Destination: Any  
- Description: Allow MGMT → Internet  

---

## 2. Allow MGMT and LAN to access DMZ

**On DMZ interface rules:**
- Action: Pass  
- Protocol: Any (or narrow down if needed)  
- Source: MGMT net, LAN net  
- Destination: DMZ net  
- Description: Allow MGMT+LAN → DMZ  


---

## 3. Prevent DMZ from accessing MGMT and LAN

**On DMZ interface rules, create block rules above the allow-to-Internet rule:**

- Action: Block  
- Protocol: Any  
- Source: DMZ net  
- Destination: MGMT net  
- Description: Block DMZ → MGMT  

- Action: Block  
- Protocol: Any  
- Source: DMZ net  
- Destination: LAN net  
- Description: Block DMZ → LAN  

*(Because rules are processed top-down, these hit before the general allow → Internet rule.)*

---

## 4. Allow Web (80/443) from anywhere to DMZ

**On DMZ interface rules:**
- Action: Pass  
- Protocol: TCP  
- Source: Any  
- Destination: DMZ address  
- Destination port range: 80 (HTTP), 443 (HTTPS)  
- Description: Allow Web → DMZ  



