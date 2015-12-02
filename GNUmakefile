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

.PHONY : dist
dist :
	$(MAKE) -f Makefile dist

.PHONY : tardist
tardist :
	$(MAKE) -f Makefile tardist

.PHONY : install
install :
	$(MAKE) -f Makefile install
