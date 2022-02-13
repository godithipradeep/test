resource "aws_internet_gateway" "my_igw" {
    vpc_id = "${aws_vpc.my_vpc.id}"
  
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "${var.vpc_cidr}"
    instance_tenancy = "${var.tenancy}"
  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "${var.subnet_cidr}"
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "my_route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }


  tags = {
    Name = "my_route"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.my_route.id
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  vpc_id      = aws_vpc.my_vpc.id

    ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.ssh_cidr}"]

  }

  ingress {
    description      = "Allow jenkins"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "jenkins_sg"
  }
}

resource "aws_security_group" "nginx_sg" {
  name        = "nginx_sg"
  vpc_id      = aws_vpc.my_vpc.id
  depends_on = [
    aws_instance.jenkins
  ]

  ingress {
    description      = "Allow http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

    ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [ "${aws_security_group.jenkins_sg.id}" ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "nginx_sg"
  }
}

resource "aws_instance" "jenkins" {
    ami = "ami-0e472ba40eb589f49"
    instance_type = "${var.instance_type}"
    vpc_security_group_ids = [ "${aws_security_group.jenkins_sg.id}" ]
    subnet_id = "${aws_subnet.public.id}"
    key_name = "${var.key_name}"
    user_data = "${file("ansible.sh")}"
    tags = {
      "Name" = "jenkins"
    }
}

resource "aws_instance" "nginx" {
    ami = "ami-0e472ba40eb589f49"
    instance_type = "${var.instance_type}"
    vpc_security_group_ids = [ "${aws_security_group.nginx_sg.id}" ]
    subnet_id = "${aws_subnet.public.id}"
    key_name = "${var.key_name}"
    tags = {
      "Name" = "nginx"
    }
}

output "Jenkins_Ansible_server_ip" {
    value = aws_instance.jenkins.public_ip
  
}

output "nginx_ip" {
    value = aws_instance.nginx.public_ip
  
}

output "nginx_private_ip" {
    value = aws_instance.nginx.private_ip
  
}

