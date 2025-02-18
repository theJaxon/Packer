{ config, pkgs, ... }:
let
  # control_plane_address = "192.168.100.10";
  # worker_node_address = "192.168.100.11";
  # control_plane_api_server_port = 6443;
  # is_control_plane = if (config.networking.hostName == "controlplane") then true else false;

in
{
  imports = [
    ./vagrant-hostname.nix
    ./vagrant-network.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    timeout = 0;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  boot.kernelModules = [
    "br_netfilter"
    "overlay"
  ];

  networking = {
    firewall.enable = false;
    usePredictableInterfaceNames = false;
    hosts = {
      "${control_plane_address}" = [
        "controlplane"
        "controlplane.mkube"
      ];
      "${worker_node_address}" = [
        "worker"
        "worker.mkube"
      ];
    };
  };

  virtualisation.vmware.guest.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "ext4";
  };

  services.openssh.enable = true;
  services.openssh.extraConfig = "PubkeyAcceptedAlgorithms=+ssh-rsa";
  services.openssh.settings.UseDns = false;
  services.timesyncd.enable = true;
  users.mutableUsers = false;
  users.users.root.initialPassword = "vagrant";

  users.groups.vagrant = {
    name = "vagrant";
    members = [ "vagrant" ];
  };

  users.users.vagrant = {
    name = "vagrant";
    group = "vagrant";
    description = "Vagrant default user.";
    extraGroups = [
      "users"
      "wheel"
    ];
    password = "vagrant";
    home = "/home/vagrant";
    createHome = true;
    useDefaultShell = true;
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1YdxBpNlzxDqfJyw/QKow1F+wvG9hXGoqiysfJOn5Y vagrant insecure public key"
    ];
  };

  security.sudo.extraConfig = ''
    Defaults env_keep+=SSH_AUTH_SOCK
    Defaults lecture = never
    vagrant ALL=(ALL) NOPASSWD: ALL
    root    ALL=(ALL) SETENV: ALL
    %wheel  ALL=(ALL) NOPASSWD: ALL, SETENV: ALL
  '';

  system.activationScripts.script.text = ''
    mkdir --verbose --parents /home/vagrant/.kube
    ln --verbose --symbolic  --force /etc/kubernetes/cluster-admin.kubeconfig /home/vagrant/.kube/config
    chown vagrant:vagrant /var/lib/kubernetes/secrets/cluster-admin-key.pem
    chown vagrant:vagrant /var/lib/kubernetes/secrets/apitoken.secret
  '';

  environment.systemPackages = with pkgs; [
    git
    kubectl
    kubernetes
    kubernetes-helm
    vim
  ];

  environment.shellAliases = {
    k = "kubectl";
  };

  # services.kubernetes = {
  #   roles = if is_control_plane then [ "master" ] else [ "node" ];
  #   masterAddress = "controlplane";
  #   apiserverAddress = "https://controlplane:${toString control_plane_api_server_port}";
  #   kubelet.kubeconfig.server = "https://controlplane:${toString control_plane_api_server_port}";
  #   easyCerts = true;
  #   addons.dns.enable = true;
  #   apiserver = {
  #     securePort = control_plane_api_server_port;
  #     advertiseAddress = control_plane_address;
  #   };
  # };
}
