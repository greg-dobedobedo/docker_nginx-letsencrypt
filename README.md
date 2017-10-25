# nginx-letsencrypt

JrCs/docker-letsencrypt-nginx-proxy-companion is great but requires access to docker.sock. Sometimes you don't want or can't give this access for security reason.

I choose to embed Let's Encrypt on the same image than nginx because in case of certificate renewal nginx requires a reload.  

I also choose to avoid complex configuration based on several environment variables to define all your domains and how many different certificates you want. I kept it simple and let you launch certbot manually in the way you want. This is only required once or when you have a new virtualhost for which a certificate is needed.

# Usage

Declare 3 writable volumes :

    /etc/letsencrypt - Let's encrypt files
    /etc/nginx/conf.d - nginx configuration files
    /usr/share/nginx/html - nginx root folder for web pages

Expose the 80/tcp and/or 443/tcp ports. You can use a selfsigned certificate by commenting any ssl_ parameters in your server block. Leave "listen 443 ssl;" directive.

# Example

    docker run --name nginx-letsencrypt -v /etc/letsencrypt -v /etc/nginx/conf.d -v /usr/share/nginx/html -p 443:443 dobedobedo/nginx-letsencrypt

# Obtaining certificates

Execute the certbot command and follow the instruction:
    
    docker exec -it nginx-letsencrypt certbot --nginx certonly

If you already know the ToS, go faster :

    docker exec -it nginx-letsencrypt certbot --nginx -d <firstdomain> -d <otherdomain> -n --agree-tos --email <your email> certonly

If you want certbot to automatically fill your nginx server blocks with the required ssl_ directives, remove "certonly". This only works if there is no existing ssl_ directives and if you do not already listen a ssl port in your server block.

If you want several certificates with different domains instead of a single one with all domains bundled, execute cerbot for each certificate separately.

If you need a new certificate, you can launch certbot at any time, modify your nginx configuration and restart the container to apply changes.

# Using certificates

The certificates are published in /etc/letsencrypt/live/<firstdomain>/ where <firstdomain> is the first provided domain : cert.pem, fullchain.pem, privkey.pem. 
Choose fullchain.pem instead of cert.pem as the intermediate certificates will be also provided during ssl handshake.

If you choose certonly option, modify manually your nginx configuration files to add SSL support:

    server {
    listen 443 ssl;
    server_name <yourdomain>;
    ssl_certificate /etc/letsencrypt/live/<firstdomain>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<firstdomain>/privkey.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ...
    }

Restart your container:

    docker restart nginx-letsencrypt

# Renewing certificates

A daily cron job is already planned. If a certificate is renewed, nginx will be automatically reload. Nothing to care about.
