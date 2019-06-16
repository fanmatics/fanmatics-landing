map $sent_http_content_type $expires {
    default                    off;
    text/html                  epoch;
    text/css                   max;
    application/javascript     max;
    ~image/                    max;
}

server {
    listen 80;
    listen [::]:80;
    server_name fanmatics.com www.fanmatics.com;
    root /usr/share/nginx/html;

    return 301 https://fanmatics.com$request_uri;
}

server {
    listen 443 http2 ssl;
    index index.html;

    ssl_certificate /etc/letsencrypt/live/fanmatics.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/fanmatics.com/privkey.pem;
    ssl_prefer_server_ciphers on;
    ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;

    # Make site accessible from http://localhost/
    server_name fanmatics.com;
    root /srv/fanmatics.com;

    location ~ /.well-known {
        allow all;
    }

    location / {
        gzip_static on;
        default_type "text/html";
        try_files $uri $uri.html /index.html;
    }

    location /static/ {
        expires $expires;
    }
}