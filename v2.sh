#!/bin/sh /etc/rc.common

START=99
STOP=99

luhn_checksum() {
    local num=0
    local nDigits=${#1}
    local odd=$((nDigits % 2))

    for ((i=nDigits-1; i>=0; i--)); do
        local digit=${1:$i:1}
        if ((i % 2 == odd)); then
            ((digit *= 2))
            if ((digit > 9)); then
                ((digit -= 9))
            fi
        fi
        ((num += digit))
    done
    echo "$num"
}

luhn_digit() {
    local num=$(luhn_checksum "$1")
    echo $((10 - (num % 10)))
}

is_valid_luhn() {
    local num=$(luhn_checksum "$1")
    ((num % 10 == 0))
}

generate_valid_imei() {
    local prefix="${imei_prefix[$RANDOM % ${#imei_prefix[@]}]}"
    local suffix=""
    for ((i=0; i<6; i++)); do
        suffix="${suffix}${RANDOM: -1}"
    done
    local full_imei="${prefix}${suffix}"
    local check_digit=$(luhn_digit "${full_imei}")
    echo "${full_imei}${check_digit}"
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
