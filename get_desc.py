import json, subprocess
output = subprocess.check_output("gcloud monitoring channel-descriptors list --format=json", shell=True)
desc = json.loads(output)
for d in desc:
    if d['name'].endswith('webhook_tokenauth'):
        print(json.dumps(d, indent=2))
        
