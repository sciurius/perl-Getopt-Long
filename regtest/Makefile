# Makefile -- Makefile for regression tests
# Author          : Johan Vromans
# Created On      : Fri May 12 11:13:53 2000
# Last Modified By: Johan Vromans
# Last Modified On: Tue Feb 28 10:50:17 2017
# Update Count    : 25
# Status          : Unknown, Use with caution!

PERL	= perl -w -Mblib
OPT	= --verbose test.data

all :	test_basic test_aux

test_basic :
	$(PERL) -w driver1.pl $(OPT)

test_aux :
	for test in aux*.pl; do \
	  $(PERL) $$test || echo "FAILED: $$test"; \
	done
	perl -T -Mblib taint01.pl -opt1 value1 -opt2=value2 || echo "FAILED: taint01.pl"

