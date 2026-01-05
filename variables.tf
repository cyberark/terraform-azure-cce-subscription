variable "service" {
  description = "Configuration for the service feature."
  type = object({
    enable = optional(bool, true)
  })
  default = { enable = false }
}

