import subprocess
try:
    with open('/usr/local/google/home/avantikapandey/vscode codes/multiple_bucket_creation/descriptors.json', 'r') as f:
        data = f.read()
    import json
    for i in json.loads(data):
        if 'webhook' in i['type']:
            print(i)
except Exception as e:
    print(e)
