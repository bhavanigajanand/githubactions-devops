# Create the Private Key
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Push the Key to AWS
resource "aws_key_pair" "deployer_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# Save the .pem file to your local folder
resource "local_file" "tf_key" {
  content  = tls_private_key.rsa_key.private_key_pem
  filename = "${var.key_pair_name}.pem"
}

# Launch the Instance
resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = file("userdata.sh")

  root_block_device {          # ✅ INSIDE the aws_instance block
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = var.instance_name
  }
}