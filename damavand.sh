#!/bin/bash

# ------------------------------------------------------------------
# [Title] : Damavand
# [Description] : Handle tree files when using git clone
# [Version] : v1.1.0
# [Author] : Lucas Noga
# [Shell] : Bash v5.1.0
# [Usage] : ./damavand.sh https://github.com/NY-Daystar/Addams
#           ./damavand.sh clone https://github.com/NY-Daystar/Addams --verbose
#           ./damavand.sh --setup
# ------------------------------------------------------------------

PROJECT_NAME=DAMAVAND
PROJECT_VERSION=v1.1.0

# Parameters to execute script
typeset -A CONFIG=(
    [folder]="./Repositories"  # Folder location of git repositories
    [script]="./damavand"      # Location of script project
    [bash_file]="./bash_file"  # Location of bash file to define aliases
    [update]=false             # Update mode to update script
    [help]=false               # Show help if asked
    [verbose]=false            # Debug mode
    [verbose_color]=light_blue # Color to show log in verbose mode
)

# TODO faire un read settings
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

    ## Update the script if needed
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
###
function run {
    args=("$@")
    first_param=${args[0]}

    # If no arguments for url repository
    if [ $# -eq 0 ] || [ $first_param = "-v" ] || [ $first_param = "--verbose" ]; then
        log_color "No arguments to proceed,\nPlease complete argument with gitlab url" "red"
        log_color "ex: $ damavand https://github.com/LucasNoga/Dathomir" "red"
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

###
# Clone git repository in a specific folder
# $1 : [string] - Path to clone the project
# $2 : [string] - URL of git repository
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

    if [ $? = 0 ]; then
        log "Execute following command : "
        pp=$(echo $project_path | sed 's/\\/\//g')
        log_color "cd $pp" 'yellow'
    fi
}

###
# Construct absolute path to clone repository from git url
# $1 : [string] - root folder to clone project
# $2 : [string] - URL of git repository
# Returns : [string] - Absolute path of clone
###
function get_project_path {
    root_folder=$1
    url=$2

    # Get last element with /
    project_name=$(get_project_name ${url})

    path=${root_folder}/${project_name}
    echo $path
}

###
# Extract name of the project
# $1 : [string] - URL of git repository
## Returns : [string] - Project name
###
function get_project_name {
    url=$1
    sep="/"
    git_file=${url//*${sep}/}                       # Get string after last /
    git_project=$(echo "$git_file" | cut -d'.' -f1) # Remove .git at the end of file
    echo $git_project
}

###
# Check if installation is already done
# Display if bash_file on configuration is setup or not
###
function need_setup {
    if [ ! -f ${CONFIG[script]} ]; then
        log_verbose "need_setup: file ${CONFIG[script]} doesn't exist"
    else
        log_verbose "need_setup: file ${CONFIG[script]} already exists"
    fi

    if [ ! -f ${CONFIG[bash_file]} ]; then
        log_verbose "need_setup: file ${CONFIG[bash_file]} doesn't exist"
    else
        log_verbose "need_setup: file ${CONFIG[bash_file]} already exists"
    fi

    if [ $(match_pattern_in_file "damavand" ${CONFIG[bash_file]}) -eq 0 ]; then
        log_verbose "need_setup: 'damavand' alias is not defined in the file ${CONFIG[bash_file]}"
    else
        log_verbose "need_setup: 'damavand' alias is already defined in the file ${CONFIG[bash_file]}"
    fi
}

###
# Check if installation is already done
# Check if bash_file exists or not
# Return : [boolean] true if install needed
###
function check_setup {
    result=0

    if [ ! -f ${CONFIG[script]} ]; then
        result=1
    fi

    if [ ! -f ${CONFIG[bash_file]} ]; then
        result=1
    fi

    if [ $(match_pattern_in_file "damavand" ${CONFIG[bash_file]}) -eq 0 ]; then
        result=1
    fi
    echo $result
}

###
# Install script to execute it with the configuration
# $1 : [string] script path
###
function setup {
    log_color "Install in progress" "yellow"

    # 0 - Create directory where we clone project if not exists
    mkdir -p ${CONFIG[folder]}

    # 1 - Création du fichier bash_profile ou bashrc s'il n'existe pas
    if [ ! -f ${CONFIG[bash_file]} ]; then
        log_verbose "Creating file : ${CONFIG[bash_file]}"
        touch ${CONFIG[bash_file]}
    fi

    # 2 - Install script in right location
    script_location=${BASH_SOURCE[0]}
    if [ ! -f ${CONFIG[script]} ]; then
        log_verbose "Script installing"
        cp $script_location ${CONFIG[script]}
    fi

    if [ $(match_pattern_in_file "damavand" ${CONFIG[bash_file]}) -eq 0 ]; then
        log_verbose Add alias in ${CONFIG[bash_file]}
        echo -e "\nalias damavand=${CONFIG[script]}" >>${CONFIG[bash_file]}
        echo -e "alias git-clone=${CONFIG[script]}" >>${CONFIG[bash_file]}
        echo -e "alias gc=${CONFIG[script]}" >>${CONFIG[bash_file]}
    fi

    log_color "Install done" "green"
    log_color "Quit and relaunch your bash to integrate the script" "yellow"
}

###
# Check if the script has to be update by param
###
function need_update {
    if [ ${CONFIG[update]} = true ]; then
        log_verbose "need_update: script update is required for file : ${CONFIG[script]}"
    else
        log_verbose "need_update: script update is not required for file : ${CONFIG[script]}"
    fi
}

###
# Check if the script has to be update
# Returns : [boolean] - true if update is required false otherwise
###
function check_update {
    result=0
    if [ ${CONFIG[update]} = true ]; then
        result=1
    fi
    echo $result
}

###
# Update the script
###
function update {

    # TODO faire un read api pour ca de gitlab
    # TODO Connect to gitlab and download the script
    # TODO Faire la doc

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

###
# Match pattern
# $1 : [string] : Pattern to search
# $2 : [string] : File path to search on its content the pattern
# Returns : [boolean] : 1 if matched, otherwise 0
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
# Help                                                                     #
################################################################################
help() {
    # TODO
    log "Usage damavand [-v | --verbose] [--update] [<args>]..."
    log "Version $PROJECT_VERSION"
    log "Git command to clone in a specific folder"
    log
    log "Syntax: archange [-v|--no-details|--setup|--history]"
    log "CONFIG:"
    log "\t -v, --verbose \t\t Verbose mode"
}

main $@
