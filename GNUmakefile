# Getopt::Long has its own Makefile (produced from Makefile.PL). Since
# I'm using GNU make, I use this GNUmakefile (which will always be
# preferred) for my personal convenience.

.PHONY : all
all :	cleanup
	perl Makefile.PL
	$(MAKE) -f Makefile all

.PHONY : test
test :
	$(MAKE) -f Makefile test

.PHONY : regtest
regtest :
	( cd regtest; $(MAKE) )

.PHONY : clean
clean : cleanup
	rm -f *~

.PHONY : cleanup
cleanup :
	if test -f Makefile; then \
	    $(MAKE) -f Makefile clean; \
	fi

.PHONY : tardist
tardist :
	$(MAKE) -f Makefile tardist

.PHONY : install
install :
	$(MAKE) -f Makefile install

MODIR := locale
LOCALES := nl
xxlocales :
	for locale in $(LOCALES); \
	do \
	  test -d $(MODIR)/$$locale || mkdir -p $(MODIR)/$$locale; \
	  ( cd locale; \
	    sh make_locales_$$locale; \
	  ); \
	done

PODIR := locale
locales :
	for locale in $(LOCALES); \
	do \
	  test -d $(MODIR)/$$locale/LC_MESSAGES || mkdir -p $(MODIR)/$$locale/LC_MESSAGES; \
	done
	msgfmt -c -v -o $(MODIR)/en/LC_MESSAGES/ebcore.mo    $(PODIR)/ebcore-en.po
	msgfmt -c -v -o $(MODIR)/nl/LC_MESSAGES/ebwxshell.mo $(PODIR)/ebwxshell-nl.po

