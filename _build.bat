@rem = '--*-Perl Script Wrapper-*--';
@rem = '
@echo off
set CMD=%0
set ARGS=
:loop
if .%1==. goto endloop
set ARGS=%ARGS% %1
shift
goto loop
:endloop
perl.exe -w -S %CMD% %ARGS%
goto endofperl
@rem ';

###############################################################################

use strict;

###########################################################
# Version

my $tm = localtime;
my $ver = shift || sprintf "internal %02d/%02d/%02d %02d:%02d", $tm->mday, $tm->mon+1, $tm->year-100, $tm->hour, $tm->min;
my $ver1 = $ver;
$ver1 =~ s/[\s\.]/_/g;
$ver1 =~ s/[\\\/\:]//g;

print "Building version $ver\n";

###########################################################
# Other vars

my $package = "..\\ac3filter_audition_$ver1";
my $zip = "..\\ac3filter_audition_$ver1.zip";
my $src = "ac3filter_audition_${ver1}_src.zip";

my $make_zip = "pkzip25 -add -rec -excl=CVS -lev=9 $zip $package\\*.*";
my $make_src = "pkzip25 -add -rec -dir -excl=CVS -lev=9 $src audition\\*.* valib\\*.*";

sub read_file
{
  my ($filename) = (@_);
  open (FILE, "< $filename");
  my @result = <FILE>;
  close (FILE);
  return @result;
}

sub write_file
{
  my $filename = shift;
  open (FILE, "> $filename");
  print FILE @_;
  close (FILE);
}

###############################################################################
##
## Clean
##

printf "Cleaning...\n";
`rmdir /s /q $package 2> nul`;
`mkdir $package`;


###############################################################################
##
## Build project
##

print "Building project...\n";

system('msdev audition.dsp /MAKE "audition - Win32 Release Libc" /REBUILD')
  && die "failed!!!";

`copy release_libc\\ac3filter.flt $package`;
`rmdir /s /q debug_libc   2> nul`;
`rmdir /s /q release_libc 2> nul`;
`_clear.bat`;

###############################################################################
##
## Prepare documentation files
##

`copy _readme.txt $package\\ac3filter_readme.txt`;
`copy _changes.txt $package\\ac3filter_changes.txt`;
`copy gpl.txt $package\\ac3filter_license`;


###############################################################################
##
## Make distributives
##

`del $zip 2> nul`;
`del $src 2> nul`;

system($make_zip);

chdir("..\\valib");
`_clear.bat`;
chdir("..");
system($make_src);

###############################################################################

__END__
:endofperl