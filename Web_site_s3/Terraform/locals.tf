locals {

  has_domain = var.domain != ""
  domain     = local.has_domain ? var.domain : random_pet.website.id

  common_tags = {

    Project   = "AWS com Terraform"
    Service   = "Static Website"
    CreatedAt = "2022-01-13"
    Module    = "3"

  }
}
