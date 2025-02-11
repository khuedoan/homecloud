module "example" {
  source = "../modules/nixos-vm/"
  name   = "example"
  nixos = {
    flake = "../../nixos"
    host  = "nixos"
  }
  cpu = {
    cores = 1
  }
  memory = {
    dedicated = 2
  }
  disks = {
    os = {
      size = 32
    }
  }
}
