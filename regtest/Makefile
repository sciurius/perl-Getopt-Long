# Makefile -- Makefile for regression testst
# Author : Johan Vromans

## * dmake/make compatible

## OS dependency

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

include Makefile.targets
