# image-checker
Checks images for aspect ratio and moves into appropriate folder. Checks a tmp download folder for image aspect ratio. Sorts each type into appropriate folders (landscape and portrait style photos). My use case is to sort mass downloaded wallpaper images into appropriate folders for use as a multi-monitor wallpaper configuration. I use both landscape or portrait orientated monitors and source the wallpapers in seperate folders for each.

The script has not been sanitized or desgined for public consumption, modifications to the code will be needed for use outside of my systems. This includes:

- Modifying the paths to meet your needs.
- The last item calls a sync script. Use or remove as needed.

Usage:

If no arguments are used, the script will use all hardcoded paths defined internally. If a path argument ($arg[0]) is provided, this will replace the $tmp variable inside the script. There are no current provisions for providing other paths as command line arguments.

