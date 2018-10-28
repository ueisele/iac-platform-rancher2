resource "aws_vpc" "rancher-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "rancher-vpc"
  }
}

resource "aws_subnet" "rancher-subnet-public-a" {
  vpc_id            = "${aws_vpc.rancher-vpc.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
  	Name =  "Subnet public AZ a"
  }
}

resource "aws_subnet" "rancher-subnet-public-b" {
  vpc_id            = "${aws_vpc.rancher-vpc.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true
  tags = {
  	Name =  "Subnet public AZ b"
  }
}

resource "aws_subnet" "rancher-subnet-public-c" {
  vpc_id            = "${aws_vpc.rancher-vpc.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2c"
  map_public_ip_on_launch = true
  tags = {
  	Name =  "Subnet public AZ c"
  }
}

resource "aws_subnet" "rancher-subnet-private-a" {
  vpc_id            = "${aws_vpc.rancher-vpc.id}"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "rancher-subnet-private-b" {
  vpc_id            = "${aws_vpc.rancher-vpc.id}"
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-2b"
}

resource "aws_subnet" "rancher-subnet-private-c" {
  vpc_id            = "${aws_vpc.rancher-vpc.id}"
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-2c"
}

resource "aws_internet_gateway" "rancher-vpc-igw" {
  vpc_id = "${aws_vpc.rancher-vpc.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.rancher-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.rancher-vpc-igw.id}"
}

resource "aws_eip" "rancher-nat-eip" {
  count = 3
  vpc      = true
}

resource "aws_nat_gateway" "rancher-nat-subnet-a" {
    allocation_id = "${aws_eip.rancher-nat-eip.0.id}"
    subnet_id = "${aws_subnet.rancher-subnet-public-a.id}"
    depends_on = ["aws_internet_gateway.rancher-vpc-igw"]
}

resource "aws_nat_gateway" "rancher-nat-subnet-b" {
    allocation_id = "${aws_eip.rancher-nat-eip.1.id}"
    subnet_id = "${aws_subnet.rancher-subnet-public-b.id}"
    depends_on = ["aws_internet_gateway.rancher-vpc-igw"]
}

resource "aws_nat_gateway" "rancher-nat-subnet-c" {
    allocation_id = "${aws_eip.rancher-nat-eip.2.id}"
    subnet_id = "${aws_subnet.rancher-subnet-public-c.id}"
    depends_on = ["aws_internet_gateway.rancher-vpc-igw"]
}


resource "aws_route_table" "private-route-table-a" {
    vpc_id = "${aws_vpc.rancher-vpc.id}"
    tags {
        Name = "Private route table a"
    }
}

resource "aws_route" "private-route-a" {
	route_table_id  = "${aws_route_table.private-route-table-a.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.rancher-nat-subnet-a.id}"
}

resource "aws_route_table_association" "rancher-subnet-private-a-association" {
    subnet_id = "${aws_subnet.rancher-subnet-private-a.id}"
    route_table_id = "${aws_route_table.private-route-table-a.id}"
}


resource "aws_route_table" "private-route-table-b" {
    vpc_id = "${aws_vpc.rancher-vpc.id}"
    tags {
        Name = "Private route table b"
    }
}

resource "aws_route" "private-route-b" {
	route_table_id  = "${aws_route_table.private-route-table-b.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.rancher-nat-subnet-b.id}"
}

resource "aws_route_table_association" "rancher-subnet-private-b-association" {
    subnet_id = "${aws_subnet.rancher-subnet-private-b.id}"
    route_table_id = "${aws_route_table.private-route-table-b.id}"
}


resource "aws_route_table" "private-route-table-c" {
    vpc_id = "${aws_vpc.rancher-vpc.id}"
    tags {
        Name = "Private route table c"
    }
}

resource "aws_route" "private-route-c" {
	route_table_id  = "${aws_route_table.private-route-table-c.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.rancher-nat-subnet-c.id}"
}

resource "aws_route_table_association" "rancher-subnet-private-c-association" {
    subnet_id = "${aws_subnet.rancher-subnet-private-c.id}"
    route_table_id = "${aws_route_table.private-route-table-c.id}"
}


resource "aws_security_group" "sg-rancher-node" {
  name        = "rancher-node"
  description = "Allow inbound and outbound traffic for Rancher nodes"
  vpc_id      = "${aws_vpc.rancher-vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
    from_port   = 2376
    to_port     = 2376
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    self        = true
  }   
  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    self        = true
  }  
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    self        = true
  }   
  ingress {
    from_port   = 10250
    to_port     = 10252
    protocol    = "tcp"
    self        = true
  }  
  ingress {
    from_port   = 10256
    to_port     = 10256
    protocol    = "tcp"
    self        = true
  }  
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }    

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}