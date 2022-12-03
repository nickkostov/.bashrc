#!/usr/bin/env bash
alias tapout="terraform apply --auto-approve"
alias think="terraform plan"
## Kubernetes:
### everything should have the required namespace/component
alias k="kubectl"
alias kpods="kubectl get pods"
alias klog="kubectl logs"
alias knode="kubectl get nodes"

## Docker
alias dc="docker compose"
alias d="docker"

## SSH Kadanza Bastion:
alias prox="ssh -J gcp-bastion.kadanza.com"

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
