import sys
import yaml

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} IP_ADDR CONFIG_NAME", file=sys.stderr)
        sys.exit(1)

    ip_addr = sys.argv[1]
    name = sys.argv[2]

    # Read YAML data from stdin
    try:
        data = yaml.safe_load(sys.stdin)
    except yaml.YAMLError as exc:
        print(f"Error parsing YAML input: {exc}", file=sys.stderr)
        sys.exit(1)

    # Update the KUBECONFIG fields to ensure they are unique
    for cluster_entry in data['clusters']:
        cluster_entry['cluster']['server'] = f'https://{ip_addr}:6443'
        cluster_entry['name'] = name

    for context_entry in data['contexts']:
        context_entry['context']['cluster'] = name
        context_entry['context']['user'] = name + '_user'
        context_entry['name'] = name

    data['current-context'] = name

    for user_entry in data['users']:
        user_entry['name'] = name + '_user'

    # Write updated YAML to stdout
    try:
        yaml.dump(data, sys.stdout, default_flow_style=False)
    except yaml.YAMLError as exc:
        print(f"Error writing YAML output: {exc}", file=sys.stderr)
        sys.exit(1)

main()