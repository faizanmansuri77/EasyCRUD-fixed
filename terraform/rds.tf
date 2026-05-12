resource "aws_security_group" "rds_sg" {
  name   = "rds-mariadb-sg"
  vpc_id = data.aws_vpc.default.id

  # Allow ALL inbound traffic

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ALL outbound traffic

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet" {
  name       = "easycrud-rds-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_db_instance" "mariadb" {
  identifier             = "easycrud-mariadb"

  allocated_storage      = 20

  engine                 = "mariadb"
  engine_version         = "11.8"

  instance_class         = "db.t4g.micro"

  db_name                = "easycruddb"

  username               = "admin"
  password               = "redhat123"

  publicly_accessible    = true
  skip_final_snapshot    = true
  multi_az               = false

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
