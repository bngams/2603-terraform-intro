terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.0.0-beta2"
    }
  }
}

# config for docker provider, is mandatory
# => can be done in root module
