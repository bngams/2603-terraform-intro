# =============================================================================
# NETWORK
# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/network
# =============================================================================
# docker_network.wp_net
resource "docker_network" "wp_net" {
  name = "wp_net" # docker network name, can be anything you like
}
