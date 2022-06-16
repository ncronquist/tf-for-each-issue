variable "name" {}
variable "sns_arns" {
  type = list(string)
}

locals {
  sns_arns_map = {for idx, val in var.sns_arns: idx => val}
}

resource "aws_sqs_queue" "this" {
  name = var.name
}

resource "aws_sns_topic_subscription" "this" {
  # for_each = toset(var.sns_arns)
  for_each = local.sns_arns_map

  topic_arn = each.value
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.this.arn
}

resource "aws_sqs_queue_policy" "this" {
  count = length(var.sns_arns) > 0 ? 1 : 0

  queue_url = aws_sqs_queue.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = var.name,
    Statement = [
      {
        Sid    = "EventSubscription",
        Effect = "Allow",
        Principal = {
          Service = [
            "sns.amazonaws.com",
          ]
        },
        Action   = "sqs:SendMessage",
        Resource = aws_sqs_queue.this.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = var.sns_arns
          }
        }
      }
    ]
  })
}
