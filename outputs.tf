output "nginx_url" {
  description = "Frontend URL"
  value       = "http://localhost:${var.nginx_port}"
}

output "rust_backend_name" {
  description = "Name of the Rust backend container"
  value       = docker_container.rust_app.name
}

output "postgres_container" {
  description = "Name of the PostgreSQL container"
  value       = docker_container.postgres.name
}
