terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.0.0-beta2"
    }
  }
}

provider "docker" {
  # Configuration options
}