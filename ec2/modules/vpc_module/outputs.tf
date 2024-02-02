output "vpc_id" {
  value = aws_vpc.example_vpc.id
}

output "public_subnet_id" {
    value = aws_subnet.example_subnet1.id
  
}