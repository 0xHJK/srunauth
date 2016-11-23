#!/bin/bash
# Author HJK <https://github.com/0xHJK>

USERNAME=''
PASSWORD=''
USERSFILE='users.txt'
STATEFILE='state.txt'
DOMAIN='192.0.0.6'
COMMOND='do_login'
VERBOSE='y'

usage(){
    echo "Usage: bash `basename $0` [-q] [-u username] [-p password] [-f file] [Commond]"
    echo "Commonds: login, logout"
    exit 1
}
md5_hash(){
    if [[ `uname | grep 'Darwin'` ]]; then
        echo -n ${1} | md5 -q | cut -c9-24
    else
        echo -n ${1} | md5sum | cut -c9-24
    fi
}

say_out(){
    if [[ ${VERBOSE} == 'y' ]]; then echo $*; fi
}

submit(){
    msg=`curl -s "http://${DOMAIN}/cgi-bin/${1}" -H 'Pragma: no-cache' -H "Origin: http://${DOMAIN}" -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Win64; x64; Trident/6.0)' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H "Referer: http://${DOMAIN}/" -H 'Connection: keep-alive' -H 'DNT: 1' --data "username=${2}&password=${3}&drop=0&type=1&n=1" --compressed`
    if [[ `echo ${msg} | grep 'ip_exist_error'` ]]; then
        echo "IP尚未下线  ${msg}"
    elif [[ `echo ${msg} | grep 'online_num_error'` ]]; then
        echo "账号 ${USERNAME} 登录人数超过限额 ${msg}"
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
}

# 当有参数时获取参数
if [ $# -gt 0 ]; then
    while getopts :qu:p:f: OPTION
    do
        case $OPTION in
            q) VERBOSE='n' ;;
            u) USERNAME=$OPTARG ;;
            p) PASSWORD=$OPTARG ;;
            f) USERSFILE=$OPTARG ;;
            \?) usage ;;
        esac
    done
fi

shift $(($OPTIND - 1))

# 如果登录
if [ $# -eq 0 ] || [[ $1 == 'login' ]]; then
    # 如果账号密码为空，则从文件里读取
    if [[ ${USERNAME} == '' ]] || [[ ${PASSWORD} == '' ]]; then
        cat -s ${USERSFILE} | while read l1; do
            USERNAME=`echo -n $l1 | awk '{ print $1 }'`
            PASSWORD=`echo -n $l1 | awk '{ print $2 }'`
            say_out "正在尝试登录 ${USERNAME} ${PASSWORD}"
            PASSWORD=`md5_hash ${PASSWORD}`
            # 如果登录成功，则退出循环，并记录账号密码
            state=`submit 'do_login' ${USERNAME} ${PASSWORD}`
            say_out "${state}"
            if [[ `echo "${state}" | grep '成功'` ]]; then
                echo "${state}"
                echo "${USERNAME} ${PASSWORD}" > ${STATEFILE}
                exit
            fi
        done
        echo "所有账号登录失败"
    else
        say_out "正在尝试登录 ${USERNAME} ${PASSWORD}"
        PASSWORD=`md5_hash ${PASSWORD}`
        submit 'do_login' ${USERNAME} ${PASSWORD}
    fi
# 如果注销
elif [[ $1 == 'logout' ]]; then
    # 如果账号密码为空，则从文件里读取
    if [[ ${USERNAME} == '' ]] || [[ ${PASSWORD} == '' ]]; then
        USERNAME=`cat ${STATEFILE} | awk '{ print $1 }'`
        PASSWORD=`cat ${STATEFILE} | awk '{ print $2 }'`
        say_out "正在尝试注销 ${USERNAME} ${PASSWORD}"
    fi
    submit 'force_logout' ${USERNAME} ${PASSWORD}
else
    usage
fi
