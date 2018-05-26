# Setup the environment for secrets
project_dir=$(pwd)

encfs "$project_dir/.secrets" "$project_dir/secrets"

source secrets/aws

# Unset ssh-agent to avoid too many keys
unset SSH_AUTH_SOCK SSH_AGENT_PID
