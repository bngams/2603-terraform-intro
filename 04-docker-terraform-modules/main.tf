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