locals {
  namespace = kubernetes_namespace_v1.external_secrets.metadata[0].name
}

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

resource "kubernetes_namespace_v1" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
}

resource "aws_iam_user" "eso_user" {
  name = "external-secrets"
}

resource "aws_iam_policy" "eso_policy" {
  name        = "external-secrets-policy"
  description = "Policy for External Secrets Operator to access AWS Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Action" : [
          "secretsmanager:ListSecrets",
          "secretsmanager:BatchGetSecretValue"
        ],
        "Resource" : "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource": [
          "arn:aws:secretsmanager:${data.aws_region.this.region}:${data.aws_caller_identity.this.account_id}:secret:*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "eso_policy_attachment" {
  user       = aws_iam_user.eso_user.name
  policy_arn = aws_iam_policy.eso_policy.arn
}

resource "aws_iam_access_key" "eso_access_key" {
  user = aws_iam_user.eso_user.name
}

resource "kubernetes_secret_v1" "eso_aws_access_key" {
  metadata {
    name      = "eso-aws-secret"
    namespace = local.namespace
  }

  data = {
    access_key = aws_iam_access_key.eso_access_key.id
    secret_key = aws_iam_access_key.eso_access_key.secret
  }

  type = "Opaque"
}


