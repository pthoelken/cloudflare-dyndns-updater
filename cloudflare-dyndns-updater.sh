#!/bin/bash -e

# Cloudflare as Dynamic DNS Updater
# Author: Patrick Thoelken
# GitHub Repository: https://github.com/pthoelken/cloudflare-dyndns-updater

if [ "$EUID" -ne 0 ]; then
    echo -e "[$(date)] - $0 must be run as sudo. Application exit."
    exit 1
fi

cd "$(dirname "$(readlink -f "$0")")"

envTemplate=".env.tpl"
envFile=".env"

if [ -f $envFile ]; then
    source $envFile
else
    mv $envTemplate $envFile
    echo -e "[$(date)] - $envFile file is created. Please fill this file with your Cloudflare credentials"
    exit 1
fi

logFolder=/var/log/cloudflare-dyndns-updater
ip=$(curl -s https://ipv4.icanhazip.com)
ip_file="$logFolder/cloudflare.ips"
id_file="$logFolder/cloudflare.ids"
log_file="$logFolder/cloudflare.log"

if [ ! -d $logFolder ]; then
    mkdir -p $logFolder
fi

ConsoleLog() {
    if [ "$1" ]; then
        echo -e "[$(date)] | $record_name | $1" | tee -a $log_file
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
    echo -e "$0 --log: Show the current log from $log_file"
    echo -e "$0 --help: Shows you the help manual."
    echo -e ""
}

function housekeeping() {
    rm -rf $tmpfolder/*.*
    echo -e "[$(date)] - $tmpfolder cleanup complete."
}

function showLog () {

    if [ -d $logFolder ]; then
        if [ -f $log_file ]; then
            cat $log_file
        fi
    else
        ConsoleLog "Log file $log_file was not found. Log can't display."
        exit 1
    fi 

}

case "$1" in
        "--cleanup")
        housekeeping
        ;;
        "--update")
        CheckFileContent $id_file
        updateIPToCloudflare
        ;;
        "--log")
        showLog
        ;;
        "--help")
        helpManual
        ;;
        *)
        echo -e ""
        echo -e "Unknown argument for $0 please use { --cleanup | --update | --help }"
        echo -e "Configuration Mode: $0 --update --config-mode"
        echo -e "Argument Mode: $0 --update --argument-mode foobar@example.com YOUR_CLOUDFLARE_API_KEY YOUR_MAIN_DNS_ZONE YOUR_SUBDOMAIN_FROM_DNS_ZONE false 1800"
        echo -e ""
        echo -e "For more informations check the GitHub Repository README.md page at: https://github.com/pthoelken/cloudflare-dyndns-updater"
        helpManual
        exit 1
        ;;
esac
exit 0
