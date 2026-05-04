# gitshift

gitshift is a lightweight CLI for switching Git identities per repository.

It lets you save multiple Git profiles, such as work and personal identities, then apply one to the current repository using local Git config. gitshift can also show the active Git identity before running `git status`.

## Features

- Save multiple Git identity profiles
- Switch `user.name` and `user.email` for the current repository
- Store identity per repository using `git config --local`
- Show current repository identity
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

Add a profile:

Avoid special characters in profile names, names, and emails, as they may break gitshift's profile lookup.

```bash
# gitshift add <profile> <name> <email>

gitshift add work "Your Name" "you@company.com"
gitshift add personal "Your Name" "you@example.com"
```

List saved profiles:

```bash
gitshift list
```

Apply a profile to the current Git repository:

```bash
gitshift use work
```

Show the current repository identity:

```bash
gitshift who
```

Show help:

```bash
gitshift help
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
gsh add work "Your Name" "you@company.com"
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
```

Saved profiles:

```text
~/.gitshift/profiles
```

Profile format:

```text
profile|name|email
```

Example:

```text
work|Alice|alice@company.com
personal|Bob|bob@example.com
```

## How It Works

`gitshift add` saves a profile to `~/.gitshift/profiles`.

`gitshift use <profile>` writes the selected identity to the current repository:

```bash
git config --local user.name "Your Name"
git config --local user.email "you@example.com"
```

Because gitshift uses `--local`, it only changes the current repository and does not modify your global Git config.

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