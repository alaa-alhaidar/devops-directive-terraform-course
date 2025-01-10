variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "m5.xlarge"
  sensitive   = false
}
variable "subnet" {
  description = "subnet id"
  type        = string
  default     = "subnet-04b4c37d24693cf70"
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
