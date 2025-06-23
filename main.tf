module "resource_group" {
  source = "../Module/resource_group"

  resource_group_name     = "rg_infra"
  resource_group_location = "Central India"
}

module "virtual_network" {
  depends_on = [module.resource_group]
  source     = "../Module/Vnet"

  virtual_network_name     = "vnet_infra"
  virtual_network_location = "Central India"
  resource_group_name      = "rg_infra"
  address_space            = ["10.0.0.0/16"]
}

module "subnet1" {
  depends_on = [module.virtual_network]
  source     = "../Module/Subnet"

  subnet_name          = "subnet_1"
  virtual_network_name = "vnet_infra"
  resource_group_name  = "rg_infra"
  address_prefixes     = ["10.0.1.0/24"]
}

module "subnet2" {
  depends_on = [module.virtual_network]
  source     = "../Module/Subnet"

  subnet_name          = "subnet_2"
  virtual_network_name = "vnet_infra"
  resource_group_name  = "rg_infra"
  address_prefixes     = ["10.0.2.0/24"]
}

module "public_ip1" {
  depends_on = [ module.subnet1]
  source = "../Module/public_ip"

  public_ip_name          = "public_ip_1"
  resource_group_name     = "rg_infra"
  resource_group_location = "Central India"
}

module "public_ip2" {
  depends_on = [ module.subnet2 ]
  source = "../Module/public_ip"

  public_ip_name          = "public_ip_2"
  resource_group_name     = "rg_infra"
  resource_group_location = "Central India"
}

module "vm1" {
  depends_on = [module.subnet1, module.public_ip1, module.resource_group]
  source     = "../Module/virtual_machine"

  vmname2025                   = "vm1111"
  resource_group_name       = "rg_infra"
  resource_group_location   = "Central India"
  virtual_network_name      = "vnet_infra"
  subnet_name               = "subnet_1"
  nic_name                  = "nic_1"
  public_ip_name            = "public_ip_1"
  vm_size                   = "Standard_B1s"
  image_publisher           = "Canonical"
  image_offer               = "0001-com-ubuntu-server-jammy"
  image_sku                 = "22_04-lts"
  image_version             = "latest"
  custom_data = base64encode (<<EOF
#!/bin/bash
apt update -y
apt install nginx -y
systemctl start nginx
systemctl enable nginx
EOF
) 

}

#   module "vm2" {
#   depends_on = [module.subnet2, module.public_ip2]
#   source     = "../Module/virtual_machine"

#   vmname2025                   = "vm2222"
#   resource_group_name       = "rg_infra"
#   resource_group_location   = "Central India"
#   virtual_network_name      = "vnet_infra"
#   subnet_name               = "subnet_2"
#   nic_name                  = "nic_2"
#   public_ip_name            = "public_ip_2"
#   vm_size                   = "Standard_B1s"
#   image_publisher           = "Canonical"
#   image_offer               = "0001-com-ubuntu-server-jammy"
#   image_sku                 = "22_04-lts"
#   image_version             = "latest"
# }

  module "sql_server" {
    depends_on = [ module.resource_group, module.key_vault, module.secret1, module.secret2 ]
  source = "../Module/sql_server"

  sql_server_name       = "goyalserver"
  resource_group_name   = "rg_infra"
  location              = "Central India"
  # administrator_username = "sqladmin"
  # administrator_password = "Password@123"
}

module "database" {
  depends_on = [module.sql_server]
  source     = "../Module/sql_database"

  sql_database_name   = "goyalsqldatabase"
  sql_server_name     = "goyalserver"
  resource_group_name = "rg_infra"
}

module "key_vault" {
  depends_on = [ module.resource_group ]
  source = "../Module/Key_vault"

  key_vault_name = "goyalkeyvault"
  resource_group_name = "rg_infra"
  resource_group_location = "Central India"
}

module "secret1" {
  # depends_on = [ module.key_vault ]
  source = "../Module/secret"

  secret_name = "username-goyal"
  secret_value = "devopsadmin"
  # key_vault_name = "goyalkeyvault"
  # resource_group_name = "rg_infra"
}

module "secret2" {
  # depends_on = [ module.key_vault ]
  source = "../Module/secret"

  secret_name = "password-goyal"
  secret_value = "Devops@1234"
  # key_vault_name = "goyalkeyvault"
  # resource_group_name = "rg_infra"
}