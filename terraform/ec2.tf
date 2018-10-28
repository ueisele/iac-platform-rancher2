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

data "template_file" "provision" {
    template = "provision.sh"
}

resource "aws_instance" "rancher-a" {
  instance_type     = "t3.xlarge"
  availability_zone = "us-east-2a"
  ami               = "${data.aws_ami.rancheros.id}"

  subnet_id = "${aws_subnet.rancher-subnet-private-a.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-rancher-node.id}"]

  iam_instance_profile = "${aws_iam_instance_profile.rke-aws.name}"
  key_name = "${aws_key_pair.aws-ue-rancher.key_name}"

  user_data = "${data.template_file.provision.rendered}"
}

resource "aws_lb_target_group_attachment" "rancher-a-target-433" {
  target_group_arn = "${aws_lb_target_group.rancher-tcp-443.arn}"
  target_id        = "${aws_instance.rancher-a.id}"
  port             = 443
}

resource "aws_lb_target_group_attachment" "rancher-a-target-80" {
  target_group_arn = "${aws_lb_target_group.rancher-tcp-80.arn}"
  target_id        = "${aws_instance.rancher-a.id}"
  port             = 80
}

resource "aws_instance" "rancher-b" {
  instance_type     = "t3.xlarge"
  availability_zone = "us-east-2b"
  ami               = "${data.aws_ami.rancheros.id}"

  subnet_id = "${aws_subnet.rancher-subnet-private-b.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-rancher-node.id}"]

  iam_instance_profile = "${aws_iam_instance_profile.rke-aws.name}"
  key_name = "${aws_key_pair.aws-ue-rancher.key_name}"

  user_data = "${data.template_file.provision.rendered}"
}

resource "aws_lb_target_group_attachment" "rancher-b-target-433" {
  target_group_arn = "${aws_lb_target_group.rancher-tcp-443.arn}"
  target_id        = "${aws_instance.rancher-b.id}"
  port             = 443
}

resource "aws_lb_target_group_attachment" "rancher-b-target-80" {
  target_group_arn = "${aws_lb_target_group.rancher-tcp-80.arn}"
  target_id        = "${aws_instance.rancher-b.id}"
  port             = 80
}

resource "aws_instance" "rancher-c" {
  instance_type     = "t3.xlarge"
  availability_zone = "us-east-2c"
  ami               = "${data.aws_ami.rancheros.id}"

  subnet_id = "${aws_subnet.rancher-subnet-private-c.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-rancher-node.id}"]

  iam_instance_profile = "${aws_iam_instance_profile.rke-aws.name}"
  key_name = "${aws_key_pair.aws-ue-rancher.key_name}"

  user_data = "${data.template_file.provision.rendered}"
}

resource "aws_lb_target_group_attachment" "rancher-c-target-433" {
  target_group_arn = "${aws_lb_target_group.rancher-tcp-443.arn}"
  target_id        = "${aws_instance.rancher-c.id}"
  port             = 443
}

resource "aws_lb_target_group_attachment" "rancher-c-target-80" {
  target_group_arn = "${aws_lb_target_group.rancher-tcp-80.arn}"
  target_id        = "${aws_instance.rancher-c.id}"
  port             = 80
}
