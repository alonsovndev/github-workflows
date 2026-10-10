# Illustrative values only. Replace the account ID, repository, and policies before use.
roles = {
  "example-tf-plan" = {
    subjects            = ["repo:alonsovndev/example-infra:pull_request"]
    managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  }
  "example-tf-apply" = {
    subjects            = ["repo:alonsovndev/example-infra:environment:prod"]
    managed_policy_arns = [] # attach the narrowest policy that covers what the stack manages
  }
  "example-ecr-push" = {
    subjects           = ["repo:alonsovndev/example-api:environment:prod"]
    inline_policy_json = <<-JSON
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
          },
          {
            "Effect": "Allow",
            "Action": [
              "ecr:BatchCheckLayerAvailability",
              "ecr:CompleteLayerUpload",
              "ecr:InitiateLayerUpload",
              "ecr:PutImage",
              "ecr:UploadLayerPart"
            ],
            "Resource": "arn:aws:ecr:us-east-1:111111111111:repository/example-api"
          }
        ]
      }
    JSON
  }
  "example-ecs-deploy" = {
    subjects           = ["repo:alonsovndev/example-api:environment:prod"]
    inline_policy_json = <<-JSON
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
              "ecs:DescribeServices",
              "ecs:DescribeTaskDefinition",
              "ecs:RegisterTaskDefinition",
              "ecs:UpdateService"
            ],
            "Resource": "*"
          },
          {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": [
              "arn:aws:iam::111111111111:role/example-api-task",
              "arn:aws:iam::111111111111:role/example-api-execution"
            ]
          }
        ]
      }
    JSON
  }
}
