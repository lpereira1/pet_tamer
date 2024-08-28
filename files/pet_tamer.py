import boto3
import os
import json

ssm = boto3.client('ssm')
ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    body = json.loads(event.get('body', '{}'))
    
    group = body.get('group')
    action = body.get('action')
    num_servers = int(body.get('num_servers', 1))
    stopservices = body.get('stopservices', [])
    
    if not group:
        return {"statusCode": 400, "body": json.dumps("Group is required")}
    
    for entry in group:
        account_id = entry.get('account')
        servicegroup = entry.get('servicegroup')  # Extract servicegroup directly
        
        if not servicegroup:
            return {"statusCode": 400, "body": json.dumps("Service group is required")}
        
        tag_key = "servicegroup"  # Enforce the use of the 'servicegroup' tag key
        tag_value = servicegroup  # Use the provided servicegroup value as the tag value
        
        # Retrieve the minimum servers running from SSM Parameter Store
        param_name = f"/pettamer/{servicegroup.replace(':', '_')}/min_servers_running"
        try:
            min_servers_running = int(ssm.get_parameter(Name=param_name)['Parameter']['Value'])
        except ssm.exceptions.ParameterNotFound:
            return {"statusCode": 400, "body": json.dumps(f"Parameter {param_name} not found in SSM")}

        sts_client = boto3.client('sts')
        assumed_role = sts_client.assume_role(
            RoleArn=f"arn:aws:iam::{account_id}:role/pettamer_target_role",
            RoleSessionName="LambdaExecution"
        )
        
        credentials = assumed_role['Credentials']
        
        ec2 = boto3.client(
            'ec2',
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['SessionToken'],
            region_name=os.environ.get('AWS_REGION', 'us-east-1')  # Assuming region is consistent
        )
        
        manage_instances(ec2, tag_key, tag_value, action, num_servers, min_servers_running, stopservices)

    return {"statusCode": 200, "body": json.dumps("Action completed successfully")}

def manage_instances(ec2, tag_key, tag_value, action, num_servers, min_servers_running, stopservices):
    instances = get_instances_by_tag(ec2, tag_key, tag_value)
    
    running_instances = [i['InstanceId'] for i in instances if i['State']['Name'] == 'running']
    stopped_instances = [i['InstanceId'] for i in instances if i['State']['Name'] == 'stopped']

    if action == 'start':
        instances_to_start = stopped_instances[:num_servers]
        if instances_to_start:
            ec2.start_instances(InstanceIds=instances_to_start)
            print(f"Instances started: {instances_to_start}")

    elif action == 'stop':
        if len(running_instances) > min_servers_running:
            max_instances_to_stop = len(running_instances) - min_servers_running
            instances_to_stop = running_instances[:min(num_servers, max_instances_to_stop)]
            if instances_to_stop:
                if stopservices:
                    stop_services_on_instances(ec2, instances_to_stop, stopservices)
                ec2.stop_instances(InstanceIds=instances_to_stop)
                print(f"Instances stopped: {instances_to_stop}")

def stop_services_on_instances(ec2, instance_ids, stopservices):
    for instance_id in instance_ids:
        # Describe the instance to find out the platform (Windows or Linux)
        instance_info = ec2.describe_instances(InstanceIds=[instance_id])['Reservations'][0]['Instances'][0]
        platform = instance_info.get('Platform', 'linux').lower()  # Default to Linux if 'Platform' is not present
        
        timeout = 600  # 10 minutes in seconds
        
        if platform == 'windows':
            commands = [
                f"""
                Get-Service -Name *{service}* | ForEach-Object {{
                    Stop-Service -Name $_.Name -Force
                    $start = Get-Date
                    do {{
                        $status = (Get-Service -Name $_.Name).Status
                        Start-Sleep -Seconds 5
                    }} while ($status -ne 'Stopped' -and ((Get-Date) - $start).TotalSeconds -lt {timeout})
                }}
                """ for service in stopservices
            ]
            ssm_document = "AWS-RunPowerShellScript"
        else:  # Assuming Linux
            commands = [
                f"""
                for svc in $(systemctl list-units --type=service --state=running | grep {service} | awk '{{print $1}}'); do
                    sudo systemctl stop $svc
                    start_time=$(date +%s)
                    while systemctl is-active --quiet $svc && [ $(($(date +%s) - start_time)) -lt {timeout} ]; do
                        sleep 5
                    done
                done
                """ for service in stopservices
            ]
            ssm_document = "AWS-RunShellScript"
        
        ssm.send_command(
            InstanceIds=[instance_id],
            DocumentName=ssm_document,
            Parameters={'commands': commands},
        )

def get_instances_by_tag(ec2, tag_key, tag_value):
    response = ec2.describe_instances(
        Filters=[
            {
                'Name': f'tag:{tag_key}',
                'Values': [tag_value]
            }
        ]
    )
    
    instances = []
    for reservation in response['Reservations']:
        instances.extend(reservation['Instances'])
    return instances
