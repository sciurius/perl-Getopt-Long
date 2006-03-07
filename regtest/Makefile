# Makefile -- Makefile for regression testst
# RCS Info        : $Id$
# Author          : Johan Vromans
# Created On      : Fri May 12 11:13:53 2000
# Last Modified By: Johan Vromans
# Last Modified On: Tue Apr 30 12:58:33 2002
# Update Count    : 12
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
	  $(PERL) $$test; \
	done
