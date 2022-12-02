/*
    Role/trust policy for the ECS instances which will be
    created. 
*/

# Allow list/read of any bucket
# Allow full access only to result bucket
resource "aws_iam_policy" "ecs_s3_access" {
  name   = "ecs_s3_policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "S3:List*"
            ],
            "Resource": ["*"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "${aws_s3_bucket.results.arn}",
                "${aws_s3_bucket.results.arn}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy" "ecs_ebs" {
  name   = "AutoscaleEBS"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:createTags",
                "ec2:createVolume",
                "ec2:attachVolume",
                "ec2:deleteVolume",
                "ec2:modifyInstanceAttribute",
                "ec2:describeVolumes"
            ],
            "Resource": ["*"]
        }
    ]
}
EOF
}

resource "aws_iam_role" "ecs_instance" {

  name = "nextflow_ecs_instance_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        }
    }
    ]
}
EOF
}



resource "aws_iam_role_policy_attachment" "ecs_for_ec2" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_role_policy_attachment" "ecs_s3_access" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = aws_iam_policy.ecs_s3_access.arn
}

resource "aws_iam_role_policy_attachment" "ecs_ebs_access" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = aws_iam_policy.ecs_ebs.arn
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "nextflow_ecs_instance_role"
  role = aws_iam_role.ecs_instance.name
}


#####################################################################################################


resource "aws_iam_role" "aws_batch_service" {
  name = "nextflow_batch_service_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service": "batch.amazonaws.com"
            }
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "batch_service" {
  role       = aws_iam_role.aws_batch_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

#####################################################################################################

# This role and associated policy are needed to use the SPOT type
# compute environment for AWS Batch
# resource "aws_iam_role" "spot_fleet" {
#   name = "nextflow_spot_fleet_role"

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#     {
#         "Action": "sts:AssumeRole",
#         "Effect": "Allow",
#         "Principal": {
#             "Service": "spotfleet.amazonaws.com"
#         }
#     }
#     ]
# }
# EOF
# }


# resource "aws_iam_role_policy_attachment" "spot_fleet" {
#   role       = aws_iam_role.spot_fleet.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
# }
