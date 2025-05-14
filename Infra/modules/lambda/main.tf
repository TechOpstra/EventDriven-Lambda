resource "aws_lambda_function" "this" {
  function_name = var.lambda_function_name
  runtime       = "python3.9"
  handler       = "lambda_payload.lambda_handler"
  role          = aws_iam_role.lambda_basic_exec.arn

  source_code_hash = filebase64sha256("lambda_payload.zip")
  filename         = "lambda_payload.zip"
}

resource "aws_iam_role" "lambda_basic_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_basic_exec" {
  role = aws_iam_role.lambda_basic_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = "events:PutEvents",
        Effect = "Allow",
        Resource = var.event_bus_arn
      },
      {
        # Adding SQS full access
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ListQueues",
          "sqs:PurgingQueue",
          "sqs:ListQueueTags",
          "sqs:TagQueue"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        # Adding EventBridge full access
        Action = "events:*",
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}


output "lambda_function_arn" {
  value = aws_lambda_function.this.arn
}

output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.this.function_name
}
