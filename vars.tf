variable "ami_id" {
  description = "The AMI ID to use in the AWS Batch compute environment. Should be compatible with ECS."
  type        = string
}

variable "result_bucket" {
  description = "A bucket into which we place results from pipeline tasks."
  type        = string
}
