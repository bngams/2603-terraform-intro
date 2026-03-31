##############################
#### NETWORKING RESOURCES
##############################

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "wordpress-vpc"
  }
}

# Internet Gateway
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "wordpress-igw"
#   }
# }

# Sous-réseau public (pour EC2)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "wordpress-public-subnet"
  }
}

# Sous-réseau privé (pour RDS)
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "wordpress-private-subnet"
  }
}

# Sous-réseau privé supplémentaire pour RDS (requis par AWS - nécessite 2 AZs selon le tiers de RDS choisi)
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-3b"

  tags = {
    Name = "wordpress-private-subnet-2"
  }
}

# Security Group pour EC2
resource "aws_security_group" "wp_ec2_sg" {
  name        = "wordpress-ec2-sg"
  description = "Security group for WordPress EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] # Restrict SSH access to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-ec2-sg"
  }
}

# Security Group pour RDS
resource "aws_security_group" "wp_rds_sg" {
  name        = "wordpress-rds-sg"
  description = "Security group for WordPress RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wp_ec2_sg.id] # Allow MySQL only from EC2 SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-rds-sg"
  }
}

####################################
#### RDS INSTANCE FOR WORDPRESS
####################################

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private_2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "wp_rds_instance" {
  allocated_storage    = 10
  db_name              = "wordpressdb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  multi_az              = false
  
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.wp_rds_sg.id]
  
  publicly_accessible = false
}


####################################
#### S3 BUCKET FOR WORDPRESS BACKUP
####################################
# TODO: Ajouter un bucket S3 pour
# les fichiers / sauvegardes de WordPress

####################################
#### EC2 INSTANCE FOR WORDPRESS
####################################

# Fetch existing SSH key pair
data "aws_key_pair" "existing_key" {
  key_name = "cesi-hosting-2601"
}

# We can use an AMI Data source
# otherwise find the AMI ID manually and hardcode it (not recommended)
# data "aws_ami" "ubuntu_ami" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu-noble-numbat-24.04-amd64-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

resource "aws_instance" "wp_ec2_instance" {
  # prefer using a data source for the AMI to ensure it stays up to date and is correct for the region, rather than hardcoding an AMI ID which may not be valid in all regions or may become outdated
  # ami = var.my_ami_id ou "ami-0dab98137e5c11cb8" # Fallback to hardcoded AMI if variable is not set
  ami = "ami-08c0fc05da0179c6e"
  # ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = data.aws_key_pair.existing_key.key_name

  security_groups = [ aws_security_group.wp_ec2_sg.id ]

  tags = {
    Name = "wordpress-ec2-instance"
  }

  depends_on = [ aws_db_instance.wp_rds_instance ]
}