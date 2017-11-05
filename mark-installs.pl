#!/usr/bin/perl
use strict;
use warnings;
`id -u`==0 or die "Must be run as root\n";
@ARGV or die "Must specify package\n";
system("removepkg $ARGV[1]; rm /home/PACKAGES/$ARGV[1]*"), exit if $ARGV[0] eq '-u';
my ($auto,$clean,$pkg,$input,@srcs)=($ARGV[0] eq '-a',1,"","",());
$pkg=$ARGV[$auto];
die if system("tar -xf $pkg.*");
system("cp $pkg*.* $pkg/");
if (not $auto) {
	do {
		system("ls -l");
		print "More sources? (Blank line if none)\n";
		chop($input=<STDIN>);
		push @srcs,$input if ($input && !system("cp $input $pkg/"));
	} while $input;
}
die if system("cd $pkg && ./$pkg.SlackBuild");
system("installpkg /tmp/$pkg*.t?z && mv /tmp/$pkg*.t?z /home/PACKAGES/");
print "Clean up? (Y/n): " and chop($clean=<STDIN>) unless $auto;
if ($auto||$clean=~/[Yy]/||not $clean) {
	system("rm -rf $pkg*");
	system("rm $_") for (@srcs);
}
print "Installation complete\n";
