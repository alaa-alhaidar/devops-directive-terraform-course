variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "m5.xlarge"
  sensitive   = false
}

variable "key_name" {
  description = "key name pem file"
  type        = string
  default     = "alaa.alhaidar_eu"
  sensitive   = true
}

variable "output_path" {
  description = "path to save result"
  type        = string
  default     = "s3://alaa-bucket/output"
  sensitive   = false
}
