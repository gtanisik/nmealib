include Makefile.inc

#
# Settings
#

$(info OS is $(OS))

ifeq ($(OS),Windows_NT)
	PARAMS = -dir
	SUFFIX = .dll
else
	PARAMS = -lc
	SUFFIX = .so
endif

LIBNAME = libnmea$(SUFFIX)

DESTDIR ?=

MACHINE=$(shell uname -m)
ifeq ($(strip $(MACHINE)),x86_64)
LIBDIR = usr/lib64
else
LIBDIR = usr/lib
endif
INCLUDEDIR = usr/include

MODULES = context generate generator gmath info parse parser sentence time tok util
OBJ = $(MODULES:%=build/%.o)

LIBS = -lm
INCS = -I ./include


#
# Targets
#

all: all-before bin/$(LIBNAME)

remake: clean all

bin/$(LIBNAME): $(OBJ)
	@echo "[LD] $@"
	@$(CC) -shared -Wl,-soname=$(LIBNAME) -o bin/$(LIBNAME) $(OBJ) $(PARAMS)

build/%.o: src/%.c Makefile Makefile.inc
	@echo "[CC] $<"
	@$(CC) $(CCFLAGS) $(INCS) -c $< -o $@

samples: all
	$(MAKE) -C samples all


#
# Phony Targets
#

.PHONY: all-before clean doc install uninstall

all-before:
	@mkdir -p build bin

clean:
	$(MAKE) -C doc clean
	$(MAKE) -C samples clean
	rm -fr build bin

doc:
	$(MAKE) -C doc all

install: all
	@mkdir -v -p $(DESTDIR)/$(LIBDIR) $(DESTDIR)/$(INCLUDEDIR)
	cp bin/$(LIBNAME) $(DESTDIR)/$(LIBDIR)/$(LIBNAME).$(VERSION)
	$(STRIP) $(DESTDIR)/$(LIBDIR)/$(LIBNAME).$(VERSION)
	ldconfig -n $(DESTDIR)/$(LIBDIR)
	@rm -fr $(DESTDIR)/$(INCLUDEDIR)/nmea
	cp -r include/nmea $(DESTDIR)/$(INCLUDEDIR)

uninstall:
	rm -fr $(DESTDIR)/$(INCLUDEDIR)/nmea
	rm -f $(DESTDIR)/$(LIBDIR)/$(LIBNAME) $(DESTDIR)/$(LIBDIR)/$(LIBNAME).$(VERSION)
	ldconfig -n $(DESTDIR)/$(LIBDIR)
	@rmdir -v -p --ignore-fail-on-non-empty $(DESTDIR)/$(LIBDIR) $(DESTDIR)/$(INCLUDEDIR)
ifneq ($(DESTDIR),)
	@mkdir -v -p $(DESTDIR)
endif
