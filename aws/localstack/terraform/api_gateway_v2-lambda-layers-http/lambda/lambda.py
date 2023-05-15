import uuid

def handler(event, context):
    id = str(uuid.uuid4())
    return {
        'statusCode': 200,
        'body': f'Hello, your ID is {id}'
    }
