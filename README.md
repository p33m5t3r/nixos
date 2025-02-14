

1. symlink /etc/nixos:
`sudo ln -s nixos /etc/nixos`

2. symlink flakes
`sudo ln -s flakes ~/flakes`

3. symlink nvim config (bc it changes often, dont let homemanager touch it)
`ln -s ~/nixos/.config/nvim/init.lua ~/.config/nvim/init.lua`
