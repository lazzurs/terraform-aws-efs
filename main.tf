#------------------------------------------------------------------------------
# Create EFS
#------------------------------------------------------------------------------
data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "this" {
  name        = var.efs_name
  description = "Allows for NFS traffic for ${var.efs_name}"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 2049
    protocol  = "tcp"
    to_port   = 2049
    self      = true
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  tags = merge(
    {
      "Name" = var.efs_name
    },
    var.tags
  )
}

resource "aws_efs_file_system" "this" {
  creation_token = var.efs_name
  encrypted      = var.encrypted

  tags = merge(
    {
      "Name" = var.efs_name
    },
    var.tags
  )
}

resource "aws_efs_mount_target" "this" {
  count          = length(var.subnet_ids) > 0 ? length(var.subnet_ids) : 0
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = var.subnet_ids[count.index]
  security_groups = [
    aws_security_group.this.id
  ]
}