# Makefile -- Makefile for regression testst
# Author          : Johan Vromans
# Created On      : Fri May 12 11:13:53 2000
# Last Modified By: Johan Vromans
# Last Modified On: Fri Jul  9 14:26:01 2010
# Update Count    : 19
# Status          : Unknown, Use with caution!

PERL	= perl -w -Mblib
OPT	= --verbose test.data

#### OS dependent section (dmake/make compatible)

ifeq ($(OS),Windows_NT)
    OS_detected := MSWindows
else
    OS_detected := $(shell uname -s)
endif

ifeq ($(OS_detected),MSWindows)
	DOLLAR := $$
else
	DOLLAR := \$$
endif

####

all:	test test_aux

test:
	$(PERL) -w driver1.pl $(OPT)

test_aux:
	$(PERL) -E "use English; @files = glob(q/aux*.pl/); for (@files) { print qx[ $(DOLLAR)EXECUTABLE_NAME $(DOLLAR)_ || echo 'FAILED: $(DOLLAR)_'] }"
	perl -T -Mlib=../blib/lib taint01.pl -opt1 value1 -opt2=value2 || echo 'FAILED: taint01.pl'

####

kit:
	@echo "use 'perl Makefile.PL; make dist'"

_info:
	@echo "OS_detected = '$(OS_detected)'"
	@echo "DOLLAR = '$(DOLLAR)'"
