echo "";	echo "|======================================================|"
		echo "| Automated compile and install script by Mark Johnson |"
		echo "|======================================================|"; echo -e
		echo "This script assumes you have the necessary dependencies."

function MAKE_INSTALL_PACKAGE {
if [[ -a $PACKAGENAME.* ]]; then
	echo "The package does not exist."
fi
tar -xvvf $PACKAGENAME.*
cp $PACKAGENAME*.* $PACKAGENAME/
if ! $AUTOMATIC; then
	SOURCEINDEX=0
	SOURCES=()
	while [[ "${SOURCE[$SOURCEINDEX]}" != "" ]]; do
		ls -l .
		echo "Are there any other sources? (Press enter if none left)"
		read SOURCES[SOURCEINDEX]
		if [[ -e "${SOURCES[$SOURCEINDEX]}*.*" ]]; then
			cp ${SOURCES[$SOURCEINDEX]}*.* $PACKAGENAME/
			((SOURCEINDEX++))
		fi
	done
fi
cd $PACKAGENAME
if ! $AUTOMATIC; then
	echo "Edit SlackBuild? (y/N)"; read EDIT
	if [[ "$EDIT" = "y" || "$EDIT" = "Y" ]]; then
		vi $PACKAGENAME.SlackBuild
	fi
	unset EDIT
fi
./$PACKAGENAME.SlackBuild && installpkg /tmp/$PACKAGENAME* && cd ../
if ! $AUTOMATIC; then
	echo "Clean up? (Y/n)"; read CLEAN
	if [[ "$CLEAN" != "n" || "$CLEAN" != "N" ]]; then
		rm $PACKAGENAME.* $PACKAGENAME*.* && rm -R $PACKAGENAME
		for PACKAGE in $PACKAGES; do
			rm $PACKAGE*.*
		done
		unset SOURCEINDEX SOURCES
	fi
	unset CLEAN
else
	rm $PACKAGENAME.* && rm $PACKAGENAME*.* && rm -R $PACKAGENAME
fi
}

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root."; echo -e
	exit 1
fi
if [[ $# -eq 0 ]]; then
	AUTOMATIC=false
	AGAIN="y"
	while [[ "$AGAIN" = "y" || "$AGAIN" = "Y" ]]; do
		ls; echo "What is the name of the package?"
		read PACKAGENAME
		MAKE_INSTALL_PACKAGE true
		echo "Do you have another package to install? (y/N)"
		read AGAIN
	done
else
	if [[ "$1" = "-a" ]]; then
		PACKAGENAME="$2"
		AUTOMATIC=true
		MAKE_INSTALL_PACKAGE
	else
		PACKAGENAME="$1"
		AUTOMATIC=false
		MAKE_INSTALL_PACKAGE
	fi
fi
exit 0
