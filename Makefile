NAME:=tuweni
VERSION:=2.2.0
REVISION:=1
ARCH:=all
FOLDER:=${NAME}_${VERSION}-${REVISION}_${ARCH}

.PHONY: clean
clean:
	rm -Rf ${FOLDER}
	rm -Rf tuweni-bin-*

tuweni-bin-${VERSION}-incubating.tgz:
	wget https://dlcdn.apache.org/incubator/tuweni/${VERSION}-incubating/tuweni-bin-${VERSION}-incubating.tgz
	
tuweni-bin-${VERSION}: tuweni-bin-${VERSION}-incubating.tgz
	tar zxf tuweni-bin-${VERSION}-incubating.tgz

${FOLDER}.deb: tuweni-bin-${VERSION}
	mkdir -p ${FOLDER}/debian
	mkdir -p ${FOLDER}/data/etc/tuweni/
	mkdir -p ${FOLDER}/data/usr/lib/tuweni/

	tar zxf tuweni-bin-${VERSION}-incubating.tgz
	cp -R tuweni-bin-${VERSION}/* ${FOLDER}/data/usr/lib/tuweni/
	
	echo "Source: ${NAME}" > ${FOLDER}/debian/control
	echo "Package: ${NAME}" >>  ${FOLDER}/debian/control
	echo "Version: ${VERSION}" >> ${FOLDER}/debian/control
	echo "Priority: extra" >> ${FOLDER}/debian/control
	echo "Essential: no" >> ${FOLDER}/debian/control
	echo "Architecture: all" >> ${FOLDER}/debian/control
	echo "Origin: https://www.github.com/tmio/tuweni-debian" >> ${FOLDER}/debian/control
	echo "Bugs: https://www.github.com/tmio/tuweni-debian/issues/" >> ${FOLDER}/debian/control
	echo "Homepage: https://www.themachine.io" >> ${FOLDER}/debian/control
	echo "Recommends: default-jre-headless" >> ${FOLDER}/debian/control
	echo "Description: Apache Tuweni executables" >> ${FOLDER}/debian/control

	echo "ln -s /usr/lib/tuweni/bin/jsonrpc /usr/bin/jsonrpc" > ${FOLDER}/debian/postinst
	echo "ln -s /usr/lib/tuweni/bin/tuweni /usr/bin/tuweni" >> ${FOLDER}/debian/postinst
	echo "ln -s /usr/lib/tuweni/bin/eth-faucet /usr/bin/eth-faucet" >> ${FOLDER}/debian/postinst
	echo "ln -s /usr/lib/tuweni/bin/gossip /usr/bin/gossip" >> ${FOLDER}/debian/postinst
	echo "ln -s /usr/lib/tuweni/bin/scraper /usr/bin/scraper" >> ${FOLDER}/debian/postinst
	echo "ln -s /usr/lib/tuweni/bin/stratum-proxy /usr/bin/stratum-proxy" >> ${FOLDER}/debian/postinst
	chmod +x ${FOLDER}/debian/postinst
	echo "rm /usr/bin/jsonrpc /usr/bin/tuweni /usr/bin/eth-faucet /usr/bin/gossip /usr/bin/scraper /usr/bin/stratum-proxy" > ${FOLDER}/debian/postrm
	chmod +x ${FOLDER}/debian/postrm
	tar czf data.tar.gz --owner=0 --group=0 -C ${FOLDER}/data/ etc usr 
	tar czf control.tar.gz --owner=0 --group=0 -C ${FOLDER}/debian/ control postinst postrm 
	echo "2.0" > debian-binary
	ar cr ${FOLDER}.a debian-binary control.tar.gz data.tar.gz 
	mv ${FOLDER}.a ${FOLDER}.deb

.PHONY: build
build: ${FOLDER}.deb
.PHONY: publish
publish: build
	mkdir -p repository/pool/main/
	cp ${FOLDER}.deb repository/pool/main/
	mkdir -p repository/dists/stable/main/binary-all
	cd repository; dpkg-scanpackages --arch all pool/ > dists/stable/main/binary-all/Packages
	cd repository; cat dists/stable/main/binary-all/Packages | gzip -9 > dists/stable/main/binary-all/Packages.gz
	cd repository/dists/stable; ../../../generate-release.sh > Release
	cat repository/dists/stable/Release | gpg --default-key tmio -abs > repository/dists/stable/Release.gpg
	cat repository/dists/stable/Release | gpg --default-key tmio -abs --clearsign > repository/dists/stable/InRelease


