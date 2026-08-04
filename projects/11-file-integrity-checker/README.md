# File Integrity Checker

The File Integrity Checker is a Bash-based command-line utility that helps detect unauthorized changes to log files by using SHA-256 hashing. It creates a baseline of file hashes and compares the current state of files against the stored hashes to identify possible tampering.

The tool supports initializing a hash database, checking file integrity, and manually updating stored hashes after trusted changes.

---

## Goal

The goal of this project is to practice Linux administration and Bash scripting by building a simple file integrity monitoring tool.

During this project, the following concepts are explored:

- Bash scripting
- Functions and local variables
- File and directory handling
- SHA-256 hashing
- Reading structured files with `read` and `IFS`
- Temporary file handling with `mktemp`
- Error handling and exit codes
- Command-line argument processing

---

## Requirements

The tool provides the following functionality:

- Accepts a single log file or a directory as input during initialization.
- Computes SHA-256 hashes for log files.
- Stores hashes in a local integrity database.
- Compares current file hashes against previously stored hashes.
- Reports modified and unmodified files.
- Allows manual updating of stored hashes after trusted file changes.
- Displays appropriate error messages for invalid paths or missing databases.

---

## Usage

### Make the script executable

```bash
chmod +x integrity-check
```

### Initialize the integrity database

Initialize a single file:

```bash
sudo ./integrity-check init /var/log/syslog
```

Initialize all regular files in a directory:

```bash
sudo ./integrity-check init /var/log
```

---

### Check file integrity

```bash
sudo ./integrity-check check /var/log/syslog
```

Example output:

```text
Status: Unmodified
```

or

```text
Status: Modified (Hash mismatch)
```

---

### Update a stored hash

After making trusted changes to a file, update its stored hash:

```bash
sudo ./integrity-check update /var/log/syslog
```

Example output:

```text
Hash updated successfully.
```

---

## Hash Database

The integrity database is stored at:

```text
/var/lib/integrity-check/hashes.db
```

Each entry is stored in the following format:

```text
/absolute/path/to/file|sha256_hash
```

---

## Example Workflow

```bash
sudo ./integrity-check init /var/log

sudo ./integrity-check check /var/log/syslog

sudo ./integrity-check update /var/log/syslog
```

---

## Outcome

This project demonstrates how cryptographic hashing can be used to verify file integrity and detect potential tampering. It also provides hands-on experience with building a practical Linux command-line utility using Bash while following common scripting and system administration practices.

---

## Link

[roadmap.sh](https://roadmap.sh/projects/file-integrity-checker)
