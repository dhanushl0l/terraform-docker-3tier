variable "nginx_port" {
  description = "External port for Nginx"
  type        = number
  default     = 8081
}

variable "database_url" {
  description = "PostgreSQL connection string for backend"
  type        = string
  default     = "postgres://test:test@postgres-db:5432/test"
}

variable "db_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "test"
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  default     = "test"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "test"
}
