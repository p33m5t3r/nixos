# slippi

Melee netplay (Slippi) + GameCube adapter support, as a self-contained flake.

Nothing here touches the system config. The one exception is the adapter,
which genuinely cannot work from user space -- see **Adapter** below.

## Run it

```sh
nix run ~/nixos/flakes/slippi   # or the `slippi` alias
```

You still need to point the launcher at your own Melee ISO (Settings ->
Melee ISO). Not shipped here, for obvious reasons.

There is a `slippi` shell alias for this. To get it in `$PATH` and your app
launcher instead, note that `slippi-launcher.nix` is a plain callPackage
derivation, so the system config can use it directly -- no flake input, no
lock churn:

```nix
# e.g. in modules/games/default.nix
environment.systemPackages = [
  (pkgs.callPackage ../../../flakes/slippi/slippi-launcher.nix { })
];
```

## Adapter

Two things here cannot live in a user flake: **udev rules** are read by the
system udev daemon, and the **kernel module** must be built against the
running kernel. A flake also evaluates in *pure* mode, so it cannot reach an
absolute path outside its own source tree -- only relative paths within this
repo work.

So the adapter half lives in the system modules tree:

    ~/nixos/nixos/modules/gamecube-adapter/default.nix

wired up as

```nix
# desktop.nix
imports = [ ./modules/gamecube-adapter ];

# modules/games/default.nix
hardware.gamecube-adapter.enable = true;
```

If you edit that module, remember `git add` it -- Nix cannot see files in a
git repo that are untracked.

That gets you:

- a udev rule tagging the adapter `uaccess`, so Dolphin can reach it over
  libusb as your normal user instead of only as root
- `gcadapter_oc`, which raises the adapter's polling rate from its stock
  8 ms (125 Hz) to 1 ms (**1000 Hz**) -- the polling-rate fix Melee players want

The overclock is on by default. To change or disable it:

```nix
hardware.gamecube-adapter.overclock.rate = 2;      # 500 Hz
hardware.gamecube-adapter.overclock.enable = false;
```

The adapter must be in **Wii U mode** (the switch on the adapter), not PC
mode. In Dolphin: Controllers -> Port 1 -> *Standard Controller* -> Configure,
or use the GameCube Adapter passthrough option.

### Verify

The module is loaded at boot, so **a rebuild alone is not enough -- reboot.**
Until then `modprobe` searches the *booted* generation's module tree, which
does not contain `gcadapter_oc` yet, and you get
`Failed to find module 'gcadapter_oc'` in `systemd-modules-load`.

After rebooting, with the adapter plugged in:

```sh
lsmod | grep gcadapter_oc                     # module live
cat /sys/module/gcadapter_oc/parameters/rate  # -> 1
```

The real proof is the USB endpoint interval, since that is what actually
governs polling. Find the adapter and read its endpoints:

```sh
grep -l 0337 /sys/bus/usb/devices/*/idProduct   # -> e.g. /sys/bus/usb/devices/3-2.2/
cat /sys/bus/usb/devices/3-2.2/*/ep_*/bInterval
```

- `08` = 8 ms = **125 Hz**, the stock rate (module not in effect)
- `01` = 1 ms = **1000 Hz**, what you want

`bInterval` is latched when the device is configured, so if the adapter was
already plugged in when the module loaded, **unplug and replug it** before
trusting this reading.

## How it works

The launcher ships only as an AppImage, and it is not in nixpkgs (the
community `ssbm-nix` flake is archived as of 2024). So `slippi-launcher.nix`
wraps the official AppImage with `appimageTools.wrapType2`.

The subtlety: the launcher *downloads a second AppImage at runtime* -- Slippi
Dolphin itself, into `~/.config/Slippi Launcher/{netplay,playback}`. That
child process inherits the FHS sandbox from its parent, which means:

- Dolphin's shared libraries must be listed in `runtime-deps.nix`, not just
  the launcher's own Electron dependencies
- `APPIMAGE_EXTRACT_AND_RUN=1` is set on the wrapper, so the child AppImage
  unpacks itself rather than demanding a FUSE mount, which isn't available
  inside the sandbox

`nix run ~/nixos/flakes/slippi#fhs-shell` drops you into that same sandbox
for debugging.

## Updating

When a new launcher release lands, bump `version` in `slippi-launcher.nix`
and refresh the hash:

```sh
nix-prefetch-url --type sha256 \
  https://github.com/project-slippi/slippi-launcher/releases/download/vX.Y.Z/Slippi-Launcher-X.Y.Z-x86_64.AppImage
nix hash convert --hash-algo sha256 --to sri <output>
```

Dolphin itself self-updates through the launcher, so it needs no bump here.

## Known quirks

The launcher logs a `org.freedesktop.portal.Desktop` activation error on
startup. This is pre-existing on this host (the portal service is dead
outside the sandbox too) and is harmless here -- Electron falls back to the
GTK file chooser, which is present in the sandbox, so the "Melee ISO" picker
still works.
