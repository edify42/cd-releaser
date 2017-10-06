## Master assume role for API GW and lambda
resource "aws_iam_role" "cd_releaser_global" {
  name = "cd_releaser_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "apigateway.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_apigateway_invoke" {
  name = "lambda_apigateway_invoke"
  role = "${aws_iam_role.cd_releaser_global.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "lambda:InvokeFunction"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_dynamodb_access" {
  name = "lambda_dynamodb_access"
  role = "${aws_iam_role.cd_releaser_global.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "notneeded",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:DescribeTable",
                "dynamodb:GetItem",
                "dynamodb:GetRecords",
                "dynamodb:ListTables",
                "dynamodb:PutItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:UpdateItem",
                "dynamodb:UpdateTable"
            ],
            "Resource": [
                "${aws_dynamodb_table.cd_releaser.arn}"
            ]
        }
    ]
}
EOF
  depends_on = ["aws_dynamodb_table.cd_releaser"]
}
