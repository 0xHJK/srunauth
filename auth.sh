#!/bin/bash
# Author HJK <https://github.com/0xHJK>

USERNAME=''
PASSWORD=''
DOMAIN='192.0.0.6'

usage(){
    echo "Usage: bash `basename $0` [-u username] [-p password] [Commond]"
    echo "Commonds: login, logout"
    exit 1
}

post_data(){
    msg=`curl -s "http://${DOMAIN}/cgi-bin/${1}" -H 'Pragma: no-cache' -H "Origin: http://${DOMAIN}" -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Win64; x64; Trident/6.0)' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H "Referer: http://${DOMAIN}/" -H 'Connection: keep-alive' -H 'DNT: 1' --data "username=${USERNAME}&password=${2}&drop=0&type=1&n=1" --compressed`
    if [[ `echo ${msg} | grep 'ip_exist_error'` ]]; then
        echo "IP尚未下线  ${msg}"
    elif [[ `echo ${msg} | grep 'online_num_error'` ]]; then
        echo "账号 ${USERNAME} 尚未下线  ${msg}"
    elif [[ `echo ${msg} | grep 'username_error'` ]]; then
        echo "用户名 ${USERNAME} 错误  ${msg}"
    elif [[ `echo ${msg} | grep 'password_error'` ]]; then
        echo "密码 ${PASSWORD} 错误  ${msg}"
    elif [[ `echo ${msg} | grep 'logout_ok'` ]]; then
        echo "账号 ${USERNAME} 注销成功  ${msg}"
    elif [[ `echo ${msg} | grep '[0-9]\{10,\}'` ]]; then
        echo "账号 ${USERNAME} 登录成功  ${msg}"
    else
        echo "未知消息 ${msg}"
    fi
    exit
}

log_in(){
    if [[ `uname | grep 'Darwin'` ]]; then
        PASS=`echo -n ${PASSWORD} | md5 -q | cut -c9-24`
    else
        PASS=`echo -n ${PASSWORD} | md5sum | cut -c9-24`
    fi
    post_data 'do_login' ${PASS}
}

log_out(){
    PASS=${PASSWORD}
    post_data 'force_logout' ${PASS}
}

if [ $# -eq 0 ]; then
    if [[ ${USERNAME} == '' ]] || [[ ${PASSWORD} == '' ]]; then
        usage
    else
        log_in
    fi
fi 

while getopts u:p: OPTION
do
    case $OPTION in
        u)
            USERNAME=$OPTARG
            ;;
        p)
            PASSWORD=$OPTARG
            ;;
        \?)
            usage
            ;;
    esac
done

shift $(($OPTIND - 1))

if [ $# -eq 0 ] || [[ $1 == 'login' ]]; then
    log_in
elif [[ $1 == 'logout' ]]; then
    log_out
else
    usage
fi
