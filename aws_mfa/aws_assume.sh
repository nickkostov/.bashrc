#!/usr/bin/env bash
set -o pipefail

# Source common functions
function pretty_echo() {
    echo "#---------------------------------------"
    echo "$1"
    echo -e "#---------------------------------------\n"    
}

# Vars
mfa_credentials_file=~/.aws/mfa_credentials
iam_account="962932245445" # This is pretty much hardcoded
role_arn_example="arn:aws:iam::112233445566:role/ptc_dev_role"

if [ ! -f ~/.aws/mfa_credentials ]; then
    pretty_echo "Populating $mfa_credentials_file file"
    
    # IAM username
    echo -n "Enter your IAM username: " >&2
    read iam_username

    if [ -z "$iam_username" ]; then
        echo "Invalid username!"
        exit 255
    fi
    
    # MFA profile from ~/.aws/credentials
    echo -n "Enter your IAM profile from ~/.aws/credentials: " >&2
    read -r mfa_profile
    
    if [ -z "$mfa_profile" ]; then
        echo "Empty profile name!"
        exit 255
    else
       grep "\[$mfa_profile\]" ~/.aws/credentials
       if [ $? -ne 0 ]; then echo "Invalid profile name! Please input a valid IAM profile!"; exit 255; fi
    fi

    # Populate the credentials file
    echo "iam_username=$iam_username" >  $mfa_credentials_file
    echo "mfa_profile=$mfa_profile"   >> $mfa_credentials_file
    echo "role_arn=$role_arn_example" >> $mfa_credentials_file
fi

pretty_echo "Reading $mfa_credentials_file"

iam_username=$(grep iam_username $mfa_credentials_file | cut -f2 -d=)
mfa_profile=$(grep mfa_profile $mfa_credentials_file | cut -f2 -d=)
last_role_arn=$(grep role_arn $mfa_credentials_file | cut -f2 -d=)
if [ -z "$last_role_arn" ]; then
    echo "You are using an old or invalid version of $mfa_credentials_file! Please remove it and re-run the $0 script!"
    echo "Exitting..."
    exit 1
fi

# ROLE ARN to assume
echo -en "Enter your IAM role arn to assume.( $last_role_arn )\nRole arn: " >&2
read -r role_arn

if [ -z "$role_arn" ]; then
    echo "Invalid role arn name!"
    exit 255
fi

# Write the role arn that was entered
sed -i s"^role_arn.*$^role_arn=$role_arn^" $mfa_credentials_file

mfa_device="arn:aws:iam::$iam_account:mfa/$iam_username"

pretty_echo "IAM Details" 
echo "IAM username   : $iam_username"
echo "IAM account    : PTC-IAM ( $iam_account )"
echo "IAM profile    : $mfa_profile"
echo "MFA device     : $mfa_device"
echo "Role to assume : $role_arn" 
echo

echo -n "Enter your MFA code now: " >&2
read -r mfa_code
echo -n "Duration of Session: " >&2
read -r session_time

if [ ! -z $mfa_code ]; then
   sts_data=$(aws --profile $mfa_profile sts assume-role --role-arn $role_arn \
--role-session-name $iam_username \
--serial-number $mfa_device \
--token-code $mfa_code \
--duration-seconds $session_time )
else
    echo "Invalid MFA code"
    exit 255
fi

secret_key=$(echo -- "$sts_data" | sed -n 's!.*"SecretAccessKey": "\(.*\)".*!\1!p')
session_token=$(echo -- "$sts_data" | sed -n 's!.*"SessionToken": "\(.*\)".*!\1!p')
access_key=$(echo -- "$sts_data" | sed -n 's!.*"AccessKeyId": "\(.*\)".*!\1!p')
expiration=$(echo -- "$sts_data" | sed -n 's!.*"Expiration": "\(.*\)".*!\1!p')

if [ -z "$secret_key" -o -z "$session_token" -o -z "$access_key" ]; then
    echo "Unable to get temporary credentials.  Could not find secret/access/session entries
    $sts_data" >&2
    exit 255
fi

pretty_echo "MFA credentials to export:"

echo -e "export AWS_SESSION_TOKEN=\"$session_token\""
echo -e "export AWS_SECRET_ACCESS_KEY=$secret_key"
echo -e "export AWS_ACCESS_KEY_ID=$access_key\n"

pretty_echo "Keys valid until $expiration" >&2
