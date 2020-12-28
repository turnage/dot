{ config, pkgs, options, ... }:

let
    home-manager = builtins.fetchGit {
      url = "https://github.com/nix-community/home-manager.git";
      ref = "release-20.09";
    };
    old = import
      (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-18.09)
      # reuse the current configuration
      { config = config.nixpkgs.config; };
in {
  imports =
    [ 
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  nixpkgs.config.allowUnfree = true;
  nix.nixPath = options.nix.nixPath.default ++ [
    "nixpkgs-overlays=/etc/nixos/overlays"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  networking.hostName = "samizdat"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "America/Denver";

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;


  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.nvidiaWayland = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.video.hidpi.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  services.xserver.layout = "us";
  services.xserver.xkbVariant = "colemak";
  services.xserver.xkbOptions = "ctrl:nocaps";

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.libinput.enable = true;

  users.users.turnage = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    wget
    (import ./vim.nix)
    git
    networkmanager
    networkmanager_openvpn
    openvpn
    networkmanagerapplet
    firefox
    pkg-config
    fish
    ssh-ident
    openssh
    tmux
    bzip2
    unzip
    jq
    curl

    gnome3.file-roller
    gnome3.evince
    gnome3.gnome-tweak-tool
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnome3.dconf
    gnome3.dconf-editor
    gtk3
    geeqie
    gimp-with-plugins
    inotify-tools
    xorg.xf86inputlibinput

    deluge
    vlc
    slack
    typora

    ps
    ripgrep
    exa

    stack
    rustup
    cmake
    valgrind
    python3
    stylish-haskell
    old.haskellPackages.hindent
    haskellPackages.cabal-install
    ghc
  ];

  environment = {
    etc = {
      "X11/xorg.conf.d/10-libinput.conf".text = ''
        Section "InputClass"
          Identifier   "Marble Mouse"
          MatchProduct "Logitech USB Trackball"
          Driver       "libinput"
          Option       "ScrollMethod"    "button"
          Option       "ScrollButton"    "8"
          Option       "MiddleEmulation" "true"
        EndSection
      '';
    };
  };

  home-manager.users.turnage = {
    programs.git = {
      enable = true;
      userName = "Payton Turnage";
      userEmail = "paytonturnage@gmail.com";
      extraConfig = {
        core = {
          editor = "vim";
        };
      };
    };

    home.file.".stack/config.yaml".source = ./dotfiles/stack/config.yaml;
    home.file.".bashrc".source = ./dotfiles/bashrc;
  };

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8100 22 80 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}

