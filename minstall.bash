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
