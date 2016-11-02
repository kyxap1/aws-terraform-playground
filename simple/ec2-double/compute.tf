resource "aws_key_pair" "key_pair" {
  key_name   = "${var.name}"
  public_key = "${file("${path.module}/keys/key_pair.pub")}"
}

resource "aws_instance" "web" {
  count                       = 2
  ami                         = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "${var.web_instance_type}"
  vpc_security_group_ids      = ["${element(aws_security_group.web.*.id, count.index)}"]
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  key_name                    = "${aws_key_pair.key_pair.key_name}"
  user_data                   = "${file("${path.module}/user_data/ec2_cloud_config.yml")}"
  iam_instance_profile        = "${aws_iam_instance_profile.instance_profile.id}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags {
    Name = "${var.name}-web${count.index+1}"
  }
}
