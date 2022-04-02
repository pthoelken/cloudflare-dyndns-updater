# your cloudflare login email address
auth_email="your email addr"

# your cloudflare general or specific api key 
# from https://dash.cloudflare.com/profile/api-tokens
auth_key="your api key"

# e.g. mydomain.com
zone_name="your main dns zone"

# e.g. subdomain.mydomain.com OR mydomain.com
record_name="your specified dns record name" 

# If you want to secure your home ip address 
# and use Cloudflare proxy features. Not recommended 
# for vpn or other direct ip services. 
# Recommended for HTTP/HTTPS services.
proxied=true 

# Your domain time to live time
ttl="1800" 