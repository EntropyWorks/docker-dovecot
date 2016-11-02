FROM debian:latest

RUN apt update && apt install -y git wget autoconf automake libtool pkg-config gettext pandoc make libssl-dev libgc-dev libpam0g-dev libldap2-dev libcdb-dev libbz2-dev liblzma-dev liblz4-dev libexpat-dev libsolr-java locales mercurial python-setuptools && \
    cd /opt && git clone --depth=1 https://github.com/dovecot/core && cd core && ./autogen.sh && \
    ./configure --enable-maintainer-mode --enable-dependency-tracking --with-nss --with-pam --with-ldap=yes --with-cdb --with-zlib --with-bzlib --with-lzma --with-lz4 --with-ssl=openssl --with-gc --with-storages=maildir --with-solr && \
    make all && cd .. && git clone --depth=1 https://github.com/dovecot/pigeonhole && cd pigeonhole && ./autogen.sh && ./configure --with-dovecot=../core --with-ldap=no && make all && \
    cd .. && cd core && make install && cd ../pigeonhole && make install && mkdir -p /var/run/dovecot && useradd dovenull && useradd dovecot && \
    apt install -y uuid-dev libgcrypt-dev libestr-dev flex dh-autoreconf bison python-docutils libxml2-dev wget re2c && \
    cd /opt && git clone https://github.com/rsyslog/libfastjson && cd libfastjson && autoreconf -v --install && ./configure && make && make install && \
    git clone https://github.com/rsyslog/liblogging && cd liblogging && autoreconf -v --install && ./configure --disable-man-pages && make && make install && \
    git clone https://github.com/rsyslog/rsyslog && cd rsyslog && ./autogen.sh --enable-omstdout && make && make install && ldconfig && \
    mkdir /var/log/supervisor/ && /usr/bin/easy_install supervisor && /usr/bin/easy_install supervisor-stdout

ADD supervisord.conf /etc/supervisord.conf
ADD rsyslog.conf /etc/rsyslog.conf

EXPOSE 143 995 993 2000 1025 
CMD ["supervisord","-n","-c","/etc/supervisord.conf"]
