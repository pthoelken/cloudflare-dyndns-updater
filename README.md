# cloudflare-dyndns-updater
Update your Cloudflare DNS Records for e.g. DynDNS

# How to use it
First of all, you have to register a domain at GoDaddy for example and set the nameservers to the Cloudflare nameservers. After this, you go ahead to Cloudflare and check in your domain as free and wait until Cloudflare tells you all is up and fine. 

1. Get your Cloudflare API Key https://dash.cloudflare.com/profile/api-tokens
2. Create a real domain zone and domain record with fake values (e.g. 8.8.8.8, non proxified) just for creation
3. Clone this repo to your linux server / RaspberryPi
4. sudo chmod +x cloudflare-dyndns-updater.sh
5. Configure the script variables section for your usecase
6. Run this script manually or automatically by a cronjob

* sudo nano /etc/crontab
* `0 */6 * * *     root    /opt/scripts/cloudflare-dyndns-updater/cloudflare-dyndns-updater.sh --update`

## Run usage Example
* s1udo ./cloudflare-dyndns-updater.sh --help
* sudo ./cloudflare-dyndns-updater.sh --cleanup
* sudo ./cloudflare-dyndns-updater.sh --log
* sudo ./cloudflare-dyndns-updater.sh --update

Last one open the necessary ports from your router to the linux server / RaspberryPi which you want to reach from the internet.

# Example build for home
- cloud.foo.bar (Port 443, public domain, GoDaddy / Namecheap registrated) **->** Cloudflare integrated **-> ||| 🏠 here begins your home network 🏠 ||| ->** your home pi update the dns records from your public router ip to cloudflare for cloud.foo.bar **->** you have to configure in your home router, that you accept port 443 incoming to your cloud-server (virtual machine, another pi, ...)

After this, you can reach the home internal cloud machine from all over the world. 

Please don't forget to protect your machine and all of your home networks and devices by a firewall solution (maybe integrated in your home router) or similar.

# Questions
Please use the issue section of this repository. Thanks. 
