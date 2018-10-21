provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "rancheros" {
  most_recent = true

  filter {
    name   = "name"
    values = ["rancheros-v1.4.2-hvm-1"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["605812595337"]
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.rancheros.id}"
  instance_type = "t3.xlarge"
  availability_zone = "a"

  vpc_security_group_ids = ""
  subnet_id = ""

  iam_instance_profile = "${aws_iam_instance_profile.rke-aws.name}"

  tags {
    Name = "HelloWorld"
  }
}