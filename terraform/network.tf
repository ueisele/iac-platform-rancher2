resource "aws_vpc" "rancher-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "rancher-subnet-a" {
  vpc_id            = "${aws_vpc.rancher-vpc.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "rancher-subnet-b" {
  vpc_id            = "${aws_vpc.rancher-vpc.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"
}

resource "aws_subnet" "rancher-subnet-c" {
  vpc_id            = "${aws_vpc.rancher-vpc.id}"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-2c"
}

resource "aws_internet_gateway" "rancher-vpc-igw" {
  vpc_id = "${aws_vpc.rancher-vpc.id}"
}

resource "aws_lb" "rancher" {
  depends_on = ["aws_internet_gateway.rancher-vpc-igw"]
  name               = "rancher"
  internal           = false
  load_balancer_type = "network"
  subnets            = [
    "${aws_subnet.rancher-subnet-a.id}",
    "${aws_subnet.rancher-subnet-b.id}",
    "${aws_subnet.rancher-subnet-c.id}"
  ]
  
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_target_group" "rancher-tcp-443" {
  name          = "rancher-tcp-443"
  protocol      = "TCP"
  port          = 443
  target_type   = "instance"
  vpc_id        = "${aws_vpc.rancher-vpc.id}"
  
  health_check  = {
      protocol            = "HTTP"
      path                = "/healthz"
      port                = 80
      healthy_threshold   = 3
      unhealthy_threshold = 3
      timeout             = 6
      interval            = 10
      matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "rancher-tcp-80" {
  name          = "rancher-tcp-80"
  protocol      = "TCP"
  port          = 80
  target_type   = "instance"
  vpc_id        = "${aws_vpc.rancher-vpc.id}"
  
  health_check  = {
      protocol            = "HTTP"
      path                = "/healthz"
      port                = 80
      healthy_threshold   = 3
      unhealthy_threshold = 3
      timeout             = 6
      interval            = 10
      matcher             = "200-399"
  }
}

resource "aws_lb_listener" "rancher-listener-tcp-443" {
  load_balancer_arn = "${aws_lb.rancher.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.rancher-tcp-443.arn}"
  }
}

resource "aws_lb_listener" "rancher-listener-tcp-80" {
  load_balancer_arn = "${aws_lb.rancher.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.rancher-tcp-80.arn}"
  }
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