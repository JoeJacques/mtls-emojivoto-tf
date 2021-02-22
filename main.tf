locals {
  adj               = jsondecode(file("./adjectives.json"))
}

module "network" {
  count            = var.deploy_count
  source           = "./modules/network"
  required_subnets = 2
  PlaygroundName   = var.PlaygroundName
}


module "puppet" {
  count              = var.deploy_count
  source             = "./modules/instance"
  PlaygroundName     = "${element(local.adj, count.index)}-panda-${var.PlaygroundName}-puppet"
  security_group_ids = [module.network.0.allow_all_security_group_id]
  subnet_id          = module.network.0.public_subnets.0
  instance_type      = var.instance_type
  user_data = templatefile(
    "${var.scriptLocation}/test-feb.sh",
    {
      hostname = "playground"
      username = "puppet"
      ssh_pass = "playground"
      region   = var.region
      gitrepo  = ""
    }
  )
  amiName  = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  amiOwner = "099720109477"
}

module "ca" {
  count              = var.deploy_count
  source             = "./modules/instance"
  PlaygroundName     = "${element(local.adj,count.index)}-panda-${var.PlaygroundName}-ca"
  security_group_ids = [module.network.0.allow_all_security_group_id]
  subnet_id          = module.network.0.public_subnets.0
  instance_type      = var.instance_type
  user_data = templatefile(
    "${var.scriptLocation}/test-feb.sh",
    {
      hostname = "playground"
      username = "ca"
      ssh_pass = "playground"
      region   = var.region
      gitrepo  = ""
    }
  )
  amiName  = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  amiOwner = "099720109477"
}

module "web" {
  count              = var.deploy_count
  source             = "./modules/instance"
  PlaygroundName     = "${element(local.adj, count.index)}-panda-${var.PlaygroundName}-web"
  security_group_ids = [module.network.0.allow_all_security_group_id]
  subnet_id          = module.network.0.public_subnets.0
  instance_type      = var.instance_type
  user_data = templatefile(
    "${var.scriptLocation}/test-feb.sh",
    {
      hostname = "playground"
      username = "web"
      ssh_pass = "playground"
      region   = var.region
      gitrepo  = ""
    }
  )
  amiName  = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  amiOwner = "099720109477"
}

module "emoji" {
  count              = var.deploy_count
  source             = "./modules/instance"
  PlaygroundName     = "${element(local.adj, count.index)}-panda-${var.PlaygroundName}-emoji"
  security_group_ids = [module.network.0.allow_all_security_group_id]
  subnet_id          = module.network.0.public_subnets.0
  instance_type      = var.instance_type
  user_data = templatefile(
    "${var.scriptLocation}/test-feb.sh",
    {
      hostname = "playground"
      username = "emoji"
      ssh_pass = "playground"
      region   = var.region
      gitrepo  = ""
    }
  )
  amiName  = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  amiOwner = "099720109477"
}

module "voting" {
  count              = var.deploy_count
  source             = "./modules/instance"
  PlaygroundName     = "${element(local.adj, count.index)}-panda-${var.PlaygroundName}-voting"
  security_group_ids = [module.network.0.allow_all_security_group_id]
  subnet_id          = module.network.0.public_subnets.0
  instance_type      = var.instance_type
  user_data = templatefile(
    "${var.scriptLocation}/test-feb.sh",
    {
      hostname = "playground"
      username = "voting"
      ssh_pass = "playground"
      region   = var.region
      gitrepo  = ""
    }
  )
  amiName  = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  amiOwner = "099720109477"
}

module "dns_puppet" {
  count        = var.deploy_count
  source       = "./modules/dns"
  instances    = var.instances
  instance_ips = element(module.puppet.*.public_ips, count.index)
  domain_name  = var.domain_name
  record_name  = "${var.PlaygroundName}-puppet-${element(local.adj, count.index)}-panda"
}
  module "dns_ca" {
    count        = var.deploy_count
    source       = "./modules/dns"
    instances    = var.instances
    instance_ips = element(module.ca.*.public_ips, count.index)
    domain_name  = var.domain_name
    record_name  = "${var.PlaygroundName}-ca-${element(local.adj, count.index)}-panda"
  }

  module "dns_web" {
    count        = var.deploy_count
    source       = "./modules/dns"
    instances    = var.instances
    instance_ips = element(module.web.*.public_ips, count.index)
    domain_name  = var.domain_name
    record_name  = "${var.PlaygroundName}-web-${element(local.adj, count.index)}-panda"
  }

  module "dns_emoji" {
    count        = var.deploy_count
    source       = "./modules/dns"
    instances    = var.instances
    instance_ips = element(module.emoji.*.public_ips, count.index)
    domain_name  = var.domain_name
    record_name  = "${var.PlaygroundName}-emoji-${element(local.adj, count.index)}-panda"
  }

  module "dns_voting" {
    count        = var.deploy_count
    source       = "./modules/dns"
    instances    = var.instances
    instance_ips = element(module.voting.*.public_ips, count.index)
    domain_name  = var.domain_name
    record_name  = "${var.PlaygroundName}-voting-${element(local.adj, count.index)}-panda"
  }



