variable "ami_id" {
  description = "The AMI ID to use in the AWS Batch compute environment. Should be compatible with ECS."
  type        = string
}

variable "instance_type_choices" {
  description = "A list of strings giving the EC2 instance types that we can choose from. The default value will allow AWS to create the instances, additionally constrained by the maximum number of vCPUs."
  type        = list(any)
  default     = ["optimal"]
}

variable "max_vcpus" {
  description = "The maximum number of vCPUS available in the AWS Batch compute environment."
  type        = number
  default     = 64
}
