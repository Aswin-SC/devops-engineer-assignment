module "acr" {
  source              = "./modules/acr"
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "keyvault" {
  source              = "./modules/keyvault"
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
}

module "aks" {
  source              = "./modules/aks"
  name                = var.aks_name
  resource_group_name = var.resource_group_name
  location            = var.location
  acr_id              = module.acr.id
}
