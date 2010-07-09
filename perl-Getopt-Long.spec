%define modname Getopt-Long
%define modversion 2.38_02
%define path   Getopt

Name: perl-%{modname}
Version: %{modversion}
Release: 1
Source: http://www.perl.com/CPAN/modules/by-module/%{path}/%{modname}-%{version}.tar.gz
Packager: Johan Vromans <jvromans@squirrel.nl>
BuildRoot: /usr/tmp/%{name}-buildroot
Requires: perl >= 5.6.0
BuildRequires: perl >= 5.6.0
BuildArchitectures: noarch

Summary: Getopt::Long -- extended command line options
License: GPL or Artistic
Group: Command/Tools

%description
Module Getopt::Long implements an extended getopt function called
GetOptions(). This function implements the POSIX standard for command
line options, with GNU extensions, while still capable of handling
the traditional one-letter options.
In general, this means that command line options can have long names
instead of single letters, and are introduced with a double dash `--'.

Optionally, Getopt::Long can support the traditional bundling of
single-letter command line options.

IMPORTANT: Since Getopt::Long is part of core perl, installing this
kit requires the '--force' option to the rpm program.

%prep
%setup -n %{modname}-%{version}

%build
perl Makefile.PL
make all
make test

%install
rm -fr $RPM_BUILD_ROOT
make DESTDIR=$RPM_BUILD_ROOT install

# Remove some unwanted files
find $RPM_BUILD_ROOT -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -name perllocal.pod -exec rm -f {} \;

# Compress manual pages
test -x /usr/lib/rpm/brp-compress && /usr/lib/rpm/brp-compress

# Build distribution list
( cd $RPM_BUILD_ROOT ; find * -type f -printf "/%p\n" ) > files

%files -f files
%doc README CHANGES examples
