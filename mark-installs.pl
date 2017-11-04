#!/usr/bin/perl
use strict;
die "Must be run as root\n" if `id -u`!=0;
`removepkg $ARGV[1]; rm /home/PACKAGES/$ARGV[1]*`, exit if $ARGV[0] eq '-u';
my ($auto,$clean,$pkg,$input,@srcs)=($ARGV[0] eq '-a',1,"","",());
$pkg=$ARGV[$auto];
die if system("tar -xf $pkg.*")!=0;
`cp $pkg*.* $pkg/`;
if (not $auto) {
	do {
		print `ls -l`,"More source files? (Blank line if none)\n";
		chop($input=<STDIN>);
		`cp $input $pkg/` and push @srcs,$input unless $input eq '';
	} while (not $input eq '');
}
die if system("cd $pkg && ./$pkg.SlackBuild")!=0;
`installpkg /tmp/$pkg*.t?z && mv /tmp/$pkg*.t?z /home/PACKAGES/`;
print "Clean up? (Y/n): " and chop($clean=<STDIN>) unless $auto;
if ($auto||$clean=~/[Yy]/||not $clean) {
	`rm -rf $pkg*`;
	`rm $_` for (@srcs);
}
print "Installation complete\n";
