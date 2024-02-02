provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "image_upload_s3" {
    bucket = var.BucketName
    
}
#bucketownership
resource "aws_s3_bucket_ownership_controls" "image_upload_s3_own" {
  bucket = aws_s3_bucket.image_upload_s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Remove public access block
resource "aws_s3_bucket_public_access_block" "Bucketpublicacc" {
  bucket = aws_s3_bucket.image_upload_s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "image_upload_s3_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.image_upload_s3_own,
    aws_s3_bucket_public_access_block.Bucketpublicacc,
  ]

  bucket = aws_s3_bucket.image_upload_s3.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "versioning_configuration" {
  bucket = aws_s3_bucket.image_upload_s3.id
  versioning_configuration {
    status = var.versioning_configuration
  }
}

resource "aws_s3_bucket_object" "object" {
    for_each = fileset("/home/helly-gtcsys/Documents/terraform/final s3 saticweb/modules/image_storing_s3/assets", "**/*.*")
    bucket = aws_s3_bucket.image_upload_s3.id
    key = each.value
    source = "/home/helly-gtcsys/Documents/terraform/final s3 saticweb/modules/image_storing_s3/assets/${each.value}"
    storage_class = var.storage_class
    

    acl    = "public-read"
    content_type = lookup({
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "png"  = "image/png"
    

    # Add more extensions and corresponding content types as needed
  }, regex(".*\\.([^.]*)", lower(each.value))[0])


  etag = filemd5("/home/helly-gtcsys/Documents/terraform/final s3 saticweb/modules/image_storing_s3/assets/${each.value}")
}
