# get image from...
FROM centos:7
# maintainer
MAINTAINER Vitaliy Natarov "vitaliy.natarov@yahoo.com"
# updates
RUN yum -y update; yum clean all
# install some utilites 
RUN yum install -y \
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
RUN cd /usr/local/src && git clone http://luajit.org/git/luajit-2.0.git && cd luajit-2.0 && make && make install
RUN cd /usr/local/src && curl -R -O http://www.lua.org/ftp/lua-5.3.4.tar.gz && tar zxf lua-5.3.4.tar.gz && cd lua-5.3.4 && make linux test 
RUN cd /usr/local/src && git clone https://github.com/simpl/ngx_devel_kit.git 
RUN cd /usr/local/src && git clone https://github.com/openresty/lua-nginx-module.git

RUN cd /usr/local/src && wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.41.tar.gz && tar -xzvf pcre-8.41.tar.gz && cd pcre-8.41 && ./configure --enable-jit && make && make install
RUN cd /usr/local/src && wget https://www.openssl.org/source/openssl-1.0.2m.tar.gz && tar -xzvf openssl-1.0.2m.tar.gz && cd openssl-1.0.2m && ./config && make && make install

# tell nginx's build system where to find LuaJIT 2.0:
ENV LUAJIT_LIB /usr/local/lib/
ENV LUAJIT_INC /usr/local/include/luajit-2.0

# create group and user for nginx
RUN groupadd nginx && useradd --no-create-home nginx -g nginx

# nginx 
RUN cd /usr/local/src && wget https://nginx.org/download/nginx-1.13.7.tar.gz && tar -vzxf nginx-1.13.7.tar.gz && cd nginx-1.13.7 \

&& ./configure \
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
		--add-module=/usr/local/src/ngx_devel_kit \
		--add-module=/usr/local/src/lua-nginx-module \

&& make -j2 && make install
# Add additional binaries into PATH for convenience
ENV PATH=$PATH:/usr/local/bin/:/usr/local/sbin/:/usr/bin/:/usr/sbin/

RUN mkdir -p /var/cache/nginx/client_temp && mkdir -p /etc/nginx/conf.d

WORKDIR /usr/share/nginx/html
# Copy nginx configuration files
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf 

RUN echo "NGINX with lua on CentOS 7 inside Docker" > /usr/share/nginx/html/index.html 

#RUN rm -rf /usr/local/src/* \
#	&& yum clean all
RUN rm -rf /usr/local/src/*.tar.gz

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# allow port(s) 
EXPOSE 22 80 443
#
#STOPSIGNAL SIGTERM

# This is the default CMD used by nginx:1.9.2 image
CMD ["nginx", "-g", "daemon off;"]
