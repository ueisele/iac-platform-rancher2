resource "aws_security_group" "sg-bastion" {
  name        = "bastion"
  description = "Allow SSH access to bastion host and outbound internet access"
  vpc_id      = "${aws_vpc.rancher-vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }  
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*ubuntu-bionic-18.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

resource "aws_instance" "bastion-a" {
  instance_type     = "t3.medium"
  availability_zone = "us-east-2a"
  ami               = "${data.aws_ami.ubuntu.id}"
  associate_public_ip_address = true

  subnet_id = "${aws_subnet.rancher-subnet-public-a.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-bastion.id}"]

  iam_instance_profile = "${aws_iam_instance_profile.rke-aws.name}"
  key_name = "${aws_key_pair.aws-ue-rancher.key_name}"
}

output "bastion-a-public-ip" {
  value = "${aws_instance.bastion-a.public_ip}"
}