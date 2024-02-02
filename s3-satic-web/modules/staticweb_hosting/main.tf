provider "aws" {
  region = "us-east-1"
}

# Creating S3 bucket
resource "aws_s3_bucket" "MyBucket" {
  bucket = var.BucketName
  
}

#bucketownership
resource "aws_s3_bucket_ownership_controls" "MyBucketown" {
  bucket = aws_s3_bucket.MyBucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Remove public access block
resource "aws_s3_bucket_public_access_block" "Bucketpublicacc" {
  bucket = aws_s3_bucket.MyBucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "MyBucketacl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.MyBucketown,
    aws_s3_bucket_public_access_block.Bucketpublicacc,
  ]

  bucket = aws_s3_bucket.MyBucket.id
  acl    = "public-read"
}




#website_configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.MyBucket.id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [ aws_s3_bucket_acl.MyBucketacl ]
}


resource "aws_s3_bucket_object" "website" {
  for_each = fileset("/home/helly-gtcsys/Documents/terraform/final s3 saticweb/modules/website", "**/*.*")
  bucket = aws_s3_bucket.MyBucket.id
  key = each.value
  source = "/home/helly-gtcsys/Documents/terraform/final s3 saticweb/modules/website/${each.value}"
  
  acl    = "public-read"
  content_type = lookup({
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "png"  = "image/png"
    "html" = "text/html"
    "css" = "text/css"

    # Add more extensions and corresponding content types as needed
  }, regex(".*\\.([^.]*)", lower(each.value))[0])


  etag = filemd5("/home/helly-gtcsys/Documents/terraform/final s3 saticweb/modules/website/${each.value}")
}