### KT TERRAFORM

#### Proposta do projeto:
> Criação de uma infraestrutura na Cloud AWS a partir do código TerraForm, contendo os seguintes recursos configurados:
-[x] Criação de uma VPC
-[x] Criação de 3 subnets em Avaliabilities Zones diferentes dentro da VPC
-[x] Criação de Internet Gateway
-[x] Criação de Route Table
-[x] Criação de dois security group, sendo um com acesso a porta 80 e outro a porta 22
-[x] Criação de um EC2 com nginx ativo e acessível na porta 80
-[x] Criação de um bucket S3, sem acesso a internet, para servir como repositório ao terraform.tfstate
-[x] Criação de um módulo que provisiona a EC2

#### Organização do código
<p>
##### **Pasta remote_tfstate**
**bucket.tf**: Nesse arquivo há a **criação do bucket s3** que servirá para armanezar o tfstate do projeto.
<details><summary>Clique para expandir</summary>

```
provider "aws" {
  version = "~> 3.0"
  region  = "sa-east-1"
}

data "aws_caller_identity" "current" {}
resource "aws_s3_bucket" "remotestate" {
  bucket = "tfstate-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name        = "Remote State"
    Environment = "Dev"
  }
  versioning {
    enabled = true
  }
}

output "remote_state_bucket" {
  value = aws_s3_bucket.remotestate.bucket
}

output "remote_state_bucket_arn" {
  value = aws_s3_bucket.remotestate.arn
}
```
</details>

<p>
##### Pasta infra-terraform
**network.tf**: Nesse arquivo há a **criação da nova VPC**, **criação das três subnets**, **criação da route table**, **associação das subnets com a route table** e a **criação do Internet Gateway**
> Plus: Criação de um data com acesso ao site http://ipv4.icanhazip.com para buscar o meu ip e permitir no arquivo do security group o acesso ssh somente a esse endereço

<details><summary>Clique para expandir</summary>

```
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Nova VPC"
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com" # outra opção "https://ifconfig.me"
}

resource "aws_route_table" "main_RT" {
  vpc_id = aws_vpc.main.id
  route = [
    {
      carrier_gateway_id         = ""
      cidr_block                 = "0.0.0.0/0"
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = aws_internet_gateway.igw.id
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
  ]
  tags = {
    Name = "Main Route table"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "subnet1"
  }
}

resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.main_RT.id
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "sa-east-1b"

  tags = {
    Name = "subnet 2"
  }
}

resource "aws_route_table_association" "subnet2_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.main_RT.id
}

resource "aws_subnet" "subnet3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "sa-east-1c"

  tags = {
    Name = "subnet 3"
  }
}

resource "aws_route_table_association" "subnet3_association" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.main_RT.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Internet gateway"
  }
}
```
</p>
</details>

<p>
**security_group.tf**: Nesse arquivo há a **criação do acessos** ao ssh na **porta 22** apenas para o meu ip e o acesso a **porta 80**
<details><summary>Clique para expandir</summary>

```
resource "aws_security_group" "acesso-ssh" {
  name        = "acesso-ssh"
  description = "acesso-ssh"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = [],
      prefix_list_ids  = null,
      security_groups : null,
      self : null,
      description : "Libera dados da rede interna"
    }
  ]
}

resource "aws_security_group" "acesso-porta80" {
  name        = "acesso-porta80"
  description = "Acesso a porta HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = [],
      prefix_list_ids  = null,
      security_groups : null,
      self : null,
      description : "Libera dados da rede interna"
    }
  ]
}
```
</p>
</details>

<p>
**remote_state.tf**: Nesse arquivo há a **definição do backend** como S3 para armazenar as informações referente ao tfstate
<details><summary>Clique para expandir</summary>

```
terraform {
  backend "s3" {
    bucket = "tfstate-979937110395"
    key    = "state/terraform.tfstate"
    region = "sa-east-1"
  }
}
```
</p>
</details>

<p>
**ec2.tf**: Nesse arquivo há o provisionamento da ec2 com a utilização do módulo, um output pra informação o ip publico da instância e um recurso para você informar a sua chave ssh para acesso remoto a instância
> IMPORTANTE: caso você vá utilizar esse repositório e subi-lo em seu git pessoal, remova sua chave do campo **public_key**

<details><summary>Clique para expandir</summary>
<p>
```
provider "aws" {
  version = "~> 3.0"
  region  = "sa-east-1"
}

resource "aws_key_pair" "julio-key2" {
  key_name   = "julio-key2"
  public_key = "Insira aqui a sua chave"
}

module "instancia_ec2" {
  source                      = "./ec2_module"
  amis                         = var.amis
  instance_type               = var.instance_type
  key_name                    = var.key_name
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
  description = "Mostra os IPs publicos e privados da maquina criada."
  depends_on = [module.instancia_ec2]
}
```
</p>
</details>

