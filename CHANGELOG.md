# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.2] - 2025-10-09
### Changed
- Simplified export logic: removed user prompt, automated CSV export to `/Reports/` folder.
- Unified all collected data into a single CSV file.
- Ensured timestamp-based filenames for better version tracking.
- Cleaned console output; removed redundant “Would you like to export” message.

### Added
- Automated CSV export (no user prompt)
- Modular structure with individual function files
- Enhanced README documentation and badges
- Clean error handling for missing modules

### Fixed
- Skipped Tape Jobs output when no jobs present
- Duplicate module loading warnings

---

## [2.1] - 2025-10-07
### Added
- Optional HTML report with CSS styling (now deprecated by default).
- Timestamped report exports.

---

## [2.0] - 2025-10-05
### Added
- Modular structure using `/functions/` folder for all PowerShell logic.
- Improved write-host feedback and consistent output formatting.
- Basic CSV export and error handling.

---

## [1.0] - 2024-08-29
### Added
- Initial version of VeeamScriptReport.ps1.
- Core functionality for collecting backup jobs, repositories, and configuration backups.
