# gitshift

A lightweight Bash CLI for switching Git identities and GitHub SSH hosts per repository.

gitshift helps you avoid committing with the wrong `user.name`, `user.email`, or SSH key when you work with multiple GitHub accounts.

Website: https://void-wizard.github.io/gitshift/

## 1. What gitshift does

gitshift lets you:

- Save multiple Git identity profiles
- Apply a profile to the current repository
- Store repository identity with `git config --local`
- Bind profiles to GitHub owners and SSH host aliases
- Clone GitHub repositories with the matching SSH identity
- Show the active Git identity before `git status`

## 2. Supported platforms

gitshift is designed for:

- macOS
- Linux
- Windows through WSL

Native PowerShell or CMD on Windows is not currently supported.

## 3. Install

Run the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/void-wizard/gitshift/main/install.sh | bash
```

Then reload your shell config.

For zsh:

```bash
source ~/.zshrc
```

For Bash:

```bash
source ~/.bashrc
```

After installation, check that the command is available:

```bash
gitshift help
```

## 4. Quick start

### 4.1 Initialize gitshift

Run this once to prepare gitshift storage:

```bash
gitshift init
```

Result:

```text
gitshift configuration is ready: ~/.gitshift
Profile file: ~/.gitshift/profiles
```

### 4.2 Add a profile

Create a Git identity profile interactively:

```bash
gitshift add
```

gitshift will ask for these fields:

```text
Profile name
Git user.name
Git user.email
GitHub owner/account
SSH configuration
```

Example values:

```text
Profile name: work
Git user.name: Alice
Git user.email: alice@company.com
GitHub owner/account: company
SSH host: github-work
```

The profile name is the value you use later in commands such as:

```bash
gitshift use work
```

Avoid special characters in profile names, names, emails, and GitHub owners, because they may break profile lookup.

### 4.3 List saved profiles

Show all profiles saved on this machine:

```bash
gitshift list
```

Example:

```text
work|Alice|alice@company.com|company|github-work
personal|Alice|alice@example.com|alice|github-personal
```

### 4.4 Apply a profile to the current repository

Go into a Git repository:

```bash
cd path/to/your/repo
```

Apply a profile:

```bash
gitshift use work
```

Here, `work` is the profile name you entered when running `gitshift add`.

Result:

```text
Git user.name and Git user.email are written to this repository's local Git config.
Other repositories keep their own identities.
Your global Git config is not changed.
```

### 4.5 Show the active repository identity

Run:

```bash
gitshift who
```

Result:

```text
Git repository: /path/to/repo
Git user.name: Alice
Git user.email: alice@company.com
```

## 5. Clone repositories

gitshift can clone GitHub repositories with the matching SSH host.

Supported formats:

```bash
gitshift clone owner/repo
gitshift clone git@github.com:owner/repo.git
gitshift clone https://github.com/owner/repo.git
```

Example:

```bash
gitshift clone company/project
```

If you have a profile like this:

```text
work|Alice|alice@company.com|company|github-work
```

gitshift will clone through the matching SSH host:

```bash
git clone git@github-work:company/project.git
```

This is useful when different GitHub accounts use different SSH keys.

## 6. Manage profiles

### 6.1 Remove one profile

```bash
gitshift remove work
```

Result:

```text
The work profile is removed from gitshift storage.
```

### 6.2 Remove all profiles

```bash
gitshift remove --all
```

Result:

```text
All saved profiles are removed.
```

### 6.3 Show help

```bash
gitshift help
```

## 7. SSH profiles

When adding a profile, gitshift can use an existing SSH host from `~/.ssh/config`.

Example:

```sshconfig
Host github-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
  IdentitiesOnly yes
```

gitshift can also generate a new SSH key and write an SSH config entry.

Example:

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
GitHub -> Settings -> SSH and GPG keys -> New SSH key
```

## 8. Git status hook

After installation, gitshift adds a shell hook for `git status`.

When you run:

```bash
git status
```

gitshift prints the current repository Git identity first, then runs the normal Git status command.

Example:

```text
Git repository: /path/to/repo
Git user.name: Alice
Git user.email: alice@company.com

On branch main
nothing to commit, working tree clean
```

This helps catch identity mistakes before you commit.

## 9. Alias

If you want a shorter command, you can create an alias.

For zsh:

```bash
printf '\n%s\n' "alias gsh='gitshift'" >> ~/.zshrc
source ~/.zshrc
```

For Bash:

```bash
printf '\n%s\n' "alias gsh='gitshift'" >> ~/.bashrc
source ~/.bashrc
```

Then you can use:

```bash
gsh add
gsh list
gsh use work
gsh clone company/project
gsh who
```

Choose an alias that does not conflict with commands already installed on your system.

## 10. Where data is stored

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
personal|Alice|alice@example.com|alice|github-personal
```

## 11. How it works

### 11.1 Adding a profile

`gitshift add` saves a profile to:

```text
~/.gitshift/profiles
```

### 11.2 Applying a profile

`gitshift use <profile>` writes the selected identity to the current repository:

```bash
git config --local user.name "Your Name"
git config --local user.email "you@example.com"
```

Because gitshift uses local Git config, it only changes the current repository.

It does not change your global Git identity.

### 11.3 Cloning a repository

`gitshift clone <repo>` parses the GitHub owner from the repository URL.

Then it finds the profile whose GitHub owner matches that owner.

For example, this profile:

```text
work|Alice|alice@company.com|company|github-work
```

makes this command:

```bash
gitshift clone company/project
```

run through this SSH host:

```bash
git clone git@github-work:company/project.git
```

## 12. Uninstall

Remove gitshift files:

```bash
rm -rf ~/.gitshift
```

Then remove the gitshift blocks from your shell config file.

For zsh, edit:

```text
~/.zshrc
```

For Bash, edit:

```text
~/.bashrc
```

Remove this block:

```bash
# >>> gitshift path >>>
export PATH="$HOME/.gitshift/bin:$PATH"
# <<< gitshift path <<<
```

Also remove the git status hook block:

```bash
# >>> gitshift git hook >>>
...
# <<< gitshift git hook <<<
```

Reload your shell.

For zsh:

```bash
source ~/.zshrc
```

For Bash:

```bash
source ~/.bashrc
```
