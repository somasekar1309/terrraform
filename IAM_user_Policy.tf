provider "aws" {
  region     = "sa-east-1"
  access_key = "AKIAWCOUOBMYT6XSM6WT"
  secret_key = "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"
}


# creating the IAM user

resource "aws_iam_user" "oneh" {
  name = "waste"
  path = "/system/"

  tags = {
    tag-key = "firstuser"
  }
  
}


# creating the policy for the user

resource "aws_iam_user_policy" "lb_ro" {
  name = "waste"
  user = aws_iam_user.oneh.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# creating the access key for the user

resource "aws_iam_access_key" "lbe" {
  user    = aws_iam_user.one.name
}

# creating the secret key for the user

resource "random_pet" "secret_key" {
  length    = 4 # Length of the secret key
  separator = "-" #and the separator parameter is set to "-" to separate the words in the generated key.
}

#outputs
output "secret_key" {
  value = random_pet.secret_key.id
}

output "ib" {
  value = aws_iam_access_key.lbe.id
}








# attaching the policy for the user to access only one region

resource "aws_iam_user_policy" "lb_roi" {
  name = "access_only_particular_region"
  user = aws_iam_user.so.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion":[ 
                        "ap-south-1"
                        "us-east-1"
                    ]
                                 
                }
            }
        }
    ]
}
EOF
}