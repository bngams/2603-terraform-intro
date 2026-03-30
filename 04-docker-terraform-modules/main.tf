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



# =============================================================================
# NETWORK
# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/network
# =============================================================================
# docker_network.wp_net
resource "docker_network" "wp_net" {
  name = "wp_net" # docker network name, can be anything you like
}

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

# =============================================================================
# CONTAINERS
# =============================================================================

# --- MySQL ---
# docker_container.mysql (terraform object variable name)
resource "docker_container" "mysql" {
  name  = "db" # container name, can be anything you like
  # before custom module
  # image = docker_image.mysql.image_id
  # after custom module
  image = module.images.created_images["mysql"].image_id

  restart = "always"

  env = [
    "MYSQL_ROOT_PASSWORD=${var.MYSQL_ROOT_PWD}",
    "MYSQL_DATABASE=${var.MYSQL_DB_NAME}",
    "MYSQL_USER=${var.MYSQL_USER}",
    "MYSQL_PASSWORD=${var.MYSQL_USER_PWD}"
  ]

  volumes {
    volume_name    = module.volumes.created_volumes["mysql_data"].name
    container_path = "/var/lib/mysql"
  }

  networks_advanced {
    name = docker_network.wp_net.name
  }
}

# --- WordPress ---
resource "docker_container" "wordpress" {
  name  = "wp" # container name, can be anything you like
  # before custom module
  # image = docker_image.wordpress.image_id
  # after custom module
  image = module.images.created_images["wordpress"].image_id

  restart = "always"

  env = [ 
    "WORDPRESS_DB_HOST=${docker_container.mysql.name}",
    "WORDPRESS_DB_USER=${var.MYSQL_USER}",
    "WORDPRESS_DB_PASSWORD=${var.MYSQL_USER_PWD}",
    "WORDPRESS_DB_NAME=${var.MYSQL_DB_NAME}"
  ]

  ports {
    internal = 80
    external = 8888
  }

  volumes {
    volume_name    = module.volumes.created_volumes["wordpress_data"].name
    container_path = "/var/www/html"
  }

  networks_advanced {
    name = docker_network.wp_net.name
  }
  
}