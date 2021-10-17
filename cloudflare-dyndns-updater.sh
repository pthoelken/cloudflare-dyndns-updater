#!/bin/bash
# Cloudflare as Dynamic DNS Updater

### EXAMPLE CRONTAB SETTIGNS FOR 6 HOURS -> EDIT /etc/crontab ###
0 */6 * * *     root    /bin/bash /opt/PTL/cloudflare/cloudflare-dyndns-updater.sh

# Update these with real values
auth_email="your email addr"
auth_key="your api key"
zone_name="your main dns zone" # e.g. mydomain.com
record_name="your specified dns record name" # e.g. subdomain.mydomain.com OR mydomain.com
proxied=true # If you want to secure your home ip address and use Cloudflare proxy features
ttl="1800" # Your domain time to live time

# More Settings
ip=$(curl -s https://ipv4.icanhazip.com)
ip_file="ip.txt"
id_file="cloudflare.ids"
log_file="cloudflare.log"

# Keep files in the same folder when run from cron
current="$(pwd)"
cd "$(dirname "$(readlink -f "$0")")"

log() {
    if [ "$1" ]; then
        echo -e "[$(date)] - $1" >> $log_file
    fi
}

log "Check Initiated"

if [ -f $ip_file ]; then
    old_ip=$(cat $ip_file)
    if [ $ip == $old_ip ]; then
        log "IP has not changed."
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
    log "$message"
    echo -e "$message"
    exit 1 
else
    message="IP changed to: $ip"
    echo "$ip" > $ip_file
    log "$message"
    echo "$message"
fi
