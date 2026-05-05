# gitshift

gitshift is a lightweight CLI for switching Git identities and GitHub SSH hosts per repository.

It helps you manage multiple Git profiles, configure SSH host aliases, and clone GitHub repositories with the matching SSH identity.

## Features

- Save multiple Git identity profiles
- Switch `user.name` and `user.email` for the current repository
- Store identity per repository using `git config --local`
- Optionally bind profiles to GitHub owners and SSH hosts
- Generate SSH keys and write `~/.ssh/config` entries
- Clone GitHub repositories using the matching SSH host
- Hook into `git status` to display active Git identity first

## Install

Run the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/void-wizard/gitshift/main/install.sh | bash
```

Then activate gitshift in your current shell:

```bash
source ~/.zshrc
```

If you use Bash:

```bash
source ~/.bashrc
```

## Usage

Initialize gitshift:

```bash
gitshift init
```

Add a profile interactively:

```bash
gitshift add
```

gitshift will ask for:

```text
Profile name
Git user.name
Git user.email
GitHub owner/account
SSH configuration
```

Avoid special characters in profile names, names, emails, and GitHub owners, as they may break gitshift's profile lookup.

List saved profiles:

```bash
gitshift list
```

Apply a profile to the current Git repository:

```bash
gitshift use work
```

Clone a GitHub repository with the matching SSH host:

```bash
gitshift clone owner/repo
gitshift clone git@github.com:owner/repo.git
gitshift clone https://github.com/owner/repo.git
```

Remove a profile:

```bash
gitshift remove work
```

Remove all profiles:

```bash
gitshift remove --all
```

Show the current repository identity:

```bash
gitshift who
```

Show help:

```bash
gitshift help
```

## SSH Profiles

When adding a profile, gitshift can use an existing SSH host from `~/.ssh/config`:

```sshconfig
Host github-work
  User git
  HostName github.com
  IdentityFile ~/.ssh/id_ed25519_work
```

Or it can generate a new SSH key and write an SSH config entry:

```sshconfig
# >>> gitshift work >>>
Host github-work
  HostName github.com
  User git
  IdentityFile /Users/you/.ssh/id_ed25519_gitshift_work
  IdentitiesOnly yes
# <<< gitshift work <<<
```

After generating a key, gitshift prints the public key so you can add it to GitHub:

```text
Settings -> SSH and GPG keys -> New SSH key
```

## Git Status Hook

After installation, gitshift adds a shell hook for `git status`.

When you run:

```bash
git status
```

gitshift prints the current repository Git identity first, then runs the normal Git status command.

Example:

```text
Git repository: /path/to/repo
Git user.name: Your Name
Git user.email: you@company.com

On branch main
...
```

## Alias

If you want a shorter command, you can create a shell alias.

For zsh:

```bash
printf '\n%s\n' "alias gsh='gitshift'" >> ~/.zshrc
source ~/.zshrc
```

For bash:

```bash
printf '\n%s\n' "alias gsh='gitshift'" >> ~/.bashrc
source ~/.bashrc
```

After that, you can use:

```bash
gsh add
gsh clone company/repo
gsh use work
gsh who
```

You can choose any short alias that fits your workflow, as long as it does not conflict with commands already installed on your system.

## Where Data Is Stored

gitshift stores its files in:

```text
~/.gitshift
```

Installed files:

```text
~/.gitshift/bin/gitshift
~/.gitshift/bin/help.txt
~/.gitshift/bin/shell-hook.sh
~/.gitshift/bin/lib/
```

Saved profiles:

```text
~/.gitshift/profiles
```

Profile format:

```text
profile|name|email|github_owner|ssh_host
```

Example:

```text
work|Alice|alice@company.com|company|github-work
personal|Bob|bob@example.com|bob|github-personal
```

## How It Works

`gitshift add` saves a profile to `~/.gitshift/profiles`.

`gitshift use <profile>` writes the selected identity to the current repository:

```bash
git config --local user.name "Your Name"
git config --local user.email "you@example.com"
```

Because gitshift uses `--local`, it only changes the current repository and does not modify your global Git config.

`gitshift clone <repo>` parses the GitHub owner from the repository URL, finds the profile whose GitHub owner matches it, and clones through that profile's SSH host.

For example, this profile:

```text
work|Alice|alice@company.com|company|github-work
```

makes this command:

```bash
gitshift clone company/project
```

run:

```bash
git clone git@github-work:company/project.git
```

## Uninstall

Remove gitshift files:

```bash
rm -rf ~/.gitshift
```

Then remove the gitshift blocks from your shell config file, such as `~/.zshrc` or `~/.bashrc`:

```bash
# >>> gitshift path >>>
export PATH="$HOME/.gitshift/bin:$PATH"
# <<< gitshift path <<<
```

```bash
# >>> gitshift git hook >>>
...
# <<< gitshift git hook <<<
```

Reload your shell:

```bash
source ~/.zshrc
```