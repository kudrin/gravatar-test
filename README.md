---

The task
--------

Create a maintainable, production ready web application
that provides an API endpoint for transforming email addresses
into gravatar uris

```
# GET /gravatr/{email}
+ Response 200 (text/plain)

    https://www.gravatar.com/avatar/sdgdsf3535sdfg.jpeg
```

* Source code of the application has to be delivered in form of
a private git repository to which you should have or will receive
access shortly.

* The code should be covered with tests.

* Improve the README file describing:
  - what libraries, frameworks, tools are used and why
  - possible improvements eg. for performance, readability, maintainability ...

* Contain the following **executables**:
  - `bin/setup` - for fetching, installing the dependencies and other setup
    related tasks
  - `bin/start` - for starting the web application on a port given
    through the ENV variable `PORT` or defaulting to a default one
  - `bin/test` - for running the test suite

* The completed version should be marked with a git tag `v1.0.0`


Have fun!


# Gravatar API proxy
The presented application was based on the following principals: quick development and high speed of work.

As the application should implement single API method without data keeping I decided not to use _Ruby on Rails_ Framework. As we also don&#146;t need DB or admin-panel I decided not to use _Padrino_ as well. I chose _Sinatra_ as the easiest decision that fully suit our purpose.

However, the application has few features.

## Cache system
I used memcahe as it is simple and stable product which is easy to scale. 
For testing I used _ab_ utility. 

Tests result:
https://gist.github.com/kudrin/c9db69678030eeecb2c9

### Without cache
![No-cache](https://goo.gl/pgTbQX)
It is the simplest realization. I would recommend to use it for average loading. To proceed with 10000 requests takes 4.0 seconds.

### Cache on application level
![Application-cache](https://goo.gl/oLpiJP)
This realization seems the more obvious and is often used in practice. But in reality generation md5 hash takes the same time as a request to the cache. Therefore, this realization would not bring any time effectiveness. To proceed with 10000 requests takes 4.5 seconds which is even more then application without cache does. I would not recommended to use this realization for API. 

### Cache on nginx level
![Nginx-cache](https://goo.gl/J1caFY)

For this realization _ngx_http_memcached_module_ is used. 
I recommend to use this method if high time effectiveness is needed. For running it is required to set up nginx and to have enough memory at the server. To proceed with 10000 requests takes 0.65 seconds. The time effectiveness is increased by 524%.

## System requirements
 - Ruby 2.0 or above
 - Nginx
 - Memcache
 - Bundler
 
### Nginx config example
 
 ```nginx
 server {
    location / {
	default_type       text/html;
        set            $memcached_key "gravatar:$scheme:$uri?$args";
        memcached_pass localhost:11211;
        error_page     404 502 504 = @fallback;
    }

    location @fallback {
        proxy_pass     http://localhost:3002;
    }
}
 ```

### Run application

You can change port with PORT enviroment variable.

```bash
$ RACK_ENV=production PORT=5000 bin/start
```

Default port is 3002.
Default enviroment is development.

### Setup application

After install requirements. 

```bash
$ bin/setup
```
To change memcache server paramaters or disable cache use - edit _app.rb_.

### Test application

```bash
$ bin/test
```
To disable cache edit _app.rb_.
