from fastapi import FastAPI
import boto3

app = FastAPI()


dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
table = dynamodb.Table("DemoTab")

@app.get("/")
def read_root():

    response = table.scan()
    return response.get("Items", [])
    