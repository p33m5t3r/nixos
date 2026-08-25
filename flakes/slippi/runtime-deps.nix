# Runtime libraries needed inside the FHS sandbox.
#
# These are mostly for the *Slippi Dolphin* AppImage that the launcher
# downloads at runtime -- it inherits this environment from its parent, so its
# dependencies have to be satisfied here rather than in its own derivation.
pkgs: with pkgs; [
  # input: GameCube adapter (libusb), controllers (SDL/evdev)
  libusb1
  libevdev
  udev
  SDL2

  # audio
  alsa-lib
  libpulseaudio

  # graphics
  libglvnd
  mesa
  vulkan-loader
  libdrm

  # display servers
  wayland
  libxkbcommon
  libx11
  libxext
  libxrandr
  libxinerama
  libxcursor
  libxi
  libxfixes
  libxrender
  libxcb
  libxscrnsaver

  # Dolphin misc runtime
  bluez
  curl
  openssl
  zlib
  zstd
  lzo
  libpng
  hidapi
  miniupnpc
  fontconfig
  freetype
]
