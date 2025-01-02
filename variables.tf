variable "proxy_prod_version" {
  type    = string
  default = "v0.2.1"
}

variable "auth_prod_version" {
  type    = string
  default = "v0.2.0"
}

variable "cards_prod_version" {
  type    = string
  default = "v0.2.0"
}

variable "collection_prod_version" {
  type    = string
  default = "v0.1.0"
}

variable "location" {
  type    = string
  default = "France Central"
}

variable "ghcr_username" {
  description = "Github packages username"
  type        = string
  sensitive   = true
}

variable "ghcr_password" {
  description = "Github packages password"
  type        = string
  sensitive   = true
}
