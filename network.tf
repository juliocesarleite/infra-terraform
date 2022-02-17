resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Nova VPC"
  }
}


resource "aws_route_table" "main_RT" {
  vpc_id = aws_vpc.main.id
  route = [
    {
      carrier_gateway_id         = ""
      cidr_block                 = "0.0.0.0/0"
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = aws_internet_gateway.igw.id
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
  ]
  tags = {
    Name = "Main Route table"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "subnet1"
  }
}

resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.main_RT.id
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "sa-east-1b"

  tags = {
    Name = "subnet 2"
  }
}

resource "aws_route_table_association" "subnet2_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.main_RT.id
}

resource "aws_subnet" "subnet3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "sa-east-1c"

  tags = {
    Name = "subnet 3"
  }
}

resource "aws_route_table_association" "subnet3_association" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.main_RT.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Internet gateway"
  }
}