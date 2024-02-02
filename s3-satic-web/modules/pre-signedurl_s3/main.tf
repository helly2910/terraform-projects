provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "signed_url_s3" {
  bucket = var.BucketName
  acl    = "private" // Set bucket ACL to private
}

resource "aws_s3_object" "object" {
  for_each = fileset("/home/helly-gtcsys/Documents/terraform/final s3 saticweb/modules/pre-signedurl_s3/assets", "**/*.*")

  bucket        = aws_s3_bucket.signed_url_s3.id
  key           = each.value
  source        = "/home/helly-gtcsys/Documents/terraform/final s3 saticweb/modules/pre-signedurl_s3/assets/${each.value}"
  storage_class = var.storage_class

  acl = "private" // Set ACL to private for each object

  content_type = lookup({
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "png"  = "image/png"
    # ...
  }, regex(".*\\.([^.]*)", lower(each.value))[0])

  etag = filemd5("/home/helly-gtcsys/Documents/terraform/final s3 saticweb/modules/pre-signedurl_s3/assets/${each.value}")

  depends_on = [aws_s3_bucket.signed_url_s3]
}

resource "null_resource" "signed_url" {
  for_each = aws_s3_object.object

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ${path.module}/signed_urls &&
      aws s3 presign s3://${aws_s3_bucket.signed_url_s3.bucket}/${each.value.key} --expires-in 3600 > ${path.module}/signed_urls/${each.value.key}
    EOT
  }

  triggers = {
    object_key = each.value.key
  }
}

locals {
  object_keys = [for obj in aws_s3_object.object : obj.key]
}

output "all_signed_urls" {
  value = [for obj_key in local.object_keys : file("${path.module}/signed_urls/${obj_key}")]
}
