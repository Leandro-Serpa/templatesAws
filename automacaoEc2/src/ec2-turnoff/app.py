import boto3
region = 'sa-east-1'
instances = ['i-00000000000']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.stop_instances(InstanceIds=instances)
    print('stopped your instance: ' + str(instances))