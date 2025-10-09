# Veeam Backup Report Script
[![PowerShell](https://img.shields.io/badge/PowerShell-blue)](https://learn.microsoft.com/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green)](https://github.com/Klmouts/powershell-veeam-backup-check/blob/main/LICENSE)
[![Status](https://img.shields.io/badge/Status-Stable-success)](https://github.com/Klmouts/powershell-veeam-backup-check/blob/main/VeeamScriptReport.ps1)


## Overview

This PowerShell script is designed to generate a comprehensive report of Veeam backup jobs and repository details. It leverages Veeam Backup & Replication PowerShell modules and the Veeam Backup for Office 365 module to gather and present data about backup jobs, their statuses, and backup repositories.

## Features

- **Backup Job Details**: Retrieves information about various types of backup jobs including VM backups, file backups, tape backups, and more.
- **Office 365 Backup**: Includes details on Office 365 backup jobs if the Veeam Backup for Office 365 module is installed.
- **Backup to Tape Details**: Provides information about backup jobs that write data to tape.
- **Configuration Backup**: Reports on configuration backups if available.
- **Backup Repository Details**: Displays information on backup repositories, including total and free space.

## Requirements

- **Veeam Backup & Replication PowerShell Modules**: Required to interact with Veeam backup jobs and sessions.
- **Veeam Backup for Office 365 Module**: Required for Office 365 backup job details (optional).

## Usage

1. **Load the Script:**
   - Open a PowerShell terminal.
2. **Run the Script:**
   - Navigate to the directory containing the script.
   - Execute the script by running:
     ```powershell
     .\VeeamScriptReport.ps1
     ```
3. **Review the Report:**
   - The script will output a summary of backup jobs and repository details directly in the PowerShell window.

````## Example Output

### Backup Jobs

Name                                    JobType              LastResult          StartTime              EndTime                Description                                     
----                                    -------              ----------          ---------              -------                -----------                                     
Backup1                                Endpoint Backup          Failed       2024-08-17 22:42:41    2024-08-17 22:46:48    Created by  at 18/07/2024 12:11.
Backup2                                Endpoint Backup          Failed       2024-08-17 23:29:35    2024-08-17 23:33:42    Created by  at 18/07/2024 16:16.
Configuration Backup                   Configuration Backup     Warning                             29/08/2024 10:00:42    Configuration Backup        



### Backup Repositories

Name                          Type TotalSpace FreeSpace PercentUsed Description            
----                          ---- ---------- --------- ----------- -----------            
Default Backup Repository WinLocal 475.00 GB  257.00 GB 45.89%      Created by Veeam Backup

````
### Feedback
Found a bug or want a feature? Open an issue or submit a pull request.

## Author

- **Name**: Klontian Moutsa

## License

This project is licensed under the MIT License – see the ![License: MIT](https://img.shields.io/badge/License-MIT-green) file for details.

## Notes

- The script was created on 29/08/2024.
- Ensure that you have the required Veeam modules installed before running the script.


