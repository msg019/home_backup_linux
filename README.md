# home_backup_linux

A lightweight **Bash script** to create compressed backups of user directories in `/home` on Linux systems. It also generates a **MD5 checksum** and maintains a **log file** for tracking backup updates per user.

---

## Requirements

- `bash`
- [`tar`]
- [`pv`] -for showing progress during compression
- `Root` permissions

Install `pv` on Debian/Ubuntu-based systems:

```bash
sudo apt install pv
