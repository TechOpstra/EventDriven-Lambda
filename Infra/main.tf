
module "Eventbridge" {
  source         = "./modules/Eventbridge"
  event_bus_name = var.event_bus_name
}

module "lambda" {
  source               = "./modules/lambda"
  event_bus_arn        = module.Eventbridge.event_bus_arn
  lambda_function_name = var.lambda_function_name

}

module "api_gateway" {
  source = "./modules/api_gateway"
  #lambda_function_arn = module.lambda.lambda_function_arn
  api_gateway_stage_name = var.api_gateway_stage_name
  lambda_invoke_arn      = module.lambda.invoke_arn
  lambda_function_name   = module.lambda.function_name
}
