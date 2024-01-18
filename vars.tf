variable "resource_group_name" {
  type =string
  description = "name of ressource group"
  default = "karima-tigrine"
}

variable "location" {
  description = "Azure region to deploy the resources"
  type        = string
  default     = "francecentral"
}
