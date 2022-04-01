#!/bin/bash -ex
# Cloudflare as Dynamic DNS Updater

# ---> Fill out the .env file with your credentials
if [ -f .env ]; then
    source .env
else
    mv .env.tpl .env
fi

# ---> Do not edit variables from here
tmpfolder=/tmp/cloudflare-dyndns-updater
ip=$(curl -s https://ipv4.icanhazip.com)
ip_file="$tmpfolder/cloudflare.ips"
id_file="$tmpfolder/cloudflare.ids"
log_file="$tmpfolder/cloudflare.log"

if [ "$EUID" -ne 0 ]; then
    echo -e "[$(date)] - $0 must be run as sudo. Application exit."
    exit 1
fi

if [ ! -d $tmpfolder ]; then
    mkdir -p $tmpfolder
fi

cd "$(dirname "$(readlink -f "$0")")"

ConsoleLog() {
    if [ "$1" ]; then
        echo -e "[$(date)] - $1" | tee -a $log_file
    fi
}

function CheckFileContent() {
    if [ -f $1 ] && ( ! grep -q '[^[:space:]]' $1); then
        ConsoleLog "$1 content is empty and will be deleted. Please re-run this script."
        sudo rm -rf $1
        exit 1
    fi
}

function updateIPToCloudflare() {
    ConsoleLog "Check Initiated"

    if [ -f $ip_file ]; then
        old_ip=$(cat $ip_file)
        if [ $ip == $old_ip ]; then
            ConsoleLog "The ip address not changed. You have still the IP address $old_ip"
            exit 0
        fi
    fi

    if [ -f $id_file ] && [ $(wc -l $id_file | cut -d " " -f 1) == 2 ]; then
        zone_identifier=$(head -1 $id_file)
        record_identifier=$(tail -1 $id_file)
    else

        zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name" \
        -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" \
        -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )

        record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name" \
        -H "X-Auth-Email: $auth_email" \
        -H "X-Auth-Key: $auth_key" \
        -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*')

        echo "$zone_identifier" > $id_file
        echo "$record_identifier" >> $id_file
    fi

    update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
    -H "X-Auth-Email: $auth_email" \
    -H "X-Auth-Key: $auth_key" \
    -H "Content-Type: application/json" \
    --data "{\"id\":\"$zone_identifier\",\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":\"$ttl\",\"proxied\":$proxied}")

    if [[ $update == *"\"success\":false"* ]]; then
        message="API UPDATE FAILED. DUMPING RESULTS:\n$update"
        ConsoleLog "$message"
        echo -e "$message"
        exit 1 
    else
        echo "$ip" > $ip_file
        ConsoleLog "Youre IP is changed and updated to: $ip"
    fi
}

function helpManual() {
    echo -e ""
    echo -e "---------- USAGE OF $0 ----------"
    echo -e ""
    echo -e "$0 --update: Update your ip address to cloudflare and save results to $tmpfolder"
    echo -e "$0 --cleanup: Cleanup the $tmpfolder Folder"
    echo -e "$0 --help: Shows you the help manual."
    echo -e ""
}

function housekeeping() {
    rm -rf $tmpfolder/*.*
    echo -e "[$(date)] - $tmpfolder cleanup complete."
}

case "$1" in
        "--cleanup")
        housekeeping
        ;;
        "--update")
        CheckFileContent $id_file
        updateIPToCloudflare
        ;;
        "--help")
        helpManual
        ;;
        *)
        echo -e ""
        echo -e "Unknown argument for $0 please use { --cleanup | --update | --help }"
        helpManual
        exit 1
        ;;
esac
exit 0
