def lambda_handler(event, context):
    print("Hello! Lambda function triggered by CloudWatch Events.")
    return {"statusCode": 200, "body": "Lambda executed successfully!"}
