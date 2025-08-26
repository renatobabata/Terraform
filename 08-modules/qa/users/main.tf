module "user_module" {
    source = "../../terraform-modules/users"
    environment = "qa"
}

locals {
    iam_user_extension = "my_iam_user_abc"
}