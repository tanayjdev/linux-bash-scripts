# Linux Bash Automation Scripts

![Linux](https://img.shields.io/badge/Linux-Ubuntu%2024.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Bash](https://img.shields.io/badge/Shell-Bash-121011?style=for-the-badge&logo=gnubash&logoColor=white)
![AWS](https://img.shields.io/badge/Cloud-AWS%20EC2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Automation](https://img.shields.io/badge/Focus-Automation-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-success?style=for-the-badge)

Production-style Linux automation scripts built and tested on AWS EC2 using Bash.

This repository contains real-world Linux administration and DevOps automation scripts focused on:

- server monitoring
- disk usage management
- automated backups
- log cleanup
- user provisioning
- log analysis
- cron automation

All scripts were developed during hands-on Linux + AWS practice on Ubuntu servers.

---

# Project Goals

The goal of this project was to simulate practical system administration and DevOps tasks commonly handled in real production environments.

Instead of writing isolated beginner scripts, this project focuses on:

- reusable automation
- logging and reporting
- error handling
- monitoring workflows
- scheduled execution
- operational maintenance

---

# Scripts Included

| Script | Purpose | Key Features |
|---|---|---|
| `server_health.sh` | Complete server monitoring | CPU, RAM, Disk, Services, Network |
| `disk_alerter.sh` | Disk usage monitoring | Threshold alerts, logs, reports |
| `log_cleaner.sh` | Log maintenance automation | Compression, deletion, cleanup reports |
| `user_creation.sh` | User provisioning automation | Validation, groups, sudo setup |
| `backup.sh` | Automated backup system | Compression, verification, retention |
| `find_large_files.sh` | Disk investigation tool | Detects storage-heavy files |
| `log_analyzer.sh` | Log analysis utility | grep + awk + sed powered summaries |

---

# Technologies Used

- Linux (Ubuntu 24.04 LTS)
- Bash Scripting
- AWS EC2
- Cron Jobs
- grep
- awk
- sed
- tar
- gzip
- SSH / SCP / rsync

---

# Environment

| Component | Details |
|---|---|
| OS | Ubuntu 24.04 LTS |
| Cloud Platform | AWS EC2 |
| Instance Type | t2.micro |
| Shell | Bash |
| Architecture | Linux CLI based automation |

---

# Project Structure

```text
linux-bash-scripts/
│
├── backup.sh
├── disk_alerter.sh
├── find_large_files.sh
├── log_analyzer.sh
├── log_cleaner.sh
├── server_health.sh
├── user_creation.sh
│
├── logs/
├── backups/
└── README.md
```

---

# Sample Production Workflow

```text
Cron Job
   ↓
Monitoring Script
   ↓
Logs Generated
   ↓
Alerts Triggered
   ↓
Cleanup / Backup Automation
```

---

# Features

## Monitoring
- CPU monitoring
- RAM monitoring
- Disk usage monitoring
- Service status checks
- Network connectivity checks

## Automation
- Scheduled cron execution
- Automated cleanup
- Automated backups
- Automated alert generation

## System Administration
- User provisioning
- Group management
- Permission handling
- Backup retention policies

## Log Processing
- Error detection
- Warning extraction
- Pattern filtering
- Statistical summaries

---

# Usage

## Clone Repository

```bash
git clone https://github.com/tanayjdev/linux-bash-scripts.git

cd linux-bash-scripts
```

---

# Make Scripts Executable

```bash
chmod +x *.sh
```

---

# 1. Server Health Check

```bash
./server_health.sh
```

### Monitors
- CPU usage
- RAM usage
- Disk usage
- Running services
- Internet connectivity

### Example Output

```bash
================================================
 SERVER HEALTH CHECK REPORT
================================================

CPU Usage: 12%
RAM Usage: 43%
Disk Usage: 38%

ssh: RUNNING
docker: RUNNING
nginx: RUNNING

Internet: CONNECTED
```

---

# 2. Disk Usage Alerter

```bash
./disk_alerter.sh
```

### Features
- monitors all partitions
- threshold-based alerts
- log file generation
- alert reporting

### Example

```bash
ALERT: / is at 85%
```

---

# 3. Log Cleaner

```bash
./log_cleaner.sh
```

### Features
- deletes old logs
- compresses recent logs
- cleanup reporting
- storage optimization

---

# 4. User Creation Script

## Interactive Mode

```bash
sudo ./user_creation.sh --interactive
```

## CSV Batch Mode

```bash
sudo ./user_creation.sh --file users.csv
```

### CSV Format

```text
username, full_name, group, sudo
```

### Features
- username validation
- automatic home creation
- sudo assignment
- group management
- welcome file creation

---

# 5. Backup Script

```bash
./backup.sh
```

### Features
- compressed backups
- integrity verification
- retention cleanup
- multiple source support
- automatic logging

### Example

```bash
Backup created successfully
Verification passed
```

---

# 6. Find Large Files

## Find files larger than 100MB

```bash
./find_large_files.sh /home 100M
```

## Find files larger than 1GB

```bash
./find_large_files.sh / 1G
```

---

# 7. Log Analyzer

```bash
./log_analyzer.sh /path/to/logfile.log
```

### Generates
- error counts
- warning counts
- hourly distribution
- filtered summaries

---

# Cron Automation

The following cron jobs were configured during testing:

```cron
# Health check every 15 minutes
*/15 * * * * /home/ubuntu/scripts/server_health.sh >> /home/ubuntu/logs/health.log 2>&1

# Disk alerts every hour
0 * * * * /home/ubuntu/scripts/disk_alerter.sh >> /home/ubuntu/logs/disk.log 2>&1

# Daily backups at 2 AM
0 2 * * * /home/ubuntu/scripts/backup.sh >> /home/ubuntu/logs/backup.log 2>&1

# Weekly log cleanup
0 23 * * 0 /home/ubuntu/scripts/log_cleaner.sh >> /home/ubuntu/logs/cleaner.log 2>&1
```

---

# Concepts Demonstrated

## Linux Administration
- process management
- user management
- file permissions
- disk operations
- package management

## Bash Scripting
- variables
- loops
- functions
- arrays
- conditionals
- return codes

## Automation
- cron scheduling
- monitoring workflows
- cleanup automation
- backup automation

## Log Analysis
- grep
- awk
- sed
- pipelines
- filtering and parsing

## Cloud & Networking
- AWS EC2
- SSH
- SCP
- rsync
- connectivity troubleshooting

---

# What I Learned

Through this project I learned:

- how to automate repetitive Linux administration tasks
- how monitoring systems are structured
- how cron jobs are used in production
- how backup retention policies work
- how log analysis is performed using CLI tools
- how to write modular and reusable bash scripts
- how to manage Linux users and permissions
- how to troubleshoot SSH and server connectivity issues

---

# Real-World Relevance

These scripts simulate operational tasks commonly performed by:

- DevOps Engineers
- Linux System Administrators
- Site Reliability Engineers (SREs)
- Cloud Engineers

The project focuses on practical automation rather than theoretical examples.

---

# Future Improvements

Planned improvements include:

- email alerts
- Slack/Discord notifications
- centralized logging
- monitoring dashboards
- AWS S3 backup integration
- Docker container monitoring
- Terraform deployment integration

---

# Author

Tanay Jain

Built as part of a long-term Cloud & DevOps Engineering learning roadmap.

---

# License

This project is licensed under the MIT License.
```
