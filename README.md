Veeam Backup Report Script
Overview
This PowerShell script is designed to generate a comprehensive report of Veeam backup jobs and repository details. It leverages Veeam Backup & Replication PowerShell modules and Veeam Backup for Office 365 module to gather and present data about backup jobs, their statuses, and backup repositories.

Features
Backup Job Details: Retrieves information about various types of backup jobs including VM backups, file backups, tape backups, and more.
Office 365 Backup: Includes details on Office 365 backup jobs if the Veeam Backup for Office 365 module is installed.
Backup to Tape Details: Provides information about backup jobs that write data to tape.
Configuration Backup: Reports on configuration backups if available.
Backup Repository Details: Displays information on backup repositories, including total and free space.
Requirements
Veeam Backup & Replication PowerShell Modules: Required to interact with Veeam backup jobs and sessions.
Veeam Backup for Office 365 Module: Required for Office 365 backup job details (optional).
Usage
Load the Script:

Open a PowerShell terminal.
Run the Script:

Navigate to the directory containing the script.
Execute the script by running:
powershell
Copy code
.\VeeamScriptReport.ps1
Review the Report:

The script will output a summary of backup jobs and repository details directly in the PowerShell window.
Example Output
yaml
Copy code
Name        : VM Backup Job 1
JobType     : VM Backup
LastResult  : Success
StartTime   : 2024-08-28 10:00:00
EndTime     : 2024-08-28 11:00:00
Description : Backup of VM1

Name        : Backup Repository 1
Type        : Disk
TotalSpace  : 500.00 GB
FreeSpace   : 200.00 GB
PercentUsed : 60.00%
Description : Main backup repository
Author
Name: Klontian Moutsa

License
This script is provided as-is. Use it at your own risk. There is no warranty or support provided. Feel free to modify and use it according to your needs.

Notes
The script was created on 29/08/2024.
Ensure that you have the required Veeam modules installed before running the script.
