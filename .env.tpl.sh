# Your Cloudflare email address for login
auth_email="foobar@example.com"

# The Cloudflare general or specific api key
# from https://dash.cloudflare.com/profile/api-tokens
auth_key="YOUR_CLOUDFLARE_API_KEY"

# The main dns zone for example "foobar.com"
zone_name="YOUR_MAIN_DNS_ZONE"

# The subdomain which you want to update daily
# for example "subdomain.foobar.com"
record_name="YOUR_SUBDOMAIN_FROM_DNS_ZONE"

# If you want to secure your home ip address
# and use Cloudflare proxy features.
# Not recommended for vpn or other direct
# ip services. Recommended for HTTP/HTTPS services.
proxied=true

# Time To Live for your sub domain entry
ttl="1800"