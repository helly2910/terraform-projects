

# module "web_hosting" {
#   source = "/home/helly-gtcsys/Documents/terraform/final s3 saticweb/modules/staticweb_hosting"
#   BucketName  = "webhosting-using-terraform"
  
# }

# output "website_endpoint" {
#   value = module.web_hosting.website_endpoint
# }

# module "image_storing_s3" {
#   source = "./modules/image_storing_s3"
#   BucketName = "imagestorings3terraform"
#   storage_class = "STANDARD"
#   versioning_configuration = "Disabled"
# }

# output "image_storing_s3_output" {
#   value = module.image_storing_s3.bucket_name
  
# }

provider "aws" {
  region = "us-east-1"
}

module "pre-signed-url-s3" {
  source = "./modules/pre-signedurl_s3"

  BucketName    = "signedurlterraform"  # Replace with your actual bucket name
  storage_class = "STANDARD"           # Replace with your desired storage class
}

output "all_signed_urls" {
  value = module.pre-signed-url-s3
}

