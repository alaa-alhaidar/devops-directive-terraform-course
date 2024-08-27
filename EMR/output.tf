output "web_server_count" {
  description = "Number of web servers provisioned"
  value       = length(aws_emr_cluster.example.id)
}