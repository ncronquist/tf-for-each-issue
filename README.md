# Minimal Repro for Terraform for_each Meta-Argument Issue

The Terraform for_each meta-argument doesn't seem to work when the argument
value is a list of resources (converted to a set) that have not yet been
created.


## Repro Instructions

- Clone this repo
- Configure your local AWS credentials
- From the root initialize Terraform and run a plan

```sh
terraform init

terraform plan
```

- That plan should succeed
- In the `modules/sqs-q-subscription/main.tf` file:
  - uncomment the `for_each` on line 15 which uses the initial list and
  - converts it to a set
  - comment out line 16 which is using the list after having converted it to a
    map
- Run another Terraform plan

```sh
terraform plan
```

- You should receive the following error:

```
│ Error: Invalid for_each argument
│
│   on modules/sqs-q-subscription/main.tf line 15, in resource "aws_sns_topic_subscription" "this":
│   15:   for_each = toset(var.sns_arns)
│     ├────────────────
│     │ var.sns_arns is list of string with 1 element
│
│ The "for_each" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many
│ instances will be created. To work around this, use the -target argument to first apply only the resources that the for_each
│ depends on.
```
