#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

void makeinstallpkg (char pkg[]);
void copysourcepkg (char pkg[],char src[]);
void showusage ();
void uninstall (char pkg[]);

int debug=0,automatic=0,error=0;

int main (int argc,char *argv[])
{
	puts("\nAutomated Slackware compile and install program by Mark Johnson\n");
	char nextcommand[50],yn[4];
	if (getuid()!=0)
	{
		puts("This program must be run as root.\n");
		return 1;
	}
	if (argc==3)
	{
		if (strcmp(argv[1],"-d")==0)
		{
			debug=1;
			argv[1]=argv[2];
		}
		else if (strcmp(argv[1],"-a")==0)
		{
			automatic=1;
			debug=1;
			argv[1]=argv[2];
		}
		else if (strcmp(argv[1],"-u")==0)
		{
			uninstall(argv[2]);
			return 0;
		}
		else
		{
			showusage();
			return 2;
		}
	}
	if (argc>=2)
	{
		if (strcmp(argv[1],"--help")==0)
		{
			showusage();
			return 2;
		}
		sprintf(nextcommand,"test -e %s.*",argv[1]);
		makeinstallpkg(argv[1]);
		return 0;
	}
	else if (argc==1)
	{
		char pkg[50];
		do
		{
			system("ls -l"); printf("\nWhat is the package name? : "); scanf("%s",&pkg);
			makeinstallpkg(pkg);
			printf("Do you have another package to install? (y/n) : ");
			scanf("%3s",yn);
		}
		while (strcmp(yn,"y")==0||strcmp(yn,"Y")==0);
		return 0;
	}
}

void makeinstallpkg (char pkg[])
{
	char nextcommand[200],src[50],yn[4]="n",srclist[50][50];
	int place=0;
	sprintf(nextcommand,"tar -xf %s.*",pkg);
	if (system(nextcommand)!=0)
	{
		do
		{	// There's a segfault in here somewhere... needs fixing
			printf("The SlackBuild archive \"%s\" does not exist.\n",pkg); system("ls -l");
			printf("Please enter the first portion of the name of the SlackBuild archive: ");
			scanf("%s",&pkg); printf("\n");
			sprintf(nextcommand,"tar -xvvf %s.*",pkg);
		}
		while (system(nextcommand)!=0);
	}
	strcpy(srclist[place],pkg);
	if (debug==1)
		printf("\nsrclist[%i] = %s\n",place,srclist[place]);
	copysourcepkg(pkg,pkg);
	printf("Is there more source code to install? (y/n) ");
	if (automatic==0)
		scanf("%3s",yn);
	while (strcmp(yn,"y")==0)
	{
		system("ls -l");
		printf("\nPlease enter the first portion of the name of the source archive: "); scanf("%s",src);
		place++; strcpy(srclist[place],src);
		if (debug==1)
			printf("\nsrclist[%i] = %s\n",place,srclist[place]);
		copysourcepkg(pkg,src);
		printf("Is there even more source code to copy? (y/n) ");
		scanf("%3s",yn);
	}
	printf("Would you like to review the SlackBuild? (y/n) ");
	if (automatic==0)
		scanf("%s",yn);
	printf("\n");
	if (strcmp(yn,"y")==0||strcmp(yn,"Y")==0)
		sprintf(nextcommand,"vi %s/%s.SlackBuild",pkg,pkg); system(nextcommand);
	sprintf(nextcommand,"cd %s/ && ./%s.SlackBuild && installpkg /tmp/%s*",pkg,pkg,pkg);
	if (system(nextcommand)!=0)
		error=1;
	printf("Clean? (y/n) ");
	if (automatic==0)
		printf("y\n");
		scanf("%3s",yn);
	else if (error=0)
		strcpy(yn,"y");
	else
	{
		printf("\n\nError! Will not clean up.\n");
		strcpy(yn,"n");
	}
	if (strcmp(yn,"y")==0||strcmp(yn,"Y")==0)
	{
		int i=0;
		if (debug==1)
			printf("place = %i\nnextcommand= \"rm -rf %s\"\n",i,srclist[i]);
		sprintf(nextcommand,"rm -rf %s",pkg,pkg); system(nextcommand);
		while (i<=place)
		{
			if (debug==1)
				printf("place = %i\nnextcommand = \"rm %s*.*\"\n",i,srclist[i]);
			sprintf(nextcommand,"rm %s*.*",srclist[i]); system(nextcommand);
			i++;
		}
	}
	printf("\n");
}

void copysourcepkg(char pkg[],char src[])
{
	printf("Copying source code %s*.* to %s\n",src,pkg);
	char nextcommand[100];
	sprintf(nextcommand,"cp %s*.* %s",src,pkg);
	if (system(nextcommand)!=0)
	{
		do
		{
		printf("The source code does not follow the expected pattern %s*.*\n",src); system("ls -l");
		printf("Please enter the first portion of the name of the source archive: "); scanf("%s\n",&src);
		sprintf(nextcommand,"cp %s*.* %s",src,pkg);
		}
		while (system(nextcommand)!=0);
	}
}

void showusage()
{
	printf("Usage:\n\n");
	printf("mark-installs --help            --  shows this menu\n\n");
	printf("mark-installs                   --  requests package name, then installs\n");
	printf("mark-installs [PACKAGENAME]     --  installs PACKAGENAME\n");
	printf("\tNote: mark-installs looks only in the current directory\n");
	printf("mark-installs -d [PACKAGENAME]  --  see above, but in debug mode\n");
	printf("mark-installs -a [PACKAGENAME]  --  see above, but automatically\n");
	printf("mark-installs -u [PACKAGENAME]  --  uninstalls PACKAGENAME\n\n");
}

void uninstall(char pkg[])
{
	char nextcommand[100];
	printf("Uninstalling \"%s\"\n",pkg);
	sprintf(nextcommand,"removepkg %s && rm /tmp/%s*.tgz",pkg,pkg);
	if (system(nextcommand)!=0)
	{
		do
		{	// There's a segfault in here, too.
			printf("\nThat package does not appear to be installed.\n");
			printf("Please enter a correct package name: "); scanf("%s",&pkg);
			printf("\n"); sprintf("removepkg %s && rm /tmp/%s*.tgz",pkg,pkg);
		}
		while (system(nextcommand)!=0);
	}
}
/*	This program is a rewrite of this old bash script I wrote which is not nearly as advanced

echo ""; 	echo "|====================================================|"
		echo "|Automated compile and install script by Mark Johnson|"
		echo "|====================================================|"; echo -e
		echo "This script assumes you have the necessary dependencies."

function MAKE_INSTALL_PACKAGE () {
if [[ -a $PACKAGENAME.* ]]; then
	echo "The package does not exist."
fi
tar -xvvf $PACKAGENAME.*
cp $PACKAGENAME*.* $PACKAGENAME && cd $PACKAGENAME/ && vi $PACKAGENAME.SlackBuild
./$PACKAGENAME.SlackBuild && installpkg /tmp/$PACKAGENAME* && cd ../
echo "Clean up? (Y/n)"; read CLEAN
if [[ "$CLEAN" = "y" || "$CLEAN" = "Y" ]]; then
	rm $PACKAGENAME.* && rm $PACKAGENAME*.* && rm -R $PACKAGENAME; fi
}

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root."; echo -e
	exit 1
fi
if [[ $# -eq 0 ]]; then
	AGAIN="y"
	while [[ "$AGAIN" = "y" || "$AGAIN" = "Y" ]]; do
		ls; echo "What is the name of the package?"
		read PACKAGENAME
		MAKE_INSTALL_PACKAGE
		echo "Do you have another package to install? (y/N)"
		read AGAIN
	done
else
	PACKAGENAME="$1"
	MAKE_INSTALL_PACKAGE
fi
exit 0

*/
