# -*- mode:nginx -*-
upstream paperstencil_cluster {
    # fail_timeout=0 means we always retry an upstream even if it failed
    # to return a good HTTP response (in case the Unicorn master nukes a
    # single worker for timing out).

    # for UNIX domain socket setups:
    server unix:/tmp/.sock fail_timeout=0;
}


server {
    listen 80;
    listen   [::]:80  ipv6only=on default_server;

    server_name paperstencil.com www.paperstencil.com 162.243.122.178;
    return 301 https://www.paperstencil.com$request_uri;
}

server {
    listen                  443 ssl default_server;

    ssl_certificate         ssl/paperstencil.com.ssl.cert;
    ssl_certificate_key     ssl/paperstencil.com.pem;

    ssl_session_cache       builtin:1000  shared:SSL:10m;
    ssl_session_timeout     5m;
    ssl_ecdh_curve          secp521r1;

    ssl_protocols           TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers       on;

    # The following is all one long line. We use an explicit list of ciphers to enable
    # forward secrecy without exposing ciphers vulnerable to the BEAST attack
    ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-RC4-SHA:ECDHE-RSA-RC4-SHA:ECDH-ECDSA-RC4-SHA:ECDH-RSA-RC4-SHA:ECDHE-RSA-AES256-SHA:RC4-SHA:HIGH:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!CBC:!EDH:!kEDH:!PSK:!SRP:!kECDH;

    # The following is for reference. It needs to be specified again
    # in each virtualhost, in both HTTP and non-HTTP versions.
    add_header Strict-Transport-Security max-age=2592000;

    client_max_body_size 510m;

    root /var/paperstencil/current/public;

    location ~ ^/assets/ {
        expires max;
    }

    location ^~ /javascripts/ {
        return 404;
    }
    
    location / {
        proxy_set_header  X-Real-IP  $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        #proxy_redirect off;

        if (-f $request_filename/index.html) {
	        rewrite (.*) $1/index.html break;
        }
        if (-f $request_filename.html) {
	        rewrite (.*) $1.html break;
        }
        if (!-f $request_filename) {
	        proxy_pass http://paperstencil_cluster;
	        break;
        }
    }

    error_page 500 504  /500.html;
    error_page 502 =503 /503.html;

    location = /500.html {
        root /var/paperstencil/current/public;
    }

    location = /503.html {
        root /var/paperstencil/current/public;
    }

}

