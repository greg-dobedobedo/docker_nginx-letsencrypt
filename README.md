# docker_nginx-letsencrypt

JrCs/docker-letsencrypt-nginx-proxy-companion is great but requires access to docker.sock in order to read their VIRTUAL_HOST environment variable. In some cases, you don't want or cannot give this access for security reason.

Let's Encrypt can run in a different image than nginx but in case of certificate renewal, nginx will require a reload to take new certificate in account. This is why the best way is to keep them together in the same image.

Instead of providing a complex image which would obtain your domains from environment variables and request certificates bundled or not according to your preferences through more environment variables, I prefered keeping it simple and request you to execute certbot manually. If more domains are added, the container does not have to be remove and create again with new variables.

# Usage

Declare 3 writable volumes for persistence :

    /etc/letsencrypt where Let's encrypt files are created
    /etc/nginx/conf.d where your nginx configuration files can be found
    /usr/share/nginx/html where your nginx web pages can be found

Expose the 80/tcp and/or 443/tcp ports. Your service on 443/tcp can use a selfsigned certificate by removing all ssl_ parameters in your server block. Just leave "listen 443 ssl;"

# Example

    docker run --name nginx-letsencrypt -v /etc/letsencrypt -v /etc/nginx/conf.d -v /usr/share/nginx/html -p 443:443 dobedobedo/nginx-letsencrypt

# Obtaining certificates

Execute by yourself the certbot command because if you want a thing done well, do it yourself:
    
    docker exec -it nginx-letsencrypt certbot --nginx certonly

If you know the TOS, you can go faster :

    docker exec -it nginx-letsencrypt certbot --nginx -d <firstdomain> -d <otherdomain> -n --agree-tos --email <your email> certonly

If you want certbot to modify your nginx automatically with all the SSL parameters, remove "certonly" but first declare no ssl parameters in your nginx server block and do not listen on 443/tcp neither.

If you want your domains in separate certificates, execute the cerbot several times with different domains.

If you need more certificate, you can launch the certbot at any time.

# Using certificates

The certificates are published in /etc/letsencrypt/live/\<firstdomain\>/ where \<firstdomain\> is the first provided domain : cert.pem, fullchain.pem, privkey.pem. 
Prefer fullchain.pem instead of cert.pem as the intermediate certificates will be provided to clients.

Modify your nginx configuration files to add the SSL support. For instance :

    server {
    listen 443 ssl;
    server_name <yourdomain>;
    ssl_certificate /etc/letsencrypt/live/<firstdomain>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<firstdomain>/privkey.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ...
    }

Then restart your container:

    docker restart nginx-letsencrypt

# Renewing certificates

A daily cron job is planned and will reload nginx. Nothing to do about it.
