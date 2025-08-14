#types of vars #any(default), number, bool, list, map, set, object, tuple
#order of priority: 
# 1 -var used as parameter in the command line terraform apply
# 2 -environment variables
# 3 -var defined in main.tf
iam_user_name_prefix = "VALUE_FROM_TERRAFORM_TFVARS"