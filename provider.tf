# main.tf

provider "aws" {
  region = var.region  # Main account region
  profile = "profile-343943556357"
  #If you need to assume role vs using sso profile comment out profile and update role_arn
  #role_arn    = "[role_arn]"

}


#add provider for each target account you want to add
provider "aws"{
  alias = "target_account1"
  region = var.region
  profile = "profile-343943556357"

  #If you need to assume role vs using sso profile comment out profile and update role_arn
  #role_arn    = "[role_arn]"
}