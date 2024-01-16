variable "vpc_name" {
  type    = string
  default = "codearts"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "codearts_agent_subnet_name" {
  type    = string
  default = "codearts_agent"
}

variable "terraform_backend_subnet_name" {
  type    = string
  default = "terraform_backend"
}

variable "resource_prefix" {
  type    = string
  default = "hfa"
}

variable "terraform_download_url" {
  type    = string
  default = "https://releases.hashicorp.com/terraform/1.6.5/terraform_1.6.5_linux_amd64.zip"
}

variable "codearts_agent_download_host" {
  type    = string
  default = "cloud-octopus-agent.obs.cn-north-4.myhuaweicloud.com"
}

variable "codearts_project_id" {
  type = string
}

variable "codearts_cluster_id" {
  type = string
}

variable "codearts_region" {
  type    = string
  default = "ap-southeast-3"
}

variable "accesskey_agent" {
  type = string
}

variable "encrypted_secretkey_agent" {
  type = string
}

variable "postgresql_mode" {
  type        = string
  default     = "single"
  description = "single,ha,replica are available mode"
}

variable "postgresql_vcpus" {
  type    = number
  default = 2
}

variable "postgresql_mem" {
  type    = number
  default = 4
}

variable "availability_zone" {
  type    = string
  default = "ap-southeast-3a"
}

variable "performance_type" {
  type    = string
  default = "normal"
}

variable "cpu_count" {
  type    = number
  default = 4
}

variable "memory_size" {
  type    = number
  default = 8
}

variable "image_name" {
  type    = string
  default = "Ubuntu 22.04 server 64bit"
}

variable "eip_bandwidth" {
  type    = number
  default = 100
}