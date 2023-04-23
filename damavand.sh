#!/bin/bash

# ------------------------------------------------------------------
# [Title] : Damavand
# [Description] : Handle tree files when using git clone
# [Version] : v1.0.0
# [Author] : Lucas Noga
# [Shell] : Bash v5.1.0
# [Usage] : ./damavand.sh https://github.com/NY-Daystar/Addams
#           ./damavand.sh clone https://github.com/NY-Daystar/Addams --verbose
#           ./damavand.sh --setup
# ------------------------------------------------------------------

PROJECT_NAME=DAMAVAND
PROJECT_VERSION=v1.0.0

# Parameters to execute script
typeset -A CONFIG=(
    [folder]="./Repositories"   # TODO a commenter
    [script]="./damavand"       # TODO a commenter
    [bash_file]="./my_file.txt" # TODO a commenter
    [update]=false              # TODO a commenter
    [help]=false                # TODO a commenter
    [verbose]=false             # TODO a commenter
    [verbose_color]=light_blue  # Color to show log in verbose mode
)

# TODO gerer des valeurs par défauts pour
#   - [folder]="./Repositories"
#   - [script]="./damavand"
#   - [bash_file]="./my_file.txt"

###
# Main body of script starts here
###
function main {
    read_args $@
    log_verbose "Launch Project $(log_color "${PROJECT_NAME} : ${PROJECT_VERSION}" "yellow")"

    log_color "Git clone from damavand project" "blue"

    if [ ${CONFIG[help]} = true ]; then
        help
        exit 0
    fi

    ## Install script if needed
    need_setup
    if [ $(check_setup) -eq 1 ]; then
        log_color "Setup needed" "yellow"
        setup
        exit 0
    else
        log_verbose "No setup required"
    fi

    ## TODO english: Maj du script
    need_update
    if [ $(check_update) -eq 1 ]; then
        log_color "Update required" "yellow"
        update
        exit 0
    else
        log_verbose "No update required"
    fi

    ## program execution
    run $@
}

###
# Run clone command
# Affiche si le fichier setup $bash_file et est configuré
###
function run {
    args=("$@")
    first_param=${args[0]}

    # If no arguments for url repository
    if [ $# -eq 0 ] || [ $first_param = "-v" ] || [ $first_param = "--verbose" ]; then
        log_color "No arguments to proceed" "red"
        return
    fi

    if [ $first_param = 'clone' ]; then
        shift
    fi

    # Clone the repository in specific directory
    log_verbose : "Arguments left : $@"
    url=$1
    echo url: $url
    clone_project ${CONFIG[folder]} ${url}

    exit 0
}

### TODO english
# Clonne un depot git danns un dossier spécifique
# $1 : [string] - Chemin du dossier ou cloner le proojet
# $2 : [string] - Url du depot git
###
function clone_project {
    folder=$1
    url=$2

    project_path=$(get_project_path ${CONFIG[folder]} ${url})
    log_verbose "Project Path : ${project_path}"

    git_clone_command="git clone ${url} ${project_path}"
    log_verbose "Launch command: $git_clone_command"

    # Launch git clone command
    $git_clone_command
}

### TODO english
# Construction du chemin absolu ou sera cloné le repository en se basant sur l'url du dépôt git
# $1 : [string] - folder racine pour cloné le projet
# $2 : [string] - url du dépôt
# Return : [string] - Chemin absolu ou le projet sera cloné
###
function get_project_path {
    root_folder=$1
    url=$2

    # Get last element with /
    project_name=$(get_project_name ${url})

    path=${root_folder}/${project_name}
    echo $path
}

### TODO english
# Extrait le nom du projet depuis l'url du dépot git
# $1 : [string] - Url du dépot
## Return : [string] - Nom du projet
###
function get_project_name {
    url=$1
    sep="/"
    git_file=${url//*${sep}/}                       # Get string after last /
    git_project=$(echo "$git_file" | cut -d'.' -f1) # remove .git at the end of file
    echo $git_project
}

### TODO english
# Vérifie si l'installation à déjà été faite
# Affiche si le fichier setup $bash_file et est configuré
###
function need_setup {
    # TODO english: Vérifie si le fichier bash_profile existe
    if [ ! -f ${CONFIG[bash_file]} ]; then
        log_verbose "need_setup: le fichier ${CONFIG[bash_file]} n'existe pas" # TODO english
    else
        log_verbose "need_setup: le fichier ${CONFIG[bash_file]} existe" # TODO english
    fi

    if [ $(match_pattern_in_file "damavand" ${CONFIG[bash_file]}) -eq 0 ]; then
        log_verbose "need_setup: l'alias damavand n'est pas défini dans le fichier ${CONFIG[bash_file]}" # TODO english
    else
        log_verbose "need_setup: l'alias damavand est défini dans le fichier ${CONFIG[bash_file]}" # TODO english
    fi
}

### TODO english
# Vérifie si installation à déjà été faite
# Verifie  si le fichier setup $bash_file existe et est configuré
# Return : booléen 1 si l'install doit etre faite 0 sinon
###
function check_setup {
    result=0
    if [ ! -f ${CONFIG[bash_file]} ]; then
        result=1
    fi

    if [ $(match_pattern_in_file "damavand" ${CONFIG[bash_file]}) -eq 0 ]; then
        result=1
    fi
    echo $result
}

### TODO english
# TODO demander ou on souhaite l'installer
# Installation du projet et du script avec la configuratoin
# $1 : Path d'installation du script
###
function setup {
    log_color "Installation en cours" "yellow"

    # 0 - Create directory where we clone project if not exists
    mkdir -p ${CONFIG[folder]}

    # 1 - Création du fichier bash_profile ou bashrc s'il n'existe pas
    if [ ! -f ${CONFIG[bash_file]} ]; then
        log_verbose "Création du fichier ${CONFIG[bash_file]}"
        touch ${CONFIG[bash_file]}
    fi

    # 2 - Install script in right location
    script_location=${BASH_SOURCE[0]}
    if [ ! -f ${CONFIG[script]} ]; then
        log_verbose "Installation du script"
        cp $script_location ${CONFIG[script]}
    fi

    ## TODO a changer avec la fonction match_pattern
    if ! grep --quiet "damavand" ${CONFIG[bash_file]}; then
        log_verbose Add alias in ${CONFIG[bash_file]}
        echo -e "\nalias damavand=${CONFIG[script]}" >>${CONFIG[bash_file]}
        echo -e "alias git-clone=${CONFIG[script]}" >>${CONFIG[bash_file]}
        echo -e "alias gc=${CONFIG[script]}" >>${CONFIG[bash_file]}
    fi

    # 3 Execute bash file
    # TODO a activer
    #source ${CONFIG[bash_file]}

    log_color "Installation terminée" "green"
    log_color "Quitter et relancer un git bash pour prendre en compte l'instlallation" "yellow"
}

### TODO english
# Vérifie si le script doit être mis à jour
###
function need_update {
    if [ ${CONFIG[update]} = true ]; then
        log_verbose "need_update: l'update du script ${CONFIG[script]} est requise" # TODO english
    else
        log_verbose "need_update: l'update du script ${CONFIG[script]} n'est pas requise" # TODO english
    fi
}

### TODO english
# Vérifie si le script doit être mis à jour
# Return : [boolean] - true si la mise à jour doit etre faite, false sinon
###
function check_update {
    result=0
    if [ ${CONFIG[update]} = true ]; then
        result=1
    fi
    echo $result
}

### TODO english
# Vérifie si le script doit être mis à jour
# Return : booléen 1 si la mise à jour doit etre faite 0 sinon
###
function update {
    log_color "Update in progress..." "yellow"

    script_location=${BASH_SOURCE[0]}
    log_verbose "Copiyng from ${script_location} to ${CONFIG[script]}"
    cp $script_location ${CONFIG[script]}

    log_color "Update done" "green"
}

################################################################### CONFIG functions ###################################################################

###
# Setup params passed with the script
# -d | --verbose : Setup verbose mode
# --erase-trace : Erase file and your trace on remote machine
###
function read_args {
    params=("$@") # Convert params into an array

    # Check if verbose exists between all parametters
    for param in "${params[@]}"; do
        [[ $param == "-v" ]] || [[ $param == "--verbose" ]] && active_verbose_mode
    done

    # Step through all params passed to the script
    for param in "${params[@]}"; do
        IFS="=" read -r key value <<<"${param}"
        [[ -z $value ]] && log_verbose "Option key '$key' founded" || log_verbose "Option key '$key' value '$value' founded"
        case $key in
        "--help")
            log_verbose "Help script activated"
            set_config "help" "true"
            ;;
        "--update")
            log_verbose "update argument found"
            set_config "update" "true"
            ;;
        *) ;;
        esac
    done

    log_verbose "Dump: $(declare -p CONFIG)"
}

###
# Active the verbose mode by changing CONFIG params
###
function active_verbose_mode {
    if [ ${CONFIG[verbose]} == true ]; then
        log_verbose "verbose Mode already activated"
        return
    fi
    set_config "verbose" "true"
    log_verbose "verbose Mode Activated"
}

###
# Set value to the CONFIG array
# $1 : [string] key to update
# $2 : [string] value to set
###
function set_config {
    CONFIG+=([$1]=$2)
}

################################################################### Logging functions ###################################################################

###
# Return datetime of now (ex: 2022-01-10 23:20:35)
###
function get_datetime {
    log $(date '+%Y-%m-%d %H:%M:%S')
}

# TODO english
###
# Match pattern
# $1 : [string] : Pattern à rechercher
# $2 : [string] : Fichier dans lequel rechercher la chaine
# Returns : [boolean] : renvoie 1 si le pattern match dans le fichier, 0 sinon
###
function match_pattern_in_file {
    pattern=$1
    filepath=$2

    if grep --quiet -s ${pattern} ${filepath}; then
        echo 1
    else
        echo 0
    fi
}

###
# Simple log function to support color
###
function log {
    echo -e $@
}

typeset -A COLORS=(
    [default]='\033[0;39m'
    [black]='\033[0;30m'
    [red]='\033[0;31m'
    [green]='\033[0;32m'
    [yellow]='\033[0;33m'
    [blue]='\033[0;34m'
    [magenta]='\033[0;35m'
    [cyan]='\033[0;36m'
    [light_gray]='\033[0;37m'
    [light_grey]='\033[0;37m'
    [dark_gray]='\033[0;90m'
    [dark_grey]='\033[0;90m'
    [light_red]='\033[0;91m'
    [light_green]='\033[0;92m'
    [light_yellow]='\033[0;93m'
    [light_blue]='\033[0;94m'
    [light_magenta]='\033[0;95m'
    [light_cyan]='\033[0;96m'
    [nc]='\033[0m' # No Color
)

###
# Log the message in specific color
###
function log_color {
    message=$1
    color=$2
    log ${COLORS[$color]}$message${COLORS[nc]}
}

###
# Log the message if verbose mode is activated
###
function log_verbose {
    message=$@
    date=$(get_datetime)
    if [ "${CONFIG[verbose]}" = true ]; then log_color "[$date] $message" ${CONFIG[verbose_color]}; fi
}

################################################################################
# Help   TODO                                                                      #
################################################################################
help() {
    log "Usage damavand [-v | --verbose] [--update] [<args>]..."
    log "Version $PROJECT_VERSION"
    log "Git command to clone in a specific folder"
    log
    log "Syntax: archange [-v|--no-details|--setup|--history]"
    log "CONFIG:"
    log "\t -v, --verbose \t\t Verbose mode"
}

main $@
