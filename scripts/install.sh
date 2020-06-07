#!/bin/bash
SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
STARTPWD=$PWD

# Define colors and styles
NORMAL="\033[0m"
BOLD="\033[1m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[93m"

show_msg() {
    echo -e $1 > /dev/tty
}

usage() {
    echo -e "${BOLD}Usage:${NORMAL}"
    echo -e "  -i  --install-dir        Specify where you want to install to"
    echo -e "                           Default is: ${BOLD}${SCRIPTPATH}${NORMAL}"
    echo -e "  -k  --api-key            Specify the assigned api key for the busy server api."
    echo -e "  -u  --url                Specify the busy server url."
    echo -e "  -d  --development        Install for development only (no service installation)"
    echo -e "  -V  --verbose            Shows command output for debugging"
    echo -e "  -v  --version            Shows version details"
    echo -e "  -h  --help               Shows this usage message"
}

version() {
    echo -e "${BOLD}BusyLight install script 0.1${NORMAL}"    
}

installSystemdService() {
    show_msg "${GREEN}Installing Systemd Service...${NORMAL}"
    sed -i "s+WorkingDirectory=/home/busybody/busylight+WorkingDirectory=$INSTALL_DIR+g" $INSTALL_DIR/busylight.service
    if [[ ! -f /etc/systemd/system/busylight.service ]]; then
        sudo cp busylight.service /etc/systemd/system/busylight.service
    else
        sudo sed -i "s+WorkingDirectory=/home/busybody/busylight+WorkingDirectory=$INSTALL_DIR+g" /etc/systemd/system/busylight.service
    fi
}

enableSystemdService() {
    show_msg "${GREEN}Starting Systemd Service...${NORMAL}"
    sudo systemctl enable busylight.service
    sudo systemctl start busylight.service
}

setApiKey(){
    show_msg "${GREEN}Setting the API Key to $API_KEY...${NORMAL}"
    sed -i "s+apiKey = ''+apiKey = '$API_KEY'+g" $INSTALL_DIR/busylight.py
}

setServerUrl(){
    show_msg "${GREEN}Setting the URL to $URL...${NORMAL}"
    sed -i "s+serverUrl = ''+serverUrl = '$URL'+g" $INSTALL_DIR/busylight.py
}

VERBOSE=false
DEVELOPMENT=false
INSTALL_DIR=$SCRIPTPATH
API_KEY=$(cat /proc/sys/kernel/random/uuid)
URL=""
while [ "$1" != "" ]; do
    case $1 in
        -i | --install-dir)     shift
                                INSTALL_DIR=$1
                                ;;
        -u | --url)             shift
                                URL=$1
                                ;;                           
        -k | --api-key)         shift
                                API_KEY=$1
                                ;;                         
        -d | --development)     DEVELOPMENT=true
                                ;;
        -V | --verbose)         VERBOSE=true
                                ;;
        -v | --version)         version
                                exit 0
                                ;;
        -h | --help)            version
                                echo -e ""
                                usage
                                exit 0
                                ;;
        * )                     echo -e "Unknown option $1...\n"
                                usage
                                exit 1
    esac
    shift
done

if [ $VERBOSE == "false" ]; then
    exec > /dev/null 
fi

if [ $API_KEY == "" ]; then
    show_msg "${RED}The API Key (-k) must be specified...${NORMAL}"
    usage
    exit 1
fi
 
if [ $URL == "" ]; then
    show_msg "${RED}The url for the busy server (-u) must be specified...${NORMAL}"
    usage
    exit 1
fi

# Check if we have the required files or if we need to clone them
FILES=("requirements.txt" "busylight.service" "busylight.py")
FILECHECK=true
for FILE in ${FILES[@]}; do
    if [ $INSTALL_DIR != $SCRIPTPATH ]; then
        if [ $VERBOSE == "true" ]; then
            show_msg "Checking file... ${INSTALL_DIR}/${FILE}"
        fi
        if [ ! -f "${INSTALL_DIR}/${FILE}" ]; then
            FILECHECK=false
        fi
    else
        if [ $VERBOSE == "true" ]; then
            show_msg "Checking file... ${INSTALL_DIR}/${FILE}"
        fi
        if [ ! -f "${SCRIPTPATH}/${FILE}" ]; then
            FILECHECK=false
        fi
    fi
    if [ $FILECHECK == 'false' ]; then
        show_msg "${RED}The requried files are missing...${NORMAL} lets clone everything from git..."
        break
    fi
done

if [ $FILECHECK == 'false' ]; then
    if [ "$(ls -A ${INSTALL_DIR})" ]; then
        INSTALL_DIR="$INSTALL_DIR/busylight"
    fi
    show_msg "${GREEN}Downloading files from git using HTTPS to ${BOLD}${INSTALL_DIR}${NORMAL}${GREEN}...${NORMAL}"
    #download script
    curl https://raw.githubusercontent.com/wisejeff/busylight/master/scripts/busylight.py -o $INSTALL_DIR/busylight.py

    #download service 
    curl https://raw.githubusercontent.com/wisejeff/busylight/master/scripts/busylight.service -o $INSTALL_DIR/busylight.service

    #download requirements 
    curl https://raw.githubusercontent.com/wisejeff/busylight/master/scripts/requirements.txt -o $INSTALL_DIR/busylight.service

    chown -R $SUDO_USER:$SUDO_USER $INSTALL_DIR
    cd $INSTALL_DIR
fi

setServerUrl
setApiKey

case $(uname -s) in
    Linux|GNU*)     case $(lsb_release -si) in
                        Ubuntu | Raspbian)      show_msg "${GREEN}Installing required files from apt...${NORMAL}"
                                                sudo apt-get install -y python3-pip python3-dev
                                                if [[ $DEVELOPMENT == "false" ]]; then
                                                    installSystemdService
                                                    enableSystemdService
                                                fi
                                                ;;
                        *)                      show_msg "${RED}${BOLD}Unsupported distribution, please consider submitting a pull request to extend the script${NORMAL}"
                                                exit 1
                    esac
                    show_msg "${GREEN}Installing needed files from pip...${NORMAL}"
                    sudo pip3 install -r ./requirements.txt
                    ;;
    *)              show_msg "${RED}${BOLD}Unsupported operating system, please consider submitting a pull request to extend the script${NORMAL}"
                    exit 1
esac

cd $STARTPWD
show_msg "${GREEN}${BOLD}Installation complete${NORMAL}"
