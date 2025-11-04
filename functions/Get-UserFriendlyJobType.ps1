function Get-UserFriendlyJobType {
    param ([string]$JobType)

    switch ($JobType) {
        "EpAgentBackup"          { return "Endpoint Backup" }
        "SimpleBackupCopyPolicy" { return "Policy Backup" }
        "VMBackup"               { return "VM Backup" }
        "FileBackup"             { return "File Backup" }
        "TapeBackup"             { return "Tape Backup" }
        "ReplicaJob"             { return "Replication Backup" }
        "NetworkBackup"          { return "Network Backup" }
        "SQLBackup"              { return "SQL Backup" }
        "OracleBackup"           { return "Oracle Backup" }
        "NASBackup"              { return "NAS Backup" }
        "SharePointBackup"       { return "SharePoint Backup" }
        "ExchangeBackup"         { return "Exchange Backup" }
        default                  { return $JobType }
    }
}
