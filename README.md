# Noah's Dotfiles

This repo stores my dotfiles using GNU stow.

## Adding things to the repo
1. Make a top-level directory in this repo for the new entry, and then subdirectories that match the system location from $HOME.
2. Copy existing files to this new directory.
3. Run `stow foo --target="$HOME" --adopt` to link the files from the repo.

For example,`./ssh/.ssh/` can hold the SSH `config` file, and then `stow ssh --target="$HOME"` will link it (and every other file under `./ssh/`) to the correct spot in your home directory (~/.ssh/config). This approach lets you group files related to the same feature, even though they might actually live in different parts of the filesystem.

## Update brew packages and applications:
* Update the list programs to install by running `brew bundle dump` in this directory.
* To check if you have all programs installed, run `brew bundle check`.
* To install missing programs, run `brew bundle install`
