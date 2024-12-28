# Noah's Dotfiles

This repo stores my dotfiles using GNU stow.

## Adding things to the repo
1. Make a top-level directory in this repo for the new entry, and then subdirectories that match the system location from $HOME.
2. Copy existing files to this new directory.
3. Run `stow foo --target="$HOME" --adopt` to link the files from the repo.

For example, in this repo, `./ssh/.ssh/` can hold the SSH `config` file, and then `stow ssh --target="$HOME"` will link it (and every other file under `./ssh/`) to the correct spot in your home directory (`~/.ssh/config`). This approach lets you group files related to the same feature, even though they might actually live in different parts of the filesystem.

Only add the specific files you need! For example, you can include `.gitconfig` while having a separate local config file which is included by the managed copy. Or, only include Zed's `~/.config/zed/settings.json` file, and not the other directories that Zed might create at runtime.

File organization is up to you. `stow` simply takes an input directory and a target directory, and symlinks everything in the input to the same location (e.g. same as the input directory tree) in the target directory. So if you make `./foo/.config/test/xyz/thing.json` and run `stow foo --target=$HOME`, then `thing.json` will get symlinked to `~/.config/test/xyz/thing.json`, and updates in to the file from either place will always stay in sync. Then you can simply use git to push/pull to update with other machines.

## Update brew programs:
* Update the list of programs you have installed by running `brew bundle dump` in this directory. It's worth removing some of the entries you might not want installed on all your computers.
* To check if you have all programs installed, run `brew bundle check`.
* To install missing programs, run `brew bundle install`

## TODO:

- [ ] Mac settings:
  * [ ] Always show hidden files
  * [ ] Three-finger drag
  * [ ] Ctrl-command to move window from anywhere
  * [ ] Default applications??
- [ ] Mac vs Linux options
- [ ] Other programs and keyboard shortcuts (e.g. Shottr replacing native screenshot shortcut)
