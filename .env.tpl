# Your Cloudflare email address for login
config_auth_email="foobar@example.com"

# The Cloudflare general or specific api key
# from https://dash.cloudflare.com/profile/api-tokens
config_auth_key="YOUR_CLOUDFLARE_API_KEY"

# The main dns zone for example "foobar.com"
config_zone_name="YOUR_MAIN_DNS_ZONE"

# The subdomain which you want to update daily
# for example "subdomain.foobar.com"
config_record_name="YOUR_SUBDOMAIN_FROM_DNS_ZONE"

# If you want to secure your home ip address
# and use Cloudflare proxy features.
# Not recommended for vpn or other direct
# ip services. Recommended for HTTP/HTTPS services.
config_proxied=true

# Time To Live for your sub domain entry
config_ttl="1800"

if [[ $2 == "--argument-mode" ]]; then
    auth_email=$3
    auth_key=$4
    zone_name=$5
    record_name=$6
    proxied=$7
    ttl=$8
    elif [[ $2 == "--config-mode" ]]; then
    auth_email=$config_auth_email
    auth_key=$config_auth_key
    zone_name=$config_zone_name
    record_name=$config_record_name
    proxied=$config_proxied
    ttl=$config_ttl
fi