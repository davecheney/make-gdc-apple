CURRENT_DIR=$(shell pwd)
WORKDIR=$(CURRENT_DIR)/work
SRCDIR=$(CURRENT_DIR)/src
DESTROOT=$(CURRENT_DIR)/destroot
SETUP_GCC_ARGS='--d-language-version=2'

all: setup fetch patch configure build

install:
	$(MAKE) -C $(WORKDIR) install

configure: 
	cd $(WORKDIR)/ && gcc-5465/configure \
		--build=i686-apple-darwin9 \
		--with-arch=nocona \
		--with-tune=generic \
		--host=i686-apple-darwin9 \
		--target=i686-apple-darwin9 \
		--prefix=/usr/local/gdc \
		--enable-languages=d \
		--with-system-zlib \
		# --with-slibdir=/usr/local/gdc/lib \
		--disable-nls \
		--disable-multilib
		
build:
	$(MAKE) -C $(WORKDIR) MAKEFLAGS=-j2 

patch: unpack-gcc copy-dgcc
	cd $(WORKDIR)/gcc-5465 && ./gcc/d/setup-gcc.sh $(SETUP_GCC_ARGS)

copy-dgcc:
	cp -r $(SRCDIR)/dgcc/d $(WORKDIR)/gcc-5465/gcc
	
unpack-gcc: 
	tar xfz $(SRCDIR)/gcc-5465.tar.gz -C $(WORKDIR)

fetch: fetch-gcc-5465 fetch-dgcc

fetch-gcc-5465: 
	cd $(SRCDIR) && wget -c http://www.opensource.apple.com/darwinsource/tarballs/other/gcc-5465.tar.gz

setup:
	mkdir -p $(WORKDIR) $(SRCDIR) $(DESTROOT)
	
fetch-dgcc: 
	svn co https://dgcc.svn.sourceforge.net/svnroot/dgcc/trunk $(SRCDIR)/dgcc

clean:
	rm -rf $(WORKDIR) $(DESTROOT)