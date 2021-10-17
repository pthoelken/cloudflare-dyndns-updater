# cloudflare-dyndns-updater
Update your Cloudflare DNS Records for e.g. DynDNS

# How to use it

First of all, you have to register a domain at GoDaddy for example and set the nameservers to the Cloudflare nameservers. After this, you go ahead to Cloudflare and check in your domain as free and wait until Cloudflare tells you all is up and fine. 

1. Get your Cloudflare API Key https://dash.cloudflare.com/profile/api-tokens
2. Create a real domain zone and domain record with fake values (e.g. 8.8.8.8, non proxified) just for creation
2. Configure the script variables section for your usecase
3. Run this script manually or automatically by a cronjob

For example your running this from your home network at a Raspberry Pi or Linux Computer you don't have to configure dyndns settings in your home router. You have to just configure your open ports for incoming traffic to your destination. 

# Example build for home
- cloud.foo.bar (Port 443, public domain, GoDaddy / Namecheap registrated) -> Cloudflare integrated -> ||| here begins your home network ||| -> your home pi update the dns records from your public router ip to cloudflare for cloud.foo.bar -> you have to configure in your home router, that you accept port 443 incoming to your cloud-server (virtual machine, another pi, ...)

After this, you can reach the home internal cloud machine from all over the world. 

Please don't forget to protect your machine and all of your home networks and devices by a firewall solution (maybe integrated in your home router) or similar.

# Questions
Please use the issue section of this repository. Thanks. 