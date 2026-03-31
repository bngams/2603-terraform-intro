# =============================================================================
# VOLUMES
# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume
# =============================================================================
# # docker_volume.mysql_data
# resource "docker_volume" "mysql_data" {
#   name = "mysql_data_tf_2603"
# }

# # docker_volume.wordpress_data
# resource "docker_volume" "wordpress_data" {
#   name = "wordpress_data"
# }

# our custom module to create volumes, we can reuse it in other projects and just change the input variable "volumes_to_create"
module "volumes" {
  source = "./modules/volumes"
  volumes_to_create = {
    mysql_data = {
      volume_name = "mysql_data_tf_2603"
    },
    wordpress_data = {
      volume_name = "wordpress_data"
    }
  }
}