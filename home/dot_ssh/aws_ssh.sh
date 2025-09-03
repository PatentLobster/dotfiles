#!/bin/zsh
#source  ~/.aws/mfa

# Fix for some apps like tableplus to use the correct aws cli
if [ -e "~/.aws/bin" ]; then
    if [ -e "$(cat ~/.aws/bin)" ]; then
        alias aws="$(cat ~/.aws/bin)"
    fi
fi

host="$1"
ssh_user="$2"
port_number="$3"
name=""
alias base64="/usr/bin/base64"
die () { echo "[${0##*/}] $*" >&2; exit 1; }


if [[ $host == *.aws ]]; then
   name=$host
   instance_id=$(aws ec2 describe-instances \
                                            --filters "Name=tag:host,Values=${host%.aws}" \
                                            --query "Reservations[].Instances[].InstanceId" \
                                            --output text)
else
	#name=$(aws ec2 describe-instances --instance-ids $1 --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text)
	instance_id=$host
fi


if [[ "${LC_TERMINAL:=lol}"=="iTerm2" ]]; then
	if [[ $name == "" ]]; then
		name=$instance_id
	fi
	function iterm2_set_user_var () {
		printf "\033]1337;SetUserVar=%s=%s\007" "$1" $(printf "%s" "$2" | base64 | /usr/bin/tr -d '\n') > /dev/tty
	}

	trap "iterm2_set_user_var badge '' " EXIT
	iterm2_set_user_var badge $name
fi

AVAILABILITY_ZONE=$(aws ec2 describe-instances \
                                                              --instance-ids "$instance_id"\
                                                              --query "Reservations[].Instances[].Placement.AvailabilityZone" \
                                                              --output text)

te=$(aws ec2-instance-connect send-ssh-public-key \
    --region us-east-1 \
    --availability-zone "$AVAILABILITY_ZONE" \
    --instance-id "$instance_id" \
    --instance-os-user $ssh_user \
    --ssh-public-key file://~/.ssh/id_rsa.pub > /dev/null)


# start ssh session over ssm
aws ssm start-session --document-name AWS-StartSSHSession --target "$instance_id" --parameters "portNumber=$port_number"