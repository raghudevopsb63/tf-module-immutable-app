resource "aws_autoscaling_group" "bar" {
  desired_capacity    = var.DESIRED_CAPACITY
  max_size            = var.MAX_SIZE
  min_size            = var.MIN_SIZE
  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS
  target_group_arns   = [aws_lb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.launch-template.id
    version = "$Latest"
  }

}

