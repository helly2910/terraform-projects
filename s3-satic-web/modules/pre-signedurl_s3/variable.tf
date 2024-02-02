variable "BucketName" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "storage_class" {
  description = "The storage class for S3 objects"
  type        = string
  default     = "STANDARD"
}
