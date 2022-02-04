#Definindo A-Z
data "aws_availability_zones" "available_zones" {
  state = "available"
}

#Cria VPC
resource "aws_vpc" "this" {
  cidr_block = "192.168.0.0/16"
  tags       = merge(local.common_tags, { Name = "Terraform VPC " })
}


#Cria Internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.common_tags, { Name = "Terraform IGW " })
}

#Cria Elastic IP
resource "aws_eip" "gateway" {
  count      = 1
  vpc        = true
  depends_on = [aws_internet_gateway.this]

  tags = merge(local.common_tags, { Name = "Elastic Ip " })
}

#Cria VPC Nat Gateway
resource "aws_nat_gateway" "gateway" {
  count         = 1
  subnet_id     = element(aws_subnet.private.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)

  tags = merge(local.common_tags, { Name = "Terraform NGW " })
}


#Cria subnet public
resource "aws_subnet" "public" {
  count                   = 1
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(local.common_tags, { Name = "Public A" })
}

#Cria subnet private
resource "aws_subnet" "private" {
  count             = 1
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, 1 + count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  tags              = merge(local.common_tags, { Name = "Private A" })
}

#Cria route table public
resource "aws_route_table" "public" {
  count  = 1
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.common_tags, { Name = "Terraform Public" })
}

#Cria route table privada
resource "aws_route_table" "private" {
  count  = 1
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }

  tags = merge(local.common_tags, { Name = "Terraform Private " })
}


#Cria Route para Route Table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.this.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

#Atribui route table
resource "aws_route_table_association" "private" {
  count          = 1
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

#Atribui route table
resource "aws_route_table_association" "this" {

  subnet_id      = aws_subnet.public.0.id
  route_table_id = aws_route_table.public.0.id
}







