# Migrations

One-time fixes that `lazytam update` runs on existing installs, for changes that
a plain `git pull` can't apply (moving a user file, renaming a config key, ...).

- Name them `YYYYMMDDHHMM-short-description.sh`; they run in name order.
- Each runs once per machine; applied names are kept in `~/.local/state/lazytam/migrations.done`.
- Fresh installs mark every existing migration as done, so write them for old installs only.
- They run with `bash`, as your user. Use `sudo` for system files.
