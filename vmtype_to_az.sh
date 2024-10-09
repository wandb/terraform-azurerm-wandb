#! /usr/bin/env bash

# Given a Azure VM instance type and a region return the availability zones that support the instance type

# Example:
# ./vmtype_to_az.sh Standard_D2_v3 westeurope
# 
# Output:
# ["1", "2", "3"]

# Copy script arguments to named environment variables
VM_TYPE="$1"
REGION="$2"
NUM_ZONES="$3"

# Check if both arguments are provided
if [ -z "$VM_TYPE" ] || [ -z "$REGION" ]; then
    echo "Error: Both VM type and region must be provided." >&2
    echo "Usage: $0 <vm_type> <region> <num_zones>" >&2
    exit 1
fi

# Default to 3 zones if not specified
if [ -z "$NUM_ZONES" ]; then
    NUM_ZONES=3
fi

# Query Azure CLI for availability zones in the region for the specified VM type
ZONES=$(az vm list-skus --location "$REGION" --size "$VM_TYPE" --query "[0].locationInfo[0].zones" -o json | jq -r -c "sort | .[0:$NUM_ZONES]")

# Check if the query returned any results
if [ -z "$ZONES" ] || [ "$ZONES" == "null" ]; then
    echo "Error: No availability zones found for VM type $VM_TYPE in region $REGION." >&2
    exit 1
fi

# Output the result
jq -n --arg zones "$ZONES" '{"zones":$zones}'
