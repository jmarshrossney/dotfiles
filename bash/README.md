# Shell Configuration

My *very simple* shell configuration.

Currently Bash only.

First, back up your current config files:

```sh
mkdir shell_config_backup
mv ~/.bashrc ~/.bash_profile ~/.inputrc shell_config_backup/
```

Then clone this repo and symlink the config files to your home directory:

```sh
git clone https://codeberg.org/float/shell-config.git
ln -s shell-config/bashrc ~/.bashrc
ln -s shell-config/bash_profile ~/.bash_profile
ln -s shell-config/inputrc ~/.inputrc
```

## Notes

- I needed to uncomment the shell completions block in `/etc/bash.bashrc` to get completions in an interactive shell.
