#!/bin/bash -x

# CREATED:
# vitaliy.natarov@yahoo.com
#
# Unix/Linux blog:
# http://linux-notes.org
# Vitaliy Natarov
#

# updates
yum -y update; yum clean all
# install some utilites 
yum install -y \
		epel-release \
		git \
		curl \
		wget \
        gcc \
        gcc-c++ \
        gd-devel \
        gettext \
        GeoIP-devel \
        libxslt-devel \
        make \
        perl \
        perl-ExtUtils-Embed \
        readline-devel \
        unzip \
        zlib-devel \
        pcre-devel
# modules
mkdir ~/build
cd ~/build && git clone http://luajit.org/git/luajit-2.0.git && cd luajit-2.0 && make && make install
cd ~/build && curl -R -O http://www.lua.org/ftp/lua-5.3.4.tar.gz && tar zxf lua-5.3.4.tar.gz && cd lua-5.3.4 && make linux test 
cd ~/build && git clone https://github.com/simpl/ngx_devel_kit.git 
cd ~/build && git clone https://github.com/openresty/lua-nginx-module.git

cd ~/build && wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.41.tar.gz && tar -xzvf pcre-8.41.tar.gz && cd pcre-8.41 && ./configure --enable-jit && make && make install
cd ~/build && wget https://www.openssl.org/source/openssl-1.0.2m.tar.gz && tar -xzvf openssl-1.0.2m.tar.gz && cd openssl-1.0.2m && ./config && make && make install

# tell nginx's build system where to find LuaJIT 2.0:
export LUAJIT_LIB=/usr/local/lib/
export LUAJIT_INC=/usr/local/include/luajit-2.0

# create group and user for nginx
sudo groupadd nginx && useradd --no-create-home nginx -g nginx

# nginx 
cd ~/build && wget https://nginx.org/download/nginx-1.13.7.tar.gz && tar -vzxf nginx-1.13.7.tar.gz && cd nginx-1.13.7

./configure \
		--with-ld-opt="-Wl,-rpath,/usr/local/lib/" \
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--user=nginx \
		--group=nginx \
		--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_stub_status_module \
		--with-http_auth_request_module \
		--with-http_xslt_module=dynamic \
		--with-http_image_filter_module=dynamic \
		--with-http_geoip_module \
		--with-http_perl_module=dynamic \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--with-stream_geoip_module=dynamic \
		--with-http_slice_module \
		--with-mail \
		--with-mail_ssl_module \
		--with-file-aio \
		--with-http_v2_module \
		--with-pcre-jit \
		--with-pcre=../pcre-8.41 \
		--with-openssl=../openssl-1.0.2m \
		--add-module=~/build/ngx_devel_kit \
		--add-module=~/build/lua-nginx-module \

make -j2 && make install
# Add additional binaries into PATH for convenience
export PATH=$PATH:/usr/local/bin/:/usr/local/sbin/:/usr/bin/:/usr/sbin/

mkdir -p /var/cache/nginx/client_temp && mkdir -p /etc/nginx/conf.d

rm -rf ~/build/*.tar.gz