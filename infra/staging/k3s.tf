module "k3s" {
  source = "../modules/nixos-vm/"
  name   = "k3s"
  nixos = {
    flake = "../../nixos"
    host  = "k3s"
  }
  cpu = {
    cores = 8
  }
  memory = {
    dedicated = 16
  }
  disks = {
    os = {
      size = 256
    }
  }
}
