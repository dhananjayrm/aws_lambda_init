provider "aws" {
  region                   = "eu-central-1"
  shared_credentials_files = ["~/.aws/credentials"]
}

resource "aws_iam_role" "lambda_role-1" {
  name                = "terraform_aws_lambda_role-1"
  assume_role_policy = <<EOF
    {
        "Version":"2012-10-17",
        "Statement":[
            {
                "Action":"sts:AssumeRole",
                "Principal":{
                    "Service":"lambda.amazonaws.com"
                },
                "Effect":"Allow",
                "Sid":""
            }
        ]
    }
    EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda-1" {
  name        = "aws_iam_policy_for_terraform_aws_lambda_role-1"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy = <<EOF
{
     "Version": "2012-10-17",
     "Statement": [
         {
             "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
             ],
             "Resource": "arn:aws:logs:*:*:*",
             "Effect": "Allow"
         }
     ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role-1" {
  role       = aws_iam_role.lambda_role-1.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda-1.arn
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/hello-python-1.zip"
}

resource "aws_lambda_function" "terraform_lambda_func-1" {
function_name = "Test-lambda-function-1"
  filename      = "${path.module}/python/hello-python-1.zip"
  runtime = "python3.8"
  handler = "hello-python-1.lambda_handler_1"
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
  role             = aws_iam_role.lambda_role-1.arn

}
