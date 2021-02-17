module "stage1_ingest_logging_policy" {
  source        = "./modules/aws_lambda_logging_policy"
  function_name = aws_lambda_function.stage1_ingest.function_name
}

module "stage2_clean_logging_policy" {
  source        = "./modules/aws_lambda_logging_policy"
  function_name = aws_lambda_function.stage2_clean.function_name
}

module "stage3_model_status_logging_policy" {
  source        = "./modules/aws_lambda_logging_policy"
  function_name = aws_lambda_function.stage3_model_status.function_name
}

module "stage3_model_trigger_logging_policy" {
  source        = "./modules/aws_lambda_logging_policy"
  function_name = aws_lambda_function.stage3_model_trigger.function_name
}
