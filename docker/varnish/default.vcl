vcl 4.0;

backend default {
  .host = "nginx:80";
}

acl purge {
        "localhost";
        "192.168.0.0/24";
        "127.0.0.1";
}


 sub vcl_recv {


        if (req.method == "PURGE") {
                if (!client.ip ~ purge) {
                        return(synth(405,"Not allowed."));
                }
                 ban("req.http.host ~ .*");
                 return (purge);
        }
 
set req.http.X-Forwarded-For = client.ip;
set req.http.X-Cache-Varnish = "yes";

set req.url = regsub(
    req.url,
    "^/bitrix/(.*\.css)\?(\d{4})\d+",
    "/bitrix/\1?\2"
);

set req.url = regsub(
    req.url,
    "^/bitrix/(.*\.js)\?(\d{4})\d+",
    "/bitrix/\1?\2"
);

#  if (req.http.Cookie ~ "^\s*$") {
#    unset req.http.Cookie;
#  }

if (req.http.X-Forwarded-For) {
        unset req.http.X-Forwarded-For;
        set req.http.X-Forwarded-For = client.ip;
}

  if (req.url ~ "\.(svg|jpg|jpeg|JPG|gif|png|ico|css|txt|js|flv|swf|html|htm|woff2|woff|eot|webp)$" || req.url ~ "\?ver=") {
        unset req.http.Cookie;
        return (hash);
    }

  if (req.url ~ "install\.php|update\.php|cron\.php|phpmyadminwedx345$") {
    return (pass);
  }

if (req.url ~ "^.*/esi/.*$") {
     unset req.http.Cookie;
     return (hash);
}

if (req.url ~ "\.css\?1.*$") {
    unset req.http.Cookie;
}

if (req.url ~ "\.js\?1.*$") {
    unset req.http.Cookie;
}

#if (req.url ~ "/catalog.*$") {
#    unset req.http.Cookie;
#}

#admin panel
if( req.url ~ "^/bitrix/admin.*" || req.http.Cookie ~ "BITRIX_SM_LOGIN" ){
return (pass);
}

if( req.url ~ "^/$" ){
return (pass);
}

if (req.http.Authorization || req.method == "POST") {
                return (pass);
        }

if( req.url ~ "^/services/orders.*$"){
        return (pass);
}

if (req.url ~ "sitemap" || req.url ~ "robots") {
                return (pass);
        }
if (req.http.cookie ~ "^ *$") {
                    unset req.http.Cookie;
        }


#if ( !(req.http.cookie ~ ".*BITRIX_SM_LOGIN.*$") ) {
#                    unset req.http.Cookie;
#        }



if (!req.http.cookie) {
                unset req.http.cookie;
        }

if (req.http.Authorization || req.http.Cookie) {
                # Not cacheable by default
                return (pass);
        }

return (hash);


 }


sub vcl_pass {
        return (fetch);
}

sub vcl_hash {
        hash_data(req.url);

        return (lookup);
}

sub vcl_backend_response {
        unset beresp.http.X-Powered-By;

        set beresp.do_esi = true;

        if ( beresp.status != 200 ) {
                set beresp.uncacheable = true;
                set beresp.ttl = 1s;
                return (deliver);
        }



    if (bereq.url ~ "^.*/esi/footer.*$") {
       unset beresp.http.cookie;
       unset beresp.http.set-cookie;
       unset beresp.http.Cache-Control;
       set beresp.ttl = 90m;
       set beresp.uncacheable = false;
       set beresp.http.Cache-Control = "public, max-age=603111";
       set beresp.http.Expires = now + beresp.ttl;
       return (deliver);
    }

    if (bereq.url ~ "^.*/esi/second_menu.*$") {
       unset beresp.http.cookie;
       unset beresp.http.set-cookie;
       unset beresp.http.Cache-Control;
       set beresp.ttl = 60m;
       set beresp.uncacheable = false;
       set beresp.http.Cache-Control = "public, max-age=603111";
       set beresp.http.Expires = now + beresp.ttl;
       return (deliver);
    }

    if (bereq.url ~ "^.*/esi/.*$") {
       unset beresp.http.cookie;
       unset beresp.http.set-cookie;
       unset beresp.http.Cache-Control;
       set beresp.ttl = 30m;
       set beresp.uncacheable = false;
       set beresp.http.Cache-Control = "public, max-age=603111";
       set beresp.http.Expires = now + beresp.ttl;
       return (deliver);
    }

    if (bereq.url ~ "^/esi/.*$") {
       unset beresp.http.cookie;
       unset beresp.http.set-cookie;
       unset beresp.http.Cache-Control;
       set beresp.ttl = 30m;
       set beresp.uncacheable = false;
       set beresp.http.Cache-Control = "public, max-age=603111";
       set beresp.http.Expires = now + beresp.ttl;
       return (deliver);
    }

       if (bereq.url ~ "sitemap" || bereq.url ~ "robots") {
                set beresp.uncacheable = true;
                set beresp.ttl = 30m;
                return (deliver);
        }

        if (bereq.url ~ "\.(png|gif|jp(e?)g)|swf|ico|eot") {
                unset beresp.http.cookie;
                set beresp.ttl = 7d;
                unset beresp.http.Cache-Control;
                set beresp.http.Cache-Control = "public, max-age=604800";
                set beresp.http.Expires = now + beresp.ttl;
        }



                if (bereq.url ~ "\.(css|js|woff|svg|htm|html)") {
                unset beresp.http.cookie;
                set beresp.ttl = 7d;
                unset beresp.http.Cache-Control;
                set beresp.http.Cache-Control = "public, max-age=604800";
                set beresp.http.Expires = now + beresp.ttl;
#                               set beresp.do_gzip = true;
#                               set beresp.http.X-Cache = "ZIP";
        }

        if (bereq.url ~ "(login|admin)") {
                set beresp.uncacheable = true;
                set beresp.ttl = 30s;
                return (deliver);
        }

        if ( bereq.method == "POST" || bereq.http.Authorization ) {
                set beresp.uncacheable = true;
                set beresp.ttl = 120s;
                return (deliver);
        }

        if ( bereq.url ~ "\?s=" ){
                set beresp.uncacheable = true;
                set beresp.ttl = 120s;
                return (deliver);
        }

#        if ( beresp.status != 200 ) {
#                set beresp.uncacheable = true;
#                set beresp.ttl = 120s;
#                return (deliver);
#        }

        set beresp.grace = 5m;
        return (deliver);
}

sub vcl_deliver {
        unset resp.http.Server;
        unset resp.http.Via;
        unset resp.http.X-Varnish;
        unset resp.http.X-Powered-CMS;
        unset resp.http.X-Frame-Options;
        if (obj.hits > 0) {
                set resp.http.X-Cache = "HIT";
        } else {
                set resp.http.X-Cache = "MISS";
        }

        return (deliver);
}

