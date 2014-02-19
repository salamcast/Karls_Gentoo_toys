#!/bin/bash
ROOT=$(pwd)

#src dir in ROOT
HTTPD=apache_1.3.41
MM=mm-1.4.2
KERB=mod_auth_kerb-5.4
PERL=mod_perl-1.31
SSL=mod_ssl-2.8.31-1.3.41 
#

APACHE=/mnt/apache
OPT=/opt/local
KERB5=libexec/heimdal
#configure
## Cleanup
for x in ${HTTPD} ${MM} ${PERL} ${SSL}
do
 rm -rf $x/*
 tar xvf ${x}.tar 

done
# MM
cd ${MM}
./configure --prefix=${APACHE} --disable-shared
make && make install
cd ${ROOT}

cd ${SSL}
./configure --with-apache=../${HTTPD}
cd ${ROOT}

# mod_auth_kerb
# cd $KERB
# ./configure --with-apache=${HTTPD} --with-krb4=no --with-krb5=${OPT}
#cd ${ROOT}


##########################
 

#mod_perl
 cd $PERL
perl  Makefile.PL USE_APACI=1 EVERYTHING=1 DO_HTTPD=1 \
        SSL_BASE=${OPT} \
        EAPI_MM=${APACHE} \
        APACHE_PREFIX=${APACHE} \
	APACHE_SRC=../${HTTPD}/src \
	APACI_ARGS='--disable-module=all --enable-shared=dir --enable-shared=mime --enable-shared=log_config --enable-shared=access --enable-module=rewrite --activate-module=src/modules/perl/libperl.a --enable-shared=ssl --prefix=/mnt/apache --enable-suexec --suexec-safepath="/mnt/local/bin:/mnt/local/sbin" '

# build/test/install Apache/mod_ssl/mod_perl
 make && make install
cd ${ROOT}

