#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

#Add some basic function here
function LOGD() {
    echo -e "${yellow}[DEG] $* ${plain}"
}

function LOGE() {
    echo -e "${red}[ERR] $* ${plain}"
}

function LOGI() {
    echo -e "${green}[INF] $* ${plain}"
}

cd ~
uname_output=$(uname -a)
enable_str="nohup \.\/x-ui run"

# check os
if echo "$uname_output" | grep -Eqi "freebsd"; then
    release="freebsd"
else
    echo -e "${red}System version not detected, please contact the script author! ${plain}\n" && exit 1
fi

arch="none"

if echo "$uname_output" | grep -Eqi 'x86_64|amd64|x64'; then
    arch="amd64"
elif echo "$uname_output" | grep -Eqi 'aarch64|arm64'; then
    arch="arm64"
else
    arch="amd64"
    echo -e "${red}检Detection schema failed，Use default schema: ${arch}${plain}"
fi

echo "Architecture: ${arch}"

confirm() {
    if [[ $# > 1 ]]; then
        echo && read -p "$1 [default$2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}

confirm_restart() {
    confirm "Whether to restart the panel，Restarting the panel will also restart xray" "y"
    if [[ $? == 0 ]]; then
        restart
    else
        show_menu
    fi
}

before_show_menu() {
    echo && echo -n -e "${yellow}Press Enter to return to the main menu: ${plain}" && read temp
    show_menu
}

update() {
    confirm "This function will force reinstall the latest version，The data will not be lost. Do you want to continue?" "n"
    if [[ $? != 0 ]]; then
        LOGE "Canceled"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi
    cd ~
    wget -N --no-check-certificate -O x-ui-install.sh https://raw.githubusercontent.com/ehsanasekhi/am-serv00-x-ui/main/install.sh
    chmod +x x-ui-install.sh
    ./x-ui-install.sh
    if [[ $? == 0 ]]; then
        LOGI "Update completed，Panel has been automatically restarted "
        exit 0
    fi
}

stop_x-ui() {
    # Set the command name of the nohup process you want to kill
    xui_com="./x-ui run"
    xray_com="bin/xray-$release-$arch -c bin/config.json"
 
    # Use pgrep to find process ID
    PID=$(pgrep -f "$xray_com")
 
    # Check if the process is found
    if [ ! -z "$PID" ]; then
        # Found the process, kill it
        kill $PID
    
        # Optional: Check if the process has been killed
        if kill -0 $PID > /dev/null 2>&1; then
            kill -9 $PID
        fi
    fi
        # Use pgrep to find process ID
    PID=$(pgrep -f "$xui_com")
 
    # Check if the process is found
    if [ ! -z "$PID" ]; then
        # Found the process, kill it
        kill $PID
    
        # Optional: Check if the process has been killed
        if kill -0 $PID > /dev/null 2>&1; then
            kill -9 $PID
        fi
    fi

}

install() {
    cd ~
    wget -N --no-check-certificate -O x-ui-install.sh https://raw.githubusercontent.com/ehsanasekhi/am-serv00-x-ui/main/install.sh
    chmod +x x-ui-install.sh
    ./x-ui-install.sh
    if [[ $? == 0 ]]; then
        if [[ $# == 0 ]]; then
            start
        else
            start 0
        fi
    fi
}

uninstall() {
    confirm "Are you sure you want to uninstall the panel? Xray will also be uninstalled?" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    stop_x-ui
    crontab -l > x-ui.cron
    sed -i "" "/x-ui.log/d" x-ui.cron
    crontab x-ui.cron
    rm x-ui.cron
    cd ~
    rm -rf ~/x-ui/

    echo ""
    echo -e "The uninstallation is successful. If you want to delete this script, exit the script and run ${green}rm ~/x-ui.sh -f${plain} Delete"
    echo ""

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

reset_user() {
    confirm "Are you sure you want to reset your username and password to admin ?" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    ~/x-ui/x-ui setting -username admin -password admin
    echo -e "Username and password have been reset to ${green}admin${plain}，Please restart the panel now"
    confirm_restart
}

reset_config() {
    confirm "Are you sure you want to reset all panel settings? Account data will not be lost and username and password will not be changed." "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    ~/x-ui/x-ui setting -reset
    echo -e "All panel settings have been reset to default values. Now please restart the panel and use the default ${green}54321${plain} Port access panel"
    confirm_restart
}

check_config() {
    info=$(~/x-ui/x-ui setting -show true)
    if [[ $? != 0 ]]; then
        LOGE "get current settings error,please check logs"
        show_menu
    fi
    LOGI "${info}"
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

set_port() {
    echo && echo -n -e "Enter port number[1-65535]: " && read port
    if [[ -z "${port}" ]]; then
        LOGD "Canceled"
        before_show_menu
    else
        ~/x-ui/x-ui setting -port ${port}
        echo -e "The panel access port is set. Now please restart the panel and use the newly set port. ${green}${port}${plain} Access panel"
        confirm_restart
    fi
}

set_traffic_port() {
    echo && echo -n -e "Enter the traffic monitoring port number[1-65535]: " && read trafficport
    if [[ -z "${trafficport}" ]]; then
        LOGD "Canceled"
        before_show_menu
    else
        ~/x-ui/x-ui setting -trafficport ${trafficport}
        echo -e "The traffic monitoring port is set. Now please restart the panel and use the newly set port. ${green}${trafficport}${plain} Access panel"
        confirm_restart
    fi
}


start() {
    check_status
    if [[ $? == 0 ]]; then
        echo ""
        LOGI "The panel is already running and does not need to be started again. If you need to restart, please select Restart."
    else
        cd ~/x-ui
        nohup ./x-ui run > ./x-ui.log 2>&1 &
        sleep 2
        check_status
        if [[ $? == 0 ]]; then
            LOGI "x-ui started successfully"
        else
            LOGE "The panel failed to start. It may be because the startup time exceeded two seconds. Please check the log information later."
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

stop() {
    check_status
    if [[ $? == 1 ]]; then
        echo ""
        LOGI "The panel has been stopped and does not need to be stopped again"
    else
        stop_x-ui
        sleep 2
        check_status
        if [[ $? == 1 ]]; then
            LOGI "x-ui and xray stopped successfully"
        else
            LOGE "The panel failed to stop, possibly because the stop time exceeded two seconds. Please check the log information later."
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

restart() {
    stop 0
    start 0
    sleep 2
    check_status
    if [[ $? == 0 ]]; then
        LOGI "x-ui and xray restarted successfully"
    else
        LOGE "The panel failed to restart, possibly because the startup time exceeded two seconds. Please check the log information later."
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

status() {
    COMMAND_NAME="./x-ui run"
    PID=$(pgrep -f "$COMMAND_NAME")
 
    # Check if the process is found
    if [ ! -z "$PID" ]; then
        LOGI "x-ui is running"
    else
        LOGI "x-ui is not running"
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

enable() {
    crontab -l > x-ui.cron
    sed -i "" "/$enable_str/d" x-ui.cron
    echo "@reboot cd $cur_dir/x-ui && nohup ./x-ui run > ./x-ui.log 2>&1 &" >> x-ui.cron
    crontab x-ui.cron
    rm x-ui.cron
    if [[ $? == 0 ]]; then
        LOGI "x-ui settings start automatically at boot successfully"
    else
        LOGE "x-ui failed to set up auto-start at boot"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

disable() {
    crontab -l > x-ui.cron
    sed -i "" "/$enable_str/d" x-ui.cron
    crontab x-ui.cron
    rm x-ui.cron
    if [[ $? == 0 ]]; then
        LOGI "x-ui cancels boot and auto-start successfully"
    else
        LOGE "x-ui failed to cancel boot auto-start"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

update_shell() {
    wget -O ~/x-ui.sh -N --no-check-certificate https://raw.githubusercontent.com/ehsanasekhi/am-serv00-x-ui/main/x-ui.sh
    if [[ $? != 0 ]]; then
        echo ""
        LOGE "Failed to download the script, please check whether the machine can connect to Github"
        before_show_menu
    else
        chmod +x ~/x-ui
        LOGI "The upgrade script is successful, please re-run the script." && exit 0
    fi
}

# 0: running, 1: not running, 2: not installed
check_status() {
    if [[ ! -f ~/x-ui/x-ui ]]; then
        return 2
    fi
    COMMAND_NAME="./x-ui run"
    PID=$(pgrep -f "$COMMAND_NAME")
 
    # Check if the process is found
    if [ ! -z "$PID" ]; then
        return 0
    else
        return 1
    fi
}

check_enabled() {
    cron_str=$(crontab -l)
 
    # Check the exit status code of grep
    if echo "$cron_str" | grep -Eqi "$enable_str"; then
        return 0
    else
        return 1
    fi
}

check_uninstall() {
    check_status
    if [[ $? != 2 ]]; then
        echo ""
        LOGE "The panel has been installed, please do not install it again"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

check_install() {
    check_status
    if [[ $? == 2 ]]; then
        echo ""
        LOGE "Please install the panel first"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

show_status() {
    check_status
    case $? in
    0)
        echo -e "Panel status: ${green}Running${plain}"
        show_enable_status
        ;;
    1)
        echo -e "Panel status: ${yellow}Not running${plain}"
        show_enable_status
        ;;
    2)
        echo -e "Panel status: ${red}Not installed${plain}"
        ;;
    esac
    show_xray_status
}

show_enable_status() {
    check_enabled
    if [[ $? == 0 ]]; then
        echo -e "Whether to start automatically after power on: ${green}yes${plain}"
    else
        echo -e "Whether to start automatically after power on: ${red}no${plain}"
    fi
}

check_xray_status() {
    count=$(ps -aux | grep "xray-${release}" | grep -v "grep" | wc -l)
    if [[ count -ne 0 ]]; then
        return 0
    else
        return 1
    fi
}

show_xray_status() {
    check_xray_status
    if [[ $? == 0 ]]; then
        echo -e "xray State: ${green}run${plain}"
    else
        echo -e "xray State: ${red}Not running${plain}"
    fi
}

show_usage() {
    echo "How to use x-ui management script: "
    echo "------------------------------------------"
    echo "/home/${USER}/x-ui.sh              - Show management menu (more functions)"
    echo "/home/${USER}/x-ui.sh start        - Start x-ui panel"
    echo "/home/${USER}/x-ui.sh stop         - Stop x-ui panel"
    echo "/home/${USER}/x-ui.sh restart      - Restart the x-ui panel"
    echo "/home/${USER}/x-ui.sh status       - View x-ui status"
    echo "/home/${USER}/x-ui.sh enable       - enable x-ui"
    echo "/home/${USER}/x-ui.sh disable      - Disable x-ui startup"
    echo "/home/${USER}/x-ui.sh update       - Update x-ui panel"
    echo "/home/${USER}/x-ui.sh install      - Installing the x-ui panel"
    echo "/home/${USER}/x-ui.sh uninstall    - Uninstall x-ui panel"
    echo "------------------------------------------"
}

show_menu() {
    echo -e "
  ${green}X-UI Panel managment${plain}
  ${green}0.${plain} Exit script
————————————————
  ${green}1.${plain} Install x-ui
  ${green}2.${plain} Update x-ui
  ${green}3.${plain} Uninstall x-ui
————————————————
  ${green}4.${plain} Reset username and password
  ${green}5.${plain} Reset panel settings
  ${green}6.${plain} Settings panel access port
  ${green}7.${plain} View current panel settings
————————————————
  ${green}8.${plain} Start x-ui
  ${green}9.${plain} Stop x-ui
  ${green}10.${plain} Restart x-ui
  ${green}11.${plain} Check x-ui status
  ${green}12.${plain} Set the traffic monitoring port
————————————————
  ${green}13.${plain} Set x-ui to boot automatically
  ${green}14.${plain} Cancel x-ui boot auto-start
————————————————
 "
    show_status
    echo && read -p "Please enter your choice [0-14]: " num

    case "${num}" in
    0)
        exit 0
        ;;
    1)
        check_uninstall && install
        ;;
    2)
        check_install && update
        ;;
    3)
        check_install && uninstall
        ;;
    4)
        check_install && reset_user
        ;;
    5)
        check_install && reset_config
        ;;
    6)
        check_install && set_port
        ;;
    7)
        check_install && check_config
        ;;
    8)
        check_install && start
        ;;
    9)
        check_install && stop
        ;;
    10)
        check_install && restart
        ;;
    11)
        check_install && status
        ;;
    12)
        check_install && set_traffic_port
        ;;
    13)
        check_install && enable
        ;;
    14)
        check_install && disable
        ;;
    *)
        LOGE "Please enter a valid number [0-14]"
        ;;
    esac
}

if [[ $# > 0 ]]; then
    case $1 in
    "start")
        check_install 0 && start 0
        ;;
    "stop")
        check_install 0 && stop 0
        ;;
    "restart")
        check_install 0 && restart 0
        ;;
    "status")
        check_install 0 && status 0
        ;;
    "enable")
        check_install 0 && enable 0
        ;;
    "disable")
        check_install 0 && disable 0
        ;;
    "update")
        check_install 0 && update 0
        ;;
    "install")
        check_uninstall 0 && install 0
        ;;
    "uninstall")
        check_install 0 && uninstall 0
        ;;
    *) show_usage ;;
    esac
else
    show_menu
fi
