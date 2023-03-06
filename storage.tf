resource "aws_s3_bucket" "results" {
    bucket = "${local.common_tags.Name}-storage"
}