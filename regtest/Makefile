# Makefile -- Makefile for regression testst
# RCS Info        : $Id$
# Author          : Johan Vromans
# Created On      : Fri May 12 11:13:53 2000
# Last Modified By: Johan Vromans
# Last Modified On: Thu Nov 16 14:16:45 2006
# Update Count    : 13
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
	  $(PERL) $$test || echo FAIL; \
	done
