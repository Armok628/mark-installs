#!/usr/bin/perl
use strict;
use warnings;
# Check appropriate UID
`id -u`==0 or die "Must be run as root\n";
# Check for arguments
@ARGV or die "Must specify package\n";
# Act appropriately for uninstall argument
system("removepkg $ARGV[1]; rm /home/PACKAGES/$ARGV[1]*"), exit if $ARGV[0] eq '-u';
# Initialize variables
my ($auto,$clean,$pkg,$input,@srcs,@reqs)=($ARGV[0] eq '-a',1,"","",(),());
$pkg=$ARGV[$auto];
# Extract SlackBuild archive
!system("tar -xf $pkg.*") or die;
# Check for present requirements
for (`cat $pkg/$pkg.info`) {push @reqs, split(/ /,$1) if ($_=~/REQUIRES="(.*)"/)}
!@reqs or print "Requirements:\n";
for (@reqs) {
	my $found=!system("ls /var/log/packages | grep -i $_ >/dev/null");
	print "$_ ",$found?'(Found)':'',"\n";
}
# Copy sources to build directory
system("cp $pkg*.* $pkg/");
if (not $auto) {
	do {
		system("ls -l");
		print "More sources? (Blank line if none)\n";
		chop($input=<STDIN>);
		push @srcs,$input if ($input and !system("cp $input $pkg/"));
	} while $input;
} else {for (@ARGV[2..@ARGV-1]) {push @srcs,$_ if !system("cp $_ $pkg/")}}
# Execute SlackBuild script
!system("cd $pkg && ./$pkg.SlackBuild") or die;
# Install and back up compiled package
system("installpkg /tmp/$pkg*.t?z && mv /tmp/$pkg*.t?z /home/PACKAGES/");
# Delete used files
print "Clean up? (Y/n): " and chop($clean=<STDIN>) unless $auto;
if ($auto||$clean=~/[Yy]/||not $clean) {
	system("rm -rf $pkg*");
	system("rm $_") for (@srcs);
}
# Report success
print "Installation complete\n";
