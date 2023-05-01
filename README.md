# Damavand project

**_Version v1.0.0_**

Shellscript project to clone repository in a default folder

Developped in Bash `v5.1.0`

## Index

-   [Get Started](#get-started)
-   [Create alias](#create-a-persistant-alias)
-   [How to use](#how-to-use)
-   [Script options](#script-options)
-   [Trouble-shootings](#trouble-shootings)
-   [Credits](#credits)

## Get Started

```bash
git clone https://github.com/NY-Daystar/Damavand.git
cd Damavand
```

Then create your configuration file **settings.conf** base on the sample

```bash
cp settings.sample.conf settings.conf
vim settings.conf
```

Put this into the file with your server intels

```bash
DAMAVAND_GIT_FOLDER="XXXXXXXX"
DAMAVAND_DOWNLOAD_PATH="XXXXXXXX"
```

-   DAMAVAND_GIT_FOLDER (mandatory) : Folder path where script clone git project
-   DAMAVAND_DOWNLOAD_PATH (mandatory) : Folder path where script updates are stored

Example

```bash
DAMAVAND_GIT_FOLDER="~/Repositories"
DAMAVAND_DOWNLOAD_PATH="~/Downloads"
```

## How to use

Launch the script for the first time
It will install what it needed

```bash
./damavand.sh
```

After you can use bash aliases like

```bash
damavand
git-clone
gc
```

To clone a repository use this command

```bash
damavand <URL_REPOSITORY>
# ex: damavand https://github.com/NY-Daystar/Addams
```

## Script options

Here's are the options on purpose  
Show help of the script

```bash
$ ./damavand.sh --help
```

Display debug mode

```bash
./damavand.sh -v
# ex ./damavand https://github.com/NY-Daystar/Addams --verbose
```

Setup configuration file

```bash
$ ./damavand.sh --setup-settings
```

Show configuration file

```bash
$ ./damavand.sh --show-settings
```

Update script

```bash
$ ./damavand.sh --update
```

## Trouble-shootings

If you have any difficulties, problems or enquiries please let me an issue [here](https://github.com/NY-Daystar/Damavand/issues/new)

## Credits

Made by Lucas Noga  
Licensed under GPLv3.
