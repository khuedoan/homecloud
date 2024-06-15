variable "name" {
  description = "Cluster name"
  type        = string
}

variable "masters" {
  description = "Master nodes configuration"
  type = object({
    count  = number
    cpu    = number
    memory = number
    disk   = number
  })

  default = {
    count  = 1
    cpu    = 1
    memory = 2
    disk   = 32
  }
}

variable "workers" {
  description = "Worker nodes configuration"
  type = object({
    count  = number
    cpu    = number
    memory = number
    disk   = number
  })

  default = {
    count  = 1
    cpu    = 1
    memory = 2
    disk   = 32
  }
}
