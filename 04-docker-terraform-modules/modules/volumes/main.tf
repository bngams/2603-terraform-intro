# if volumes_to_create equals {"mysql_data": {volume_name: "..."}, "wordpress_data": {volume_name: "..."}},
# then applies resource "docker_volume" "volumes" for each one

resource "docker_volume" "created_volumes" {
  for_each = var.volumes_to_create
  name = each.value.volume_name
}
