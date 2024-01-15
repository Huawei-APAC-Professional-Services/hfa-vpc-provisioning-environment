locals {
  codearts_agent_subnet_cidr    = cidrsubnet(var.vpc_cidr, 8, 0)
  terraform_backend_subnet_cidr = cidrsubnet(var.vpc_cidr, 8, 1)
}

resource "huaweicloud_vpc" "agent_vpc" {
  name = var.vpc_name
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "agent_subnet" {
  name       = var.codearts_agent_subnet_name
  cidr       = local.codearts_agent_subnet_cidr
  gateway_ip = cidrhost(local.codearts_agent_subnet_cidr, 1)
  vpc_id     = huaweicloud_vpc.agent_vpc.id
}

resource "huaweicloud_vpc_subnet" "terraform_backend_subnet" {
  name       = var.terraform_backend_subnet_name
  cidr       = local.terraform_backend_subnet_cidr
  gateway_ip = cidrhost(local.terraform_backend_subnet_cidr, 1)
  vpc_id     = huaweicloud_vpc.agent_vpc.id
}

data "huaweicloud_availability_zones" "main" {}

data "template_file" "init" {
  template = file("${path.module}/ecs_init.yaml")
  vars = {
    ak                     = var.accesskey_agent
    sk                     = var.encrypted_secretkey_agent
    cluster_id             = var.codearts_cluster_id
    project_id             = var.codearts_project_id
    region                 = var.codearts_region
    download_host          = var.codearts_agent_download_host
    terraform_download_url = var.terraform_download_url
  }
}


resource "huaweicloud_identity_role" "assume_role" {
  name = "${var.resource_prefix}-codearts-agent"
  type = "AX"
  policy = jsonencode({
    "Version" : "1.1",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:agencies:assume"
        ]
      }
    ]
  })
  description = "Allowing Assume Role"
}

resource "huaweicloud_identity_agency" "codearts_agent" {
  name                   = "${var.resource_prefix}-codearts-agent"
  description            = "Manage codearts agent permission"
  delegated_service_name = "op_svc_ecs"

  all_resources_roles = [
    huaweicloud_identity_role.assume_role.name
  ]
}

// ECS Agent
data "huaweicloud_compute_flavors" "main" {
  availability_zone = var.availability_zone
  performance_type  = var.performance_type
  cpu_core_count    = var.cpu_count
  memory_size       = var.memory_size
}

data "huaweicloud_images_image" "main" {
  name        = var.image_name
  most_recent = true
}


resource "huaweicloud_networking_secgroup" "codearts_agent" {
  name        = "${var.resource_prefix}-codearts-agent"
  description = "allow agent to access internet"
}

resource "huaweicloud_networking_secgroup" "terraform_pg" {
  name        = "${var.resource_prefix}-terraform-pg"
  description = "allow agent to access database"
}

resource "huaweicloud_networking_secgroup_rule" "codearts_agent" {
  security_group_id = huaweicloud_networking_secgroup.terraform_pg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_group_id   = huaweicloud_networking_secgroup.codearts_agent.id
}

resource "huaweicloud_vpc_eip" "main" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "${var.resource_prefix}-codearts-agent"
    size        = var.eip_bandwidth
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_compute_instance" "main" {
  name               = "${var.resource_prefix}-codearts-agent"
  image_id           = data.huaweicloud_images_image.main.id
  flavor_id          = data.huaweicloud_compute_flavors.main.ids[0]
  user_data          = data.template_file.init.rendered
  agency_name        = huaweicloud_identity_agency.codearts_agent.name
  security_group_ids = [huaweicloud_networking_secgroup.codearts_agent.id]
  availability_zone  = var.availability_zone

  network {
    uuid = huaweicloud_vpc_subnet.agent_subnet.id
  }
}

//

resource "huaweicloud_rds_parametergroup" "terraform_backend" {
  name        = "terraform_backend"
  description = "Backend for Terraform"
  datastore {
    type    = "postgresql"
    version = "15"
  }
}

data "huaweicloud_rds_flavors" "postgresql" {
  db_type           = "PostgreSQL"
  db_version        = "15"
  instance_mode     = var.postgresql_mode
  vcpus             = var.postgresql_vpcs
  memory            = var.postgresql_mem
  availability_zone = var.availability_zone
}

resource "huaweicloud_rds_instance" "terraform_backend" {
  name              = "terraform_backend"
  flavor            = data.huaweicloud_rds_flavors.postgresql.flavors[0].id
  vpc_id            = huaweicloud_vpc.agent_vpc.id
  subnet_id         = huaweicloud_vpc_subnet.terraform_backend_subnet.id
  security_group_id = huaweicloud_networking_secgroup.terraform_pg.id
  availability_zone = [var.availability_zone]

  db {
    type     = "PostgreSQL"
    version  = "15"
    password = "Huangwei!120521"
  }

  volume {
    type = "ULTRAHIGH"
    size = 40
  }

  backup_strategy {
    start_time = "08:00-09:00"
    keep_days  = 1
  }
}