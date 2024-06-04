#!/bin/sh /etc/rc.common
START=99
STOP=99

generate_valid_imei() {
    local prefix="${imei_prefix[$RANDOM % ${#imei_prefix[@]}]}"
    local suffix=$((RANDOM % 10000000))
    local full_imei="${prefix}${suffix}"
    local check_digit=$(luhn_checkdigit "${full_imei}")
    echo "${full_imei}${check_digit}"
}

luhn_checkdigit() {
    local num=$1
    local sum=0
    local num_length=${#num}
    for ((i=num_length-1;i>=0;i-=2)); do
        let "sum+=${num:$i:1}"
    done
    for ((i=num_length-2;i>=0;i-=2)); do
        let "temp=${num:$i:1}*2"
        if ((temp>9)); then
            let "sum+=(temp%10)+(temp/10)"
        else
            let "sum+=temp"
        fi
    done
    let "check_digit=(10-(sum%10))%10"
    echo "${check_digit}"
}

SET_IMEI() {
    local imei="$1"
    if [[ ${#imei} -eq 15 ]]; then
        gl_modem AT AT+EGMR=1,7,"${imei}"
    else
        echo "Invalid IMEI length."
    fi
}

declare -a imei_prefix=("35674108" "35290611" "35397710" "35323210" "35384110"
                        "35982748" "35672011" "35759049" "35266891" "35407115"
                        "35538025" "35480910" "35324590" "35901183" "35139729"
                        "35479164")

start() {
    local imei=$(generate_valid_imei)
    SET_IMEI "$imei"
}

stop() {
    :
}
