# Makefile -- Makefile for regression testst
# Author          : Johan Vromans
# Created On      : Fri May 12 11:13:53 2000
# Last Modified By: Johan Vromans
# Last Modified On: Fri Jul  9 14:26:01 2010
# Update Count    : 19
# Status          : Unknown, Use with caution!

PERL	= perl -w -Mblib
OPT	= --verbose test.data

all:	test1 aux

test1:
	$(PERL) -w driver1.pl $(OPT)

kit:
	@echo "use 'perl Makefile.PL; make dist'"

aux:
	for test in aux*.pl; do \
	  $(PERL) $$test || echo "FAILED: $$test"; \
	done
	perl -T -Mlib=../blib/lib taint01.pl -opt1 value1 -opt2=value2 || echo "FAILED: taint01.pl"
