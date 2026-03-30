# Find the latest Ubuntu precise image.
# We have a terraform object docker_image.ubuntu that we can reference in the docker_container resource.
resource "docker_image" "ubuntu" {
  name = "ubuntu:latest" # /!\ avoid latest tag in production, it can lead to unexpected results
}

# Start a container
resource "docker_container" "ubuntu" {
  name  = "foo"
  image = docker_image.ubuntu.image_id
  # infinite sleep to keep the container running
  command = [ "sleep", "infinity" ]
}
