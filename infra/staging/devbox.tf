module "devbox" {
  source = "../modules/nixos-vm/"
  name   = "devbox"
  nixos = {
    flake = "../../nixos"
    host  = "devbox"
  }
  cpu = {
    cores = 4
  }
  memory = {
    dedicated = 16
  }
  disks = {
    os = {
      size = 128
    }
  }
}
