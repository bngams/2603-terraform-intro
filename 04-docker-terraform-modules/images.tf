# =============================================================================
# IMAGES 
# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image
# =============================================================================
# # docker_image.mysql
# resource "docker_image" "mysql" {
#   name = "mysql:latest" # We can also specify a version like "mysql:8.0"
# }

# # docker_image.wordpress
# resource "docker_image" "wordpress" {
#   name = "wordpress:latest" # We can also specify a custom image / private registry like "myregistry.com/wordpress:latest"
# }

# our custom module to create images, we can reuse it in other projects and just change the input variable "images_to_create"
module "images" {
  source = "./modules/images"
  # with type = map(string)
  # images_to_create = {
  #    mysql = "mysql:latest",
  #    wordpress = "wordpress:latest"
  # } 
  images_to_create = {
     mysql = {
       image_name = "mysql:latest",
       image_hash = "sha256:..."
     },
     wordpress = {
       image_name = "wordpress:latest",
       image_hash = "sha256:..."
     }
  }
}

# our custom gives new variables
# module.images.created_images["mysql"].image_id
# module.images.created_images["wordpress"].image_id


