resource "null_resource" "build_lambda_layers" {

  triggers = {

    layer_build = filemd5("${local.layers_path}/package.json")
  }

  provisioner "local-exec" {

    working_dir = local.layers_path
    command     = "npm install --production && cd ../ && zip -9 -r --quiet ${local.layer_name} *"
  }

}

resource "aws_lambda_layer_version" "join" {

  layer_name          = "join-layer"
  description         = "join: 17.3.0"
  filename            = "${local.layers_path}/../${local.layer_name}"
  compatible_runtimes = ["nodejs14.x"]
  depends_on = [
    null_resource.build_lambda_layers
  ]
}

data "archive_file" "s3" {

  output_path = "file/s3-artefact.zip"
  source_file = "${local.lambdas_path}/s3/index.js"
  type        = "zip"

}

resource "aws_lambda_function" "s3" {

  function_name = "s3"
  handler       = "index".handler
  role          = aws_iam_role.s3.arn
  runtime       = "nodejs14.x"

  filename = data.archive_file.s3.output_path

  source_code_hash = data.archive_file.s3.output_base64sha256

  tags = local.common_tags

  layers = [aws_lambda_layer_version.join.arn]
}


resource "aws_lambda_function" "dynamo" {

  function_name = "dynamo"
  handler       = "index.handler"
  role          = aws_iam_role.dynamo.arn
  runtime       = "nodejs14.x"

  filename         = data.archive_file.dynamo.output_path
  source_code_hash = data.archive_file.dynamo.output_base64sha256

  timeout     = 30
  memory_size = 128

  environment {
    variables = {

      TABLE = aws_dynamodb_table.this.name
    }
  }

}
data "archive_file" "dynamo" {

  type        = "zip"
  source_file = "${local.lambdas_path}/dynamo/index.js"
  output_path = "files/dynamo-artefact.zip"


}

resource "aws_lambda_permission" "s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.todo.arn
}
