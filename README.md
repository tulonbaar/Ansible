# Introduction 
Repository for scripts, playbooks related to my work.
I try to comment everything I write, but if something is not clear - ask :)
Hopefully someday this will help someone. If not, at least I got some backup.

# Scripts
  - Scripts for different environments. If Ansible is not able to handle some tasks
  ## Powershell
    - GetCounters.ps1 - Returns counters for MSSQL Instance Database
    - config-winrm-ansible.ps1 - Configures WinRM to use with ansible instance
    ### 1.101
      - Scripts that copy files from my Oracle machine
    ### 1.137
      - Scripts that copy files from my Synology Drive (Windows Server is here a sort of middle-man, as Synology didn't want to work with me)
      
# Playbooks
  - Instructions for Ansible Instacnce
  ## Powershell
    - weekly-copy-full.yaml - playbook for management of weekly copy on my synology drives. Really impractical. Figured out different solution
    - powershell-script-run.yaml -Execute a PowerShell Script File on Windows Hosts
    - powershell-get-counters-mssql.yaml - Execute a PowerShell Script File on Windows Hosts (GetCounters.ps1)
