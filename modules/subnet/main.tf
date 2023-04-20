
resource "aws_subnet" "sculptsoft-subnet-1" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr_block
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
  availability_zone = var.avail_zone
}

resource "aws_internet_gateway" "sculptsoft-igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "sculptsoft-route-table" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sculptsoft-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-route-table"
  }
}

resource "aws_route_table_association" "sculptsoft-rtb-subnet" {
  subnet_id = aws_subnet.sculptsoft-subnet-1.id
  route_table_id = var.default_route_table_id
}
