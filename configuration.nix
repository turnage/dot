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

  nixpkgs.config = {
    allowBroken = false;
    allowUnsupportedSystem = false;
  };
  nixpkgs.config.allowUnfree = true;  

  virtualisation.docker.enable = true;  

  nix = (import ./nix.nix);

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "samizdat"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "America/Vancouver";

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
  #services.xserver.displayManager.gdm.nvidiaWayland = true;
  services.xserver.displayManager.gdm.wayland = true;
  #hardware.nvidia.modesetting.enable = true;
  hardware.video.hidpi.enable = true;
  #services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  services.xserver.layout = "us";
  services.xserver.xkbVariant = "colemak";
  services.xserver.xkbOptions = "ctrl:nocaps";

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.libinput = {
    enable = true;
    additionalOptions = ''
        Identifier   "Marble Mouse"
        MatchProduct "Logitech USB Trackball"
        Driver       "libinput"
        Option       "ScrollMethod"    "button"
        Option       "ScrollButton"    "8"
        Option       "MiddleEmulation" "true"
    '';
  };

  services.openvpn.servers = {
    pritunl = (import ./pritunl.nix);
  };

  users.users.turnage = {
    isNormalUser = true;
    extraGroups = [ "wheel" "plugdev" "docker" ];
  };

  environment.systemPackages = with pkgs; [
    xorg.libxshmfence  
    wget
    (import ./vim.nix)
    gitFull
    vimer
    google-chrome
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
    kazam
    vlc

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
    ormolu
    haskellPackages.cabal-install
    ghc
    fzf
    ctags
    postgis

    obsidian
  ];

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
  services.sshd.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8100 22 80 3000 3001 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  # Merc
  services.postgresql = {
    package = pkgs.postgresql_13;
    enable = true;
    enableTCPIP = false;
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    extraPlugins = [config.services.postgresql.package.pkgs.postgis];
    # for configuration in NixOS 20.09 or later
    settings = {
      timezone = "UTC";
      shared_buffers = 128;
      fsync = false;
      synchronous_commit = false;
      full_page_writes = false;
    };
  };

  services.journald = {
    # this setting disables rate limiting
    # https://www.freedesktop.org/software/systemd/man/journald.conf.html#RateLimitIntervalSec=
    rateLimitBurst = 0;
    forwardToSyslog = true;
  };

  services.syslogd.enable = true;
  hardware.keyboard.zsa.enable = true;
}

