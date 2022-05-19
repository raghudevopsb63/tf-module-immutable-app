resource "aws_launch_template" "launch-template" {
  name                   = "${var.COMPONENT}-${var.ENV}"
  image_id               = data.aws_ami.ami.id
  instance_type          = var.INSTANCE_TYPE
  vpc_security_group_ids = [aws_security_group.allow_app.id]
  //user_data = filebase64("${path.module}/example.sh")

  instance_market_options {
    market_type = "spot"
  }

  iam_instance_profile {
    name = var.APP_TYPE == "backend" ? data.terraform_remote_state.iam.outputs.INSTANCE_PROFILE_NAME : null
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.COMPONENT}-${var.ENV}"
      ENV         = var.ENV
      COMPONENT   = var.COMPONENT
      APP_VERSION = var.APP_VERSION
    }
  }

}