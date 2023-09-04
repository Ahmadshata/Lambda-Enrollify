import json
import boto3

client = boto3.client('secretsmanager')
secret_response = client.get_secret_value(SecretId='lambda-secrets')
stored_secret = json.loads(secret_response['SecretString'])
token = stored_secret["JWT_TOKEN"]

def lambda_handler(event, context):
    auth = 'Deny'
    if event['authorizationToken'] == token:
        auth = 'Allow'
    else:
        auth = 'Deny'
    
    #3 - Construct and return the response
    authResponse = { "principalId": "1", "policyDocument": { "Version": "2012-10-17", "Statement": [{"Action": "execute-api:Invoke", "Resource": ["arn:aws:execute-api:eu-west-2:253823388836:*/*/*"], "Effect": auth}] }}
    return authResponse
