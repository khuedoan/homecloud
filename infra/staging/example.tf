module "example" {
  source = "../modules/nixos-vm/"
  name   = "example"
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
