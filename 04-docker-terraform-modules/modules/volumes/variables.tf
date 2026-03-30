variable "volumes_to_create" {
  description = "All volumes to create"
  type = map(object({
    volume_name = string
  }))
}
