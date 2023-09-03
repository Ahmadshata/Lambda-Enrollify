import json
import boto3

dynamo = boto3.resource('dynamodb')
table = dynamo.Table('onboarding')
lambda_client = boto3.client('lambda')

def lambda_handler(event, context):
    try:
        requestBody = json.loads(event["body"])
        response=table.put_item(Item=requestBody)
        msg = {'id': requestBody['id'], 'first_name': requestBody['first name'], 'last_name': requestBody['last name']}
        invoke_response = lambda_client.invoke(FunctionName="test-sendgrid", InvocationType='Event', Payload=json.dumps(msg))

        return {
            'statusCode': 200,
            'body': json.dumps(requestBody)
    }
    except:
        raise
    


