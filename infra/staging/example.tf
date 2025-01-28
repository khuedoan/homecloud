module "example" {
  source = "../modules/nixos-vm/"
  name   = "example"
  nixos = {
    flake = "../../global/images"
    host  = "nixos"
  }
  cpu = {
    cores = 2
  }
  memory = {
    dedicated = 8
  }
  disks = {
    os = {
      size = 32
    }
  }
}
