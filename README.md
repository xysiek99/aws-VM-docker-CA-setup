# aws-VM-docker-CA-setup

To deploy run:

`./run-all.sh`

Before running you need to modify files"
- `TF-setup/providers.tf` - you need to specify variables in `provider "aws"` curly braces
- `TF-setup/variables.tf` - you need to specify your home public IP address in  variable `variable "home_ip"` - with current your VM will be reachable from any IP address
