# Damavand project

TODO
**_Version v1.0.0_**

Shellescript
TODO : Save the history of a server by creating a file history

TODO: Developped in Bash `v5.1.0`

## Index

TODO

-   [Comming Next](#comming-next)
-   [Get Started](#get-started)
-   [Create alias](#create-a-persistant-alias)
-   [How to use](#how-to-use)
-   [Script options](#script-options)
-   [Trouble-shootings](#trouble-shootings)
-   [Credits](#credits)

## Get Started

```bash
$ git clone https://github.com/NY-Daystar/Damavand.git
$ cd Damavand
```

Then create your configuration file **settings.conf** base on the sample

```bash
$ cp settings.sample.conf settings.conf
$ vim settings.conf
```

TODO
Put this into the file with your server intels

```bash
IP="XX.XX.XX.XX"
PORT="XX"
PASSWORD="XXXXXX"
FOLDER_HISTORY="XXXXX"
```

TODO

-   IP (mandatory) : Ip of your server

TODO
Example

```bash
IP="192.168.1.1"
PORT="21"
PASSWORD="password"
FOLDER_HISTORY="./MyHistory" # Store files into the folder ./MyHistory
```

TODO

## Create a persistant alias

```bash
vim ~/.bash_aliases
```

Then put this line

```bash
alias git-clone="<PATH_TO_REPO>/damavand.sh"
alias gc=="<PATH_TO_REPO>/damavand.sh"
```

Then in your `~/.bashrc` or `~/bash_profile` execute `bash_aliases` with this

```bash
if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi
```

TODO

## How to use

If you setup the alias

```bash
$ gc <URL_REPOSITORY
```

TODO mettre un example

if not

```bash
$ ./damavand.sh
```

## Script options

TODO
Here's are the options on purpose  
Show help of the script

```bash
$ ./damavand.sh --help
```

Display debug mode

```bash
$ ./damavand.sh -v
$ ./damavand.sh --verbose
```

TODO: Setup configuration file

```bash
$ ./damavand.sh --setup
```

TODO: Erase trace on the server

```bash
$ ./damavand.sh --update
```

## Trouble-shootings

If you have any difficulties, problems or enquiries please let me an issue [here](https://github.com/NY-Daystar/Damavand/issues/new)

## Credits

Made by Lucas Noga  
Licensed under GPLv3.
