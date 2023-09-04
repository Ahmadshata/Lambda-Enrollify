import json
import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
import boto3

client = boto3.client('secretsmanager')
secret_response = client.get_secret_value(SecretId='lambda-secrets')
stored_secret = json.loads(secret_response['SecretString'])
api_key = stored_secret["API_KEY"]

def lambda_handler(event, context):
    message = Mail(
        from_email='4ata12@gmail.com',
        to_emails='ahmadesmailshata@gmail.com',
        subject='New user just got added',
        # html_content=f"""
        # <strong>User Added With Data:</strong> <br><br>
        # <strong>ID: </strong> {event['id']} <br> 
        # <strong>First Name: </strong> {event['first_name']} <br> 
        # <strong>Last Name:</strong> 
        # """
        html_content=f"""
        <strong>New user added with data:</strong><br><br>
        <table width="1000" style="border:1px solid #333">
            <tr style="border:1px solid #333">
                <th width="200" align="center" style="border:1px solid #333">ID</th>
                <th width="200" align="center" style="border:1px solid #333">First name</th>
                <th width="200" align="center" style="border:1px solid #333">Last name</th>
            </tr>
            <tr style="border:1px solid #333">
                <td align="center" style="border:1px solid #333">{event['id']}</td>
                <td align="center" style="border:1px solid #333">{event['first_name']}</td>
                <td align="center" style="border:1px solid #333">{event['last_name']}</td>
            </tr>
        </table>"""
        )
    try:
        # sg = SendGridAPIClient(os.environ.get('API_KEY'))
        sg = SendGridAPIClient(api_key)
        response = sg.send(message)
        print(response.status_code)
        print(response.body)
        print(response.headers)
    except Exception as e:
        print(e)
