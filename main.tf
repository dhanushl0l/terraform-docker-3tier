terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "app_internal" {
  name     = "app_internal"
  internal = true
}

# Nginx
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "frontend"

  ports {
    internal = 80
    external = var.nginx_port
  }

  volumes {
    host_path      = abspath("${path.module}/templates")
    container_path = "/usr/share/nginx/html"
  }

  volumes {
    host_path      = abspath("${path.module}/templates/nginx.conf")
    container_path = "/etc/nginx/nginx.conf"
  }

  networks_advanced {
    name = docker_network.app_internal.name
  }

  networks_advanced {
    name = "bridge"
  }
}

# Rust backend
resource "docker_image" "rust_app" {
  name = "rust-app:latest"
  build {
    context    = abspath("${path.module}/backend")
    dockerfile = "Dockerfile"
  }
  keep_locally = true
}

resource "docker_container" "rust_app" {
  image = docker_image.rust_app.image_id
  name  = "rust-backend"

  env = [
    "DATABASE_URL=${var.database_url}"
  ]

  networks_advanced {
    name = docker_network.app_internal.name
  }
}

resource "docker_image" "postgres" {
  name         = "postgres:16"
  keep_locally = false
}

resource "docker_container" "postgres" {
  image = docker_image.postgres.image_id
  name  = "postgres-db"

  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}"
  ]

  networks_advanced {
    name = docker_network.app_internal.name
  }

  volumes {
    host_path      = abspath("${path.module}/init.sql")
    container_path = "/docker-entrypoint-initdb.d/init.sql"
  }

  volumes {
    host_path      = abspath("${path.module}/postgres_data")
    container_path = "/var/lib/postgresql/data"
  }
}
