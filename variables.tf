variable "region" {
    description = "The region to deploy the Pet Tamer"
}

variable "controller_account" {
    description = "Account number for the controller role. Where the Lambda and API gateway are located"
}

variable "servicegroups" {
    description = "A list of the service groups that are being managed. This is used to build ssm paramaters"
    type = list(string)
    
}

