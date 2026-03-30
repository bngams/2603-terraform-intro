# if images_to_create equals ["mysql:latest", "wordpress:latest"], 
# then applies resource "docker_image" "images" for each one

resource "docker_image" "created_images" {
  # for_each = var.images_to_create # with type = map(string)
  for_each = var.images_to_create # with type = map(object({image_name, image_hash}))
  name = each.value.image_name # with type = map(object({image_name, image_hash}))
}