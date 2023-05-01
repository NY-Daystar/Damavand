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
PROJECT_VERSION=v1.1.0

# Parameters to execute script
typeset -A CONFIG=(
    [script]="$HOME/.damavand"        # Location of script project
    [bash_file]="$HOME/.bash_profile" # Location of bash file to define aliases
    [script_location]="."             # Get absolute path to where is the script executed

    [settings_prefix]=$PROJECT_NAME # For settings.conf variable already used in the system ($USER, $PATH)
    [settings_file]="settings.conf" # Configuration file

    [setup_settings]=false # If true launch script to setup configuration file
    [show_settings]=false  # If true launch script to show configuration file
    [update]=false         # Update mode to update script
    [help]=false           # Show help if asked

    [verbose]=false            # Debug mode
    [verbose_color]=light_blue # Color to show log in verbose mode

    [default_git_folder]="./Repositories"  # Default folder location of git repositories
    [default_download_path]="~/Downloads/" # Default folder to download script's update
)

# SETTINGS base on setting.conf file
typeset -A SETTINGS=(
    [git_folder]=""    # Folder location of git repositories (Default : ./Repositories)
    [download_path]="" # # Folder to download script's update (Default : ./Download)
)

###
# Main body of script starts here
###
function main {
    read_args $@
    log_verbose "Launch Project $(log_color "${PROJECT_NAME} : ${PROJECT_VERSION}" "yellow")"

    log_color "Git clone from damavand project" "blue"

    set_config "script_location" "$(dirname $0)"
    log_verbose "Folder where script localized: $(log_color "${CONFIG[script_location]}" "yellow")"

    # Read .conf file (default ./setting.conf)
    read_settings "${CONFIG[script_location]}" "${CONFIG[settings_file]}"

    if [ ${CONFIG[help]} = true ]; then
        help
        exit 0
    fi

    if [ ${CONFIG[setup_settings]} = true ]; then
        setup_settings "${CONFIG[script_location]}/${CONFIG[settings_file]}"
        exit 0
    fi

    if [ ${CONFIG[show_settings]} = true ]; then
        show_settings
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

    log_verbose url: $url
    log_verbose git_foler: ${SETTINGS[git_folder]}

    clone_project ${SETTINGS[git_folder]} ${url}

    exit 0
}

###
# Clone git repository in a specific folder
# $1 : [string] - Path to clone the project
# $2 : [string] - URL of git repository
###
function clone_project {
    git_folder=$1
    url=$2

    project_path=$(get_project_path ${git_folder} ${url})
    log_verbose "Project Path : ${project_path}"

    git_clone_command="git clone ${url} ${project_path}"
    log_verbose "Launch command: $git_clone_command"

    # Launch git clone command
    $git_clone_command

    if [ $? = 0 ]; then
        pp=$(echo $project_path | sed 's/\\/\//g')
        log "Execute following command : " $(log_color "cd $pp" "yellow")
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
    mkdir -p ${CONFIG[git_folder]}

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
    log_color "Update in progress..." "yellow"

    local_file=${SETTINGS[download_path]}/damavand.sh
    url="https://raw.githubusercontent.com/NY-Daystar/Damavand/main/damavand.sh"

    log_verbose download_file from ${url} to ${local_file}
    download_file ${url} ${local_file}

    log_verbose "Copiyng from ${local_file} to ${CONFIG[script]}"
    cp ${local_file} ${CONFIG[script]}

    log_color "Update done" "green"
}

###
# Download file from url
# $1 : [string] - URL of file to download
# $2 : [string] - local file_path to store it
###
function download_file {
    url_file=$1
    local_file=$2

    log_verbose "Downloading file ${url_file} into ${local_file}"

    cmd="curl -s -o ${local_file} ${url_file}"

    log_verbose curl command : $cmd

    $cmd

    log_verbose "Download successful on ${local_file}"
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
        "--show-settings")
            log_verbose "show-settings argument found"
            set_config "show_settings" "true"
            ;;
        "--setup-settings")
            log_verbose "setup-settings argument found"
            set_config "setup_settings" "true"
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

################################################################### Settings functions ###################################################################

###
# Setup variables from settings file
# $1 = path to the settings file (default: ./)
# $2 = name of the settings file (default: settings.conf)
###
function read_settings {
    path=$1
    filename=$2
    settings_file="$path/$filename"

    # if we directly pass settings file
    if [ $# -ne 2 ]; then
        settings_file=$1
    fi

    log_verbose "Read configuration file: $settings_file"

    if [ ! -f "$settings_file" ]; then
        log_color "WARN: $settings_file doesn't exists." "yellow"
        log "Creating the file ${CONFIG[settings_file]}..."
        setup_settings ${CONFIG[settings_file]}
    fi

    # Load configuration file
    . "$settings_file"

    SETTINGS+=(
        [git_folder]=$(eval echo \$${CONFIG[settings_prefix]}"_GIT_FOLDER")       # Env variable already defined in the system ($USER) so we prefix it with DAMAVAND_
        [download_path]=$(eval echo \$${CONFIG[settings_prefix]}"_DOWNLOAD_PATH") # Env variable already defined in the system ($USER) so we prefix it with DAMAVAND_
    )

    # Check empty values
    if [ -z ${SETTINGS[git_folder]} ]; then
        log_color "ERROR: DAMAVAND_PATH is not defined into $settings_file" "red"
        log_color "Get default value for DAMAVAND_PATH : ${CONFIG[default_git_folder]}" "yellow"
        SETTINGS+=([git_folder]="${CONFIG[default_git_folder]}")
    fi
    if [ -z ${SETTINGS[download_path]} ]; then
        log_color "ERROR: DAMAVAND_DOWNLOAD_PATH is not defined into $settings_file" "red"
        log_color "Get default value for DAMAVAND_DOWNLOAD_PATH : ${CONFIG[default_download_path]}" "yellow"
        SETTINGS+=([download_path]="${CONFIG[default_download_path]}")
    fi

    log_verbose "Configuration file $settings_file loaded"
    log_verbose "Dump: $(declare -p SETTINGS)"
}

###
# List settings in settings.conf file if they are defined
# $1: path where the settings file is (default: "<script_location_path>/settings.conf")
###
function show_settings {
    file=$1
    # get default configuration file if no filled
    if [ -z $file ]; then
        file=${CONFIG[settings_file]}
    fi

    log "Here's your settings: "
    log "\t- Path where repositories are cloned:" $(log_color "${SETTINGS[git_folder]}" "yellow")
    log "\t- Download_path:" $(log_color "${SETTINGS[download_path]}" "yellow")
}

###
# Setup the settings in command line for the user, if the file exists we erased it
# $1: path where the settings file is (default: <script_location_path>/settings.conf")
###
function setup_settings {
    file=$1
    log "Setup settings need some intels to create your settings"
    # get default configuration file if no filled
    if [ -z $file ]; then
        file=${CONFIG[settings_file]}
    fi
    # Check if you want to override the file
    if [ -f $file ]; then
        override=$(ask_yes_no "$(log_color "$file" "yellow") already exists do you want to override it")
        if [ "$override" == false ]; then
            log_color "Abort settings editing - no override" "red"
            exit 0
        fi
    fi

    # DEFAULT VALUES
    typeset -A DEFAULT_VALUES=(
        [GIT_FOLDER]=${CONFIG[default_git_folder]}
        [DOWNLOAD_PATH]=${CONFIG[default_download_path]}
    )

    log_verbose "Dump: $(declare -p DEFAULT_VALUES)"
    log_color "Actual path: $(pwd)" "magenta"

    # Read value for the user
    git_folder=$(read_data "Folder location of git repositories (default: $(log_color ${DEFAULT_VALUES[GIT_FOLDER]} yellow))" "text")
    download_path=$(read_data "Folder to download script's update (default: $(log_color ${DEFAULT_VALUES[DOWNLOAD_PATH]} yellow))" "text")

    typeset -A INPUTS+=(
        [GIT_FOLDER]="$git_folder"
        [DOWNLOAD_PATH]="$download_path"
    )

    # Check all the inputs
    check_inputs DEFAULT_VALUES INPUTS

    log_verbose "Dump: $(declare -p INPUTS)"

    for data in "${!INPUTS[@]}"; do
        if [ $data == "PASSWORD" ]; then
            log_verbose "$data -> ${INPUTS[$data]}"
        else
            log_color "$data -> ${INPUTS[$data]}" "magenta"
        fi
    done

    confirmation=$(ask_yes_no "$(log_color "Do you want to apply this settings ?" "yellow")")
    if [ "$confirmation" == false ]; then
        log_color "Abort settings editing - no confirmation data" "red"
        exit 0
    fi

    # Write the settings
    write_settings_file $file "$(declare -p INPUTS)"

    # reload settings
    read_settings $file

    # show the new settings
    show_settings $file

    log_color "You can now restart the script" "yellow"
    exit 0
}

###
# Check data filled by user and process it by replacing by default value if conditions are not satisfied
# $1 : [Assoc-Array] default values set before
# $2 : [Assoc-Array] inputs values from user
# return [Assoc-Array] new inputs value
###
function check_inputs {
    declare -n DEFAULTS="$1" # Get Reference of variable DEFAULTS_VALUE before to not get a copie
    declare -n DATA=$2       # Get Reference of variable INPUTS before to not get a copie

    for key in "${!DATA[@]}"; do
        val=${DATA[$key]}
        count=${#val}
        case $key in
        "GIT_FOLDER" | "DOWNLOAD_PATH")
            min_char=1
            regex=""
            ;;
        "IP")
            min_char=1
            regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
            ;;
        "PORT")
            min_char=1
            regex="^[0-9]{0,5}$"
            ;;
        "PASSWORD")
            min_char=0
            regex=""
            ;;
        *)
            min_char=1 # Default character to check
            regex=""
            ;;
        esac

        # Do the check on char number
        # if no values
        if [ $count -eq 0 ]; then
            log_verbose "Setting default value for $key: ${DEFAULTS[$key]}"
            DATA+=([$key]=${DEFAULTS[$key]})
            continue
        # if less than expected
        elif [ $count -lt $min_char ]; then
            log_color "Incorrect value for $key you need $min_char characters at least. You have only $count ($val)" "red"
            log "Setting default value for $key: ${DEFAULTS[$key]}"
            DATA+=([$key]=${DEFAULTS[$key]})
            continue
        fi

        # Check Regex if exists for
        if
            [ ! -z "$regex" ] &
            [[ ! $val =~ $regex ]]
        then
            log_color "Regex not valid for $key (value: \"$val\")" "red"
            log "Setting default value for $(log_color "$key: ${DEFAULTS[$key]}" "yellow")"
            DATA+=([$key]=${DEFAULTS[$key]})
        fi
    done
}

###
# Write the file settings the settings in command line for the user, if the file exists we erased it
# $1: [string] path where the settings file is (default: "<script_location_path>/settings.conf")
# $2: [array] data to insert into the setting like (ip, user of else)
###
function write_settings_file {
    file=$1

    eval "declare -A DATA="${2#*=} # eval string into a new associative array

    # if file doesn't exist we create it
    if [ ! -f $file ]; then
        log_verbose "Creating $(log_color "$file" "yellow")"
        touch $file
        log_verbose "$(log_color "$file" "yellow") Created"
    else
        log_verbose "Resetting old settings in $(log_color "$file" "yellow")"
        >$file # Resetting file
        log_verbose "$(log_color "$file" "yellow") Reseted"
    fi

    echo "DAMAVAND_GIT_FOLDER=${DATA[GIT_FOLDER]}" >>$file
    echo "DAMAVAND_DOWNLOAD_PATH=${DATA[DOWNLOAD_PATH]}" >>$file
}

################################################################### Logging functions ###################################################################

###
# Return datetime of now (ex: 2022-01-10 23:20:35)
###
function get_datetime {
    log $(date '+%Y-%m-%d %H:%M:%S')
}

###
# Ask yes/no question for user and return boolean
# $1 : question to prompt for the user
###
function ask_yes_no {
    message=$1
    read -r -p "$message [y/N] : " ask
    if [ "$ask" == 'y' ] || [ "$ask" == 'Y' ]; then
        echo true
    else
        echo false
    fi
}

###
# Setup a read value for a user, and return it
# $1: [string] message prompt for the user
# $2: [string] type of data wanted (text, number, password)
# $3: [integer] number of character wanted at least
###
function read_data {
    message=$1
    type=$2
    min_char=$3

    if [ -z $min_char ]; then min_char=0; fi

    read_options=""
    case $type in
    "text")
        read_options="-r"
        ;;
    "number")
        read_options="-r"
        ;;
    "password")
        read_options="-rs"
        ;;
    *) ;;
    esac

    # read command value
    read $read_options -p "$message : " value

    echo $value
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
    log "Usage damavand [-v | --verbose] [--update] [--show-settings] [--setup-settings] [<args>] [OPTIONS...]..."
    log "Version $PROJECT_VERSION"
    log "Git command to clone in a specific folder"
    log
    log "Syntax: archange [-v|--no-details|--setup|--history]"
    log "Options:"
    log "\t --update \t\t Launch update script from github source"
    log "\t --show-settings \t Show settings of your project"
    log "\t --setup-settings \t Define settings of your project"
    log "\t -v, --verbose \t\t Show verbose logs"
}

main $@
