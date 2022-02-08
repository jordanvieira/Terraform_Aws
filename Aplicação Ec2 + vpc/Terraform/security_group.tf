resource "aws_security_group" "sql_server" {
  name        = "sql_server"
  description = "sql_server machine"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = 1433
    to_port         = 1433
    protocol        = "TCP"
    security_groups = [aws_security_group.vpn.id]
  }

  ingress {
    from_port       = 3177
    to_port         = 3177
    protocol        = "TCP"
    security_groups = [aws_security_group.vpn.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "Sql_server" })
}



resource "aws_security_group" "vpn" {
  name        = "vpn"
  description = "vpn machine"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 13690
    to_port     = 13690
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "Sql_server" })
}

