variable "resource_group_name" {
  default = "pokecloud-resources"
}

variable "location" {
  default = "West Europe"
}

variable "server_name" {
  default = "pokecloudpgserver"
}

variable "admin_user" {
  default = "adminuser"
}

variable "database_name" {
  default = "pokeclouddb"
}

variable "resource_group_location" {
  type        = string
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg-cloud"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
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

variable "tgc_api_key" {
  description = "The api key for the tgc api"
  type        = string
  sensitive   = true
}
