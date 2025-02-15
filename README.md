

1. symlink /etc/nixos:
`sudo ln -s nixos /etc/nixos`

2. symlink flakes
`sudo ln -s flakes ~/flakes`

3. symlink nvim config (bc it changes often, dont let homemanager touch it)
`ln -s ~/nixos/.config/nvim/init.lua ~/.config/nvim/init.lua`


## notes
for the system-wide rust flake, you have to run rustup to actually install rustc
you may also want to run:
`rustup component add rust-analyser`
`rustup component add rust-src`
