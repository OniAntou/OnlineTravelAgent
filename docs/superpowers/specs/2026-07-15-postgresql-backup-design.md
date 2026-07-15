# PostgreSQL Backup Design

> **Status (2026-07-15): Superseded.** The user chose a one-off, manually
> verified backup and explicitly declined scheduled automation. No backup
> script or Windows Scheduled Task is to be implemented from this design.

## Goal

Protect the local `online_travel_agent` PostgreSQL database from accidental
deletion or corruption by creating a verified, restorable backup every day.

## Scope

- Create a PowerShell backup command that reads the existing backend `.env`.
- Create a Windows Scheduled Task named `OnlineTravelAgent PostgreSQL Backup`.
- Store verified backups in `D:\OnlineTravelAgentBackups` and retain 14 days.
- Provide an optional mirror directory for a second disk, external drive, or
  synced folder.
- Document manual backup, task installation, verification, and restore.

This first delivery does not configure a cloud provider, automatically restore
data, or copy PostgreSQL's physical data directory. The local destination
protects against logical data loss; it does not protect against loss of the
entire `D:` drive. An off-device mirror remains the next hardening step.

## Current Environment

- PostgreSQL 18.4 is running as `postgresql-x64-18` from
  `D:\PostgreSQL\18\bin`.
- The backend uses `DATABASE_URL` in `backend/.env` and Prisma with PostgreSQL.
- Matching `pg_dump.exe` and `pg_restore.exe` are available under
  `D:\PostgreSQL\18\bin`.
- No backup task or backup directory currently exists.

## Architecture

```text
Windows Scheduled Task (02:30 daily)
  -> backend/scripts/backup-postgres.ps1
      -> read backend/.env
      -> pg_dump custom-format file (.partial)
      -> pg_restore --list integrity check
      -> SHA-256 checksum
      -> atomically publish .dump
      -> retention cleanup
      -> optional mirror copy
      -> timestamped log
```

### Backup Command

`backend/scripts/backup-postgres.ps1` owns one backup run. It will:

1. Load `DATABASE_URL` and backup settings without printing credentials.
2. Resolve `pg_dump` and `pg_restore` from explicit configuration, the
   PostgreSQL 18 installation, or `PATH`; fail with a clear error if either is
   unavailable.
3. Use PostgreSQL connection arguments and a temporary `PGPASSWORD`
   environment variable rather than placing the complete connection URL in the
   process command line.
4. Write a custom-format dump to a `.partial` file under the configured backup
   directory. Custom format supports selective, controlled restore through
   `pg_restore`.
5. Run `pg_restore --list` against the temporary dump. Only a passing result
   is published as a final `.dump` file.
6. Write a SHA-256 checksum next to each final dump, clean up backups and
   checksums older than the retention period, and return a non-zero exit code
   on any failure.
7. If `BACKUP_MIRROR_DIRECTORY` is configured, copy only the verified dump and
   checksum there. A mirror-copy error makes the run fail visibly while
   preserving the verified local backup.

Backup and error logs live beneath the backup directory. They contain file
names, timestamps, sizes, and error summaries only; no database password or
connection string is logged.

### Configuration

The existing `DATABASE_URL` remains the source of database connection details.
The following optional settings will be documented in `backend/.env.example`:

| Variable | Default | Purpose |
| --- | --- | --- |
| `BACKUP_DIRECTORY` | `D:\OnlineTravelAgentBackups` | Local directory for dumps and logs. |
| `BACKUP_RETENTION_DAYS` | `14` | Number of whole days to retain a verified backup. |
| `PG_DUMP_PATH` | auto-resolved | Explicit path to `pg_dump.exe` when PostgreSQL is installed elsewhere. |
| `PG_RESTORE_PATH` | auto-resolved | Explicit path to `pg_restore.exe` when PostgreSQL is installed elsewhere. |
| `BACKUP_MIRROR_DIRECTORY` | unset | Optional independent copy destination. |

The backup directory stays outside the repository so backup contents cannot be
accidentally committed.

### Scheduling

`backend/scripts/install-postgres-backup-task.ps1` will register or update a
single task with the approved name. It runs daily at 02:30 local time as the
Windows `SYSTEM` account with highest available privileges, calls the backup
script using `powershell.exe -NoProfile`, and writes output to the backup log
directory. The installer is idempotent: rerunning it updates the existing task
instead of creating duplicates.

The production backup script is always runnable manually through an npm command
before the task is installed. Task installation never performs a database
restore or changes database contents.

## Restore Procedure

The operations guide will require an explicit target database and confirmation
before any destructive restore. Its standard command will use `pg_restore`
with `--clean`, `--if-exists`, and `--no-owner` only after the operator has
selected a verified `.dump` and has taken a fresh safety backup. No script will
automatically run this command.

## Error Handling

- A missing `.env`, invalid `DATABASE_URL`, missing PostgreSQL tool, unwritable
  destination, failed dump, failed integrity check, or invalid retention value
  terminates the run with a non-zero exit code.
- Failed partial dumps are never published as successful backups.
- Retention cleanup is limited to the configured backup directory and only
  recognizes this feature's dump and checksum naming pattern.
- A failure leaves previous verified backups untouched and is visible in the
  task result and log file.

## Verification

1. Run `npm run db:backup` from `backend/` against the live local PostgreSQL
   service.
2. Confirm that one `.dump`, one `.sha256`, and a success log exist under
   `D:\OnlineTravelAgentBackups`.
3. Run `pg_restore --list` on the new dump and verify its SHA-256 checksum.
4. Register the scheduled task, inspect its next run time and action, and
   trigger one controlled task run to confirm it produces another verified
   backup.
5. Exercise retention with test files or an override, confirming that only
   expired files matching the backup naming convention are removed.

## Alternatives Considered

- **Copying `D:\PostgreSQL\18\data`: rejected.** PostgreSQL data files cannot
  be safely copied while the server is running without a coordinated physical
  backup process.
- **Cloud-only backup: deferred.** It would improve disaster recovery but
  needs a user-owned destination and credentials; the local verified backup is
  useful immediately.
- **Local backup plus optional mirror: selected.** It gives immediate recovery
  from accidental deletion while allowing a separate disk or synced folder to
  serve as the durable off-device copy when it is configured.

## Acceptance Criteria

- A manual command creates a restorable, verified PostgreSQL dump without
  exposing credentials.
- The daily scheduled task exists exactly once and has a visible success or
  failure result.
- Exactly 14 days of matching local backups are retained by default.
- Operators have a tested, explicit restore guide and can configure a mirror
  without changing source code.
