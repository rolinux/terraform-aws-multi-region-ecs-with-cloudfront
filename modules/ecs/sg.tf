/* Security Group resources */
resource "aws_default_security_group" "default" {
  vpc_id = data.aws_vpc.default.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "default_sg"
    Owner = "Radu"
  }
}

resource "aws_security_group" "lb_allow_http" {
  name        = "lb_allow_http"
  description = "Allow HTTP inbound traffic into LB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from Internet"
    from_port   = var.host_port
    to_port     = var.host_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "lb_allow_http"
    Owner = "Radu"
  }
}
