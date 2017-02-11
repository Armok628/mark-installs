# mark-installs
SlackBuild installation tool, written in bash. This is obviously not intended to replace/improve pkgtools in any way. This tool is purely for convenience's sake.

To install, do `chmod +x mark-installs && mv mark-installs /bin/` as root

Update 2/11/17: The project is returning to its roots as a bash script.

Long ago, I rewrote the script in C to get more experience with C, particularly with strings. It used so many system calls that it might as well have been in bash anyway, so it wasn't worth maintaining in C. However, it also had more features than the original, so despite having issues, it was better to use than the original script. Today I decided to update the bash version to include everything the C version had. The only thing it still lacks is an -h option and a -d option (which didn't do very much anyway).

The only command line argument for the script is -a, which installs the package automatically, assuming that SlackBuild and source archives follow the most common naming convention. A good rule of thumb is that if you can hit tab and autocomplete the name of the package without getting .tar.gz at the end, it can almost always be installed automatically if no other source archives are needed.
