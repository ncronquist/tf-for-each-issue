locals {
  name = "nick-foo"
}

resource "aws_sns_topic" "this" {
  name = local.name
}

module "sqs_q_subscription" {
  source = "./modules/sqs-q-subscription"

  name = local.name
  sns_arns = [
    aws_sns_topic.this.arn
  ]
}
