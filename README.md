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

- sudo nano /etc/crontab
- `0 */6 * * *     root    cloudflare-dyndns-updater.sh --update --argument-mode foobar@example.com YOUR_CLOUDFLARE_API_KEY YOUR_MAIN_DNS_ZONE YOUR_SUBDOMAIN_FROM_DNS_ZONE false 1800`

## Run usage Example

- sudo ./cloudflare-dyndns-updater.sh --help
- sudo ./cloudflare-dyndns-updater.sh --cleanup
- sudo ./cloudflare-dyndns-updater.sh --log
- sudo ./cloudflare-dyndns-updater.sh --update --config-mode/--argument-mode

## Commands Example

### arguments describe

| Argument                     | Description                                                                                                                                                             |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| foobar@example.com           | Your Cloudflare login email address                                                                                                                                     |
| YOUR_CLOUDFLARE_API_KEY      | Your global Cloudflare API key from https://dash.cloudflare.com/profile/api-tokens                                                                                      |
| YOUR_MAIN_DNS_ZONE           | The main dns zone for example "foobar.com"                                                                                                                              |
| YOUR_SUBDOMAIN_FROM_DNS_ZONE | The subdomain which you want to update daily for example "subdomain.foobar.com"                                                                                         |
| false                        | If you want to secure your home ip address and use Cloudflare proxy features. Not recommended for vpn or other direct ip services. Recommended for HTTP/HTTPS services. |
| 1800                         | Time To Live for your sub domain entry                                                                                                                                  |

### argument-mode

In argument-mode you can run the script with your sesstings out from the commandline. This is useful for updating more than one different domain / subdomain from one host

- `cloudflare-dyndns-updater.sh --update --argument-mode foobar@example.com YOUR_CLOUDFLARE_API_KEY YOUR_MAIN_DNS_ZONE YOUR_SUBDOMAIN_FROM_DNS_ZONE false 1800`

### config-mode

If you have just one domain to update it you can use this script in config-mode. In this case you have to fill out the information in the .env file which will be created if you've run this at the first time.

- `cloudflare-dyndns-updater.sh --update --config-mode`

Last one open the necessary ports from your router to the linux server / RaspberryPi which you want to reach from the internet.

# Update Script

Switch to the directory where the script is located.

1. `sudo git reset --hard`
2. `sudo git pull`
3. `sudo chmod +x cloudflare-dyndns-updater.sh`

# Example build for home

- cloud.foo.bar (Port 443, public domain, GoDaddy / Namecheap registrated) **->** Cloudflare integrated **-> ||| 🏠 here begins your home network 🏠 ||| ->** your home pi update the dns records from your public router ip to cloudflare for cloud.foo.bar **->** you have to configure in your home router, that you accept port 443 incoming to your cloud-server (virtual machine, another pi, ...)

After this, you can reach the home internal cloud machine from all over the world.

Please don't forget to protect your machine and all of your home networks and devices by a firewall solution (maybe integrated in your home router) or similar.

# Questions

Please use the issue section of this repository. Thanks.
