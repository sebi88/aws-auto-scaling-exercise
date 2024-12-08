import boto3
from datetime import datetime
import json
import os

# Initialize SQS client
sqs = boto3.client('sqs')

# Get the SQS queue URL from the environment variable (set in Lambda console)
QUEUE_URL = os.environ['SQS_URL']

def send_message(message_body):
    """
    Send a message to the SQS queue.
    """
    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=json.dumps(message_body)
    )

def lambda_handler(event, context):
    """
    Lambda function entry point. Sends as many messages as the current time's minute part, 
    or none if less than 10
    """
    num_messages = datetime.now().minute
    if num_messages < 10:
        num_messages = 0

    print(f"Sending {num_messages} messages to SQS.")
    # Send the messages to the SQS queue
    for i in range(num_messages):
        message_body = {'message_id': i, 'content': f'Random message {i}'}
        send_message(message_body)
        print(f"Sent message {i} to SQS.")

    return {
        'statusCode': 200,
        'body': json.dumps(f"Sent {num_messages} messages.")
    }
