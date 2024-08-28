# ssm_parameters.tf

resource "aws_ssm_parameter" "min_servers_running" {
  name  = "/pettamer/${var.servicegroup}/min_servers_running"
  type  = "String"
  value = "${var.minimum_servers}"
}


