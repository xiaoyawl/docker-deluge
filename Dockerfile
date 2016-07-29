FROM benyoo/centos-core:7.2.1511.20160706

MAINTAINER from www.dwhd.org by lookback (mondeolove@gmail.com)

ARG VERSION=${VERSION:-1.3.13}

ENV DATA_DIR=/data/ \
	TEMP_DIR=/tmp/deluge

RUN set -x && \
	mkdir -p ${TEMP_DIR} ${DATA_DIR} && \
	cd ${TEMP_DIR} && \
	yum install gcc gcc-c++ make boost boost-devel openssl openssl-devel python-devel GeoIP GeoIP-devel git svn which intltool libffi-devel -y && \
	curl -Lk https://bootstrap.pypa.io/get-pip.py | python && \
	pip install chardet pyopenssl twisted mako service_identity pyxdg && \
	curl -Lk https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_0_7/libtorrent-rasterbar-1.0.7.tar.gz |gunzip|tar x -C ./ && \
	cd libtorrent-rasterbar-1.0.7/ && \
	./configure --prefix=/usr --enable-python-binding --with-libgeoip --with-libiconv --disable-debug && \
	make clean && make -j $(awk '/processor/{i++}END{print i}' /proc/cpuinfo) && make install && cd .. && \
	ln -s /usr/lib/pkgconfig/libtorrent-rasterbar.pc /usr/lib64/pkgconfig/libtorrent-rasterbar.pc && \
	ln -s /usr/lib/libtorrent-rasterbar.so.8 /usr/lib64/libtorrent-rasterbar.so.8 && \
	#python -c "import libtorrent; print libtorrent.version" && \
	curl -Lk http://download.deluge-torrent.org/source/deluge-${VERSION}.tar.gz|gunzip|tar x -C ./ && \
	cd deluge-${VERSION}/ && \
	python setup.py build && \
	python setup.py install && \
	useradd -r -s /usr/sbin/nologin -d /data -m -k no deluge && \
	yum remove gcc gcc-c++ make boost boost-devel -y && \
	yum clean all && \
	rm -rf ${TEMP_DIR} /var/cache/{yum,ldconfig} && \
	mkdir -pv --mode=0755 /var/cache/{yum,ldconfig}

EXPOSE 53160/tcp 53160/udp 8112/tcp 58846/tcp

ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
