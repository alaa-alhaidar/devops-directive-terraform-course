output "web_server_count" {
  description = "Number of web servers provisioned"
  value       = length(aws_emr_cluster.example.id)
}
output "aws_vpc-default_vpc-id" {
  description = "Number of web servers provisioned"
  value       = data.aws_vpc.default_vpc.id
}
output "cidr_block" {
  description = "Number of web servers provisioned"
  value       = data.aws_vpc.default_vpc.cidr_block
}