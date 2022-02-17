provider "aws" {
  version = "~> 3.0"
  region  = "sa-east-1"
}

resource "aws_key_pair" "julio-key2" {
  key_name   = "julio-key2"
  public_key = file("C:/Users/Julio Leite/.ssh/id_rsa.pub")
}

module "instancia_ec2" {
  source                      = "./ec2_module"
  amis                         = var.amis
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.julio-key2.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.acesso-ssh.id}", "${aws_security_group.acesso-porta80.id}"]
  subnet_id                   = aws_subnet.subnet1.id
  user_data                   = file("userdata.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

output "public_ip" {
  value       = module.instancia_ec2.public_ip
  description = "Mostra o IP publico da maquina criada."
  depends_on = [module.instancia_ec2]
}








