# resource "aws_volume_attachment" "sql_server_attach" {
#   device_name = "/dev/sdh"
#   volume_id   = aws_ebs_volume.sql_server_ebs.id
#   instance_id = aws_instance.sql_server.id
# }

# resource "aws_ebs_volume" "sql_server_ebs" {
#   availability_zone = "${var.aws_region}a"
#   size              = 512
#   type              = "gp3"

# }

#Associando elastic ip
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.sql_server.id
  allocation_id = aws_eip.eip.id
}

#Associando elastic ip
resource "aws_eip_association" "eip_asso" {
  instance_id   = aws_instance.ubuntu.id
  allocation_id = aws_eip.eipv.id
}

#Criando Instancia EC2 - WIN_SQL_SERVER
resource "aws_instance" "sql_server" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  key_name      = "terraform"


  subnet_id                   = aws_subnet.private.0.id
  availability_zone           = "${var.aws_region}a"
  vpc_security_group_ids      = [aws_security_group.sql_server.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 512
    volume_type = "gp3"
  }


  tags = merge(local.common_tags, { Name = "Terraform_Win_Sql_Server" })

}


resource "aws_instance" "ubuntu" {
  ami                         = "ami-04505e74c0741db8d"
  instance_type               = "t2.micro"
  key_name                    = "terraform"
  associate_public_ip_address = true

  subnet_id              = aws_subnet.public.0.id
  availability_zone      = "${var.aws_region}a"
  vpc_security_group_ids = [aws_security_group.vpn.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }


  tags = merge(local.common_tags, { Name = "Terraform_ubuntu_VPN" })

}

resource "aws_eip" "eip" {
  vpc = true
  tags = merge(local.common_tags, { Name = "Terraform Sql-Server " })
}

resource "aws_eip" "eipv" {
  vpc = true
  tags = merge(local.common_tags, { Name = "Terraform VPN " })
}

