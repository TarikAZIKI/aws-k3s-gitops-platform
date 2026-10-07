# --- GitHub Actions access through OIDC -----------------------------------------
# GitHub issues a short-lived signed token to each workflow run; AWS trusts that
# token instead of long-lived access keys stored as repository secrets.
#
# Disabled by default: accounts created with the new AWS sign-up experience belong
# to an AWS-managed organization whose SCP denies iam:CreateOpenIDConnectProvider.
# Set enable_github_oidc = true on a standard account to turn it on.

resource "aws_iam_openid_connect_provider" "github" {
  count = var.enable_github_oidc ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "github_plan_trust" {
  count = var.enable_github_oidc ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only pull requests and the main branch of this repository can assume the role.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repository}:pull_request",
        "repo:${var.github_repository}:ref:refs/heads/main",
      ]
    }
  }
}

resource "aws_iam_role" "github_plan" {
  count = var.enable_github_oidc ? 1 : 0

  name                 = "${var.project_name}-github-terraform-plan"
  assume_role_policy   = data.aws_iam_policy_document.github_plan_trust[0].json
  max_session_duration = 3600
}

# Read-only: enough for `terraform plan`, nothing that can change the account.
data "aws_iam_policy_document" "github_plan" {
  statement {
    sid = "DescribeInfrastructure"
    actions = [
      "ec2:Describe*",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:GetInstanceProfile",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "ReadState"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tfstate.arn]
  }

  statement {
    sid       = "ReadStateObjects"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/*"]
  }
}

resource "aws_iam_role_policy" "github_plan" {
  count = var.enable_github_oidc ? 1 : 0

  name   = "terraform-plan-read-only"
  role   = aws_iam_role.github_plan[0].id
  policy = data.aws_iam_policy_document.github_plan.json
}
