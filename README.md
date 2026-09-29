### layout
- `nixos/` - the flake. `shared.nix` + one file per host (`desktop.nix`, `laptop.nix`) + `hardware/hardware-configuration-<host>.nix`
- `.config/`, `.tmux.conf` - dotfiles, symlinked into `$HOME` by `./link.sh`
- rebuild on an installed machine: `rebuild` (zsh alias)

### fresh install
from the nixos installer iso, as root (`sudo -i`). disk is probably `/dev/nvme0n1`, check with `lsblk`.

1. **wifi**: graphical iso → `nmtui`. minimal iso → `wpa_cli` (`add_network`, `set_network 0 ssid "..."`, `set_network 0 psk "..."`, `enable_network 0`)

2. **partition**: 1G boot, 32G luks swap, rest luks btrfs with `@` (/) and `@home` subvolumes.
   use the **same passphrase** for both luks prompts so boot only asks once.
   ```
   parted /dev/nvme0n1 -- mklabel gpt
   parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 1GB
   parted /dev/nvme0n1 -- set 1 esp on
   parted /dev/nvme0n1 -- mkpart swap 1GB 33GB
   parted /dev/nvme0n1 -- mkpart root 33GB 100%
   mkfs.fat -F 32 -n boot /dev/nvme0n1p1

   cryptsetup luksFormat /dev/nvme0n1p2
   cryptsetup open /dev/nvme0n1p2 cryptswap
   mkswap -L swap /dev/mapper/cryptswap
   swapon /dev/mapper/cryptswap

   cryptsetup luksFormat /dev/nvme0n1p3
   cryptsetup open /dev/nvme0n1p3 cryptroot
   mkfs.btrfs -L nixos /dev/mapper/cryptroot
   mount /dev/mapper/cryptroot /mnt
   btrfs subvolume create /mnt/@
   btrfs subvolume create /mnt/@home
   umount /mnt
   mount -o subvol=@ /dev/mapper/cryptroot /mnt
   mkdir -p /mnt/home /mnt/boot
   mount -o subvol=@home /dev/mapper/cryptroot /mnt/home
   mount -o umask=077 /dev/nvme0n1p1 /mnt/boot

   nixos-generate-config --root /mnt
   ```
   sanity check `/mnt/etc/nixos/hardware-configuration.nix`: two `boot.initrd.luks.devices` entries,
   `subvol=@` / `subvol=@home` in the fileSystems options, and a `swapDevices` entry.
   note the `system.stateVersion` in `/mnt/etc/nixos/configuration.nix`, you need it in step 5.

3. **get the ssh key over** (installed systems don't allow password ssh, the installer does)
   - on the new machine: `passwd nixos && systemctl start sshd && mkdir -p /home/nixos/.ssh && ip a`
   - on an old machine: `scp ~/.ssh/id_ed25519* nixos@<ip>:.ssh/`
   - back on the new machine, as the `nixos` user (not root): `chmod 600 ~/.ssh/id_ed25519`

4. **clone** (as `nixos` user)
   ```
   nix-shell -p git
   sudo mkdir -p /mnt/home/anon && sudo chown nixos /mnt/home/anon
   git clone git@github.com:p33m5t3r/nixos.git /mnt/home/anon/nixos
   ```

5. **add the host** (skip if reinstalling an existing host, just replace its hardware file)
   - `cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/anon/nixos/nixos/hardware/hardware-configuration-<host>.nix`
   - `cp laptop.nix <host>.nix`, then edit: `hostName`, drop the `nvda` import, `rebuild` alias → `#<host>`, `stateVersion` → value from step 2
   - add `boot.resumeDevice = "/dev/mapper/cryptswap";` (hibernate)
   - in `flake.nix`, copy the `laptop` block, rename to `<host>`, point at the new files
   - **`git add -A`** - flakes can't see untracked files

6. **install** (as root)
   ```
   nixos-install --flake /mnt/home/anon/nixos/nixos#<host>
   nixos-enter --root /mnt -c 'passwd anon'
   mkdir -p /mnt/home/anon/.ssh && cp /home/nixos/.ssh/id_ed25519* /mnt/home/anon/.ssh/
   chown -R 1000:100 /mnt/home/anon && chmod 700 /mnt/home/anon/.ssh
   reboot
   ```

7. **after first boot**, as anon: `~/nixos/link.sh`, then commit + push the new host.

