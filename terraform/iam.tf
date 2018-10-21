resource "aws_iam_role" "rke-role" {
    name                = "rke-role"
    assume_role_policy  = "${file("rke-trust-policy.json")}"
}

resource "aws_iam_role_policy" "rke-access-policy" {
  name = "rke-access-policy"
  role = "${aws_iam_role.rke-role.id}"
  policy = "${file("rke-access-policy.json")}"
}

resource "aws_iam_instance_profile" "rke-aws" {
  name = "rke-aws"
  role = "${aws_iam_role.rke-role.id}"
}