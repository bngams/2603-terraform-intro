variable "images_to_create" {
  description = "All images to create"
  # type = map(string)
  type = map(object({
    image_name = string,
    image_hash = string
  }))
}