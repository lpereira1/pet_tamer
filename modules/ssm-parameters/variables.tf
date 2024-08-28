variable "minimum_servers" {
    description = "The minimum number of servers that should be on in a service group"
    default = 2
    type = number
}

variable "servicegroup" {
    description = "The name of the service group"
    type = string
}