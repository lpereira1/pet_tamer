variable "controller_account_id"{
    description = "Account number of controller account"
    type = string
}

variable "region" {
    description = "Region the controller account is in. Used for SSM parameter permissions"
}