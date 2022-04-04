provider "aws" {
  region     = "us-east-1"
}



resource "aws_vpc" "main" {
  cidr_block = "40.0.0.0/16"
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "40.0.1.0/24"

  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "40.0.2.0/24"

  tags = {
    Name = "subnet2"
  }
}




resource "aws_internet_gateway" "public-subnet-igw" {
  vpc_id  = aws_vpc.main.id

tags = {
        Name = "public-subnet-igw"
    }

}


resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.main.id

  route {
     cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public-subnet-igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}


resource "aws_route_table_association" "public-subnet1-association" {
  subnet_id= aws_subnet.subnet1.id
  route_table_id = aws_route_table.public-route.id
}



resource "aws_route_table_association" "public-subnet2-association" {
  subnet_id= aws_subnet.subnet2.id
  route_table_id = aws_route_table.public-route.id
}





resource "aws_s3_bucket" "b" {
  bucket = "my-bucket-omar-hamdaa"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

terraform {
  backend "s3" {
    bucket   = "my-bucket-omar-hamdaa"
    key      = "terraform-state"
    region   = "us-east-1"
  }

}


resource "aws_instance" "web" {
  ami = var.myami
  instance_type = var.myinstancetype
  key_name= var.key_name
  vpc_security_group_ids = [aws_security_group.SG_OM.id]
  tags = {
  Name = "production"
    }



}

resource "aws_security_group" "SG_OM" {
  name        = "SG_OM"
  description = "Allow ssh only"


  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_tls"
  }
}






resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
   public_key = file(var.public_key)
}


