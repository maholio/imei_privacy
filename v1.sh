#!/bin/bash

echo "Choose an option: 1) Set auto-update of IMEI on boot 2) Change IMEI once 3) Remove automatic change of IMEI"
read -p "Enter your choice (1, 2, or 3): " user_choice

case $user_choice in
    1)
        echo "Setting auto-update script..."
        cat << EOF > /etc/init.d/auto_update_imei.sh
#!/bin/bash

luhn_checksum() {
    local num=\$1
    local sum=0
    local num_length=\${#num}
    for ((i=num_length-1;i>=0;i--)); do
        local digit=\${num:i:1}
        if ((i % 2 == 0)); then
            ((digit *= 2))
            if ((digit > 9)); then
                ((digit -= 9))
            fi
        fi
        ((sum += digit))
    done
    local check_digit=\$((10 - (sum % 10)))
    if ((check_digit == 10)); then
        check_digit=0
    fi
    printf "%d" "\$check_digit"
}

generate_valid_imei() {
    local prefix="\${imei_prefix[\$RANDOM % \${#imei_prefix[@]}]}"
    local suffix=\$(printf "%08d" \$((RANDOM % 10000000)))
    local full_imei="\${prefix}\${suffix}"
    local check_digit=\$(luhn_checksum "\${full_imei}")
    printf "%s%s" "\${full_imei}" "\$check_digit"
}

declare -a imei_prefix=("35674108" "35290611" "35397710" "35323210" "35384110"
                        "35982748" "35672011" "35759049" "35266891" "35407115"
                        "35538025" "35480910" "35324590" "35901183" "35139729"
                        "35479164")

SET_IMEI() {
    local imei="\$1"
    if [[ \${#imei} -eq 15 ]]; then
        gl_modem AT AT+EGMR=1,7,"\${imei}"
    fi
}

start() {
    local imei=\$(generate_valid_imei)
    SET_IMEI "\$imei"
}

stop() {
    :
}
EOF
        chmod +x /etc/init.d/auto_update_imei.sh
        /etc/init.d/auto_update_imei.sh enable
        ;;
    2)
        read -p "Change IMEI automatically or provide a custom one? (auto/custom): " imei_option
        case $imei_option in
            auto)
                imei=$(generate_valid_imei)
                echo "New IMEI: $imei"
                ;;
            custom)
                read -p "Are you sure you want to set a custom IMEI? (y/n): " confirm_custom
                if [[ "$confirm_custom" == "y" ]]; then
                    read -p "Enter your custom IMEI: " custom_imei
                    echo "New IMEI: $custom_imei"
                else
                    imei=$(generate_valid_imei)
                    echo "New IMEI: $imei"
                fi
                ;;
            *)
                echo "Invalid option."
                exit 1
                ;;
        esac
        ;;
    3)
        echo "Removing auto-update of IMEI..."
        rm /etc/init.d/auto_update_imei.sh
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

luhn_checksum() {
    local num=$1
    local sum=0
    local num_length=${#num}
    for ((i=num_length-1;i>=0;i--)); do
        local digit=${num:i:1}
        if ((i % 2 == 0)); then
            ((digit *= 2))
            if ((digit > 9)); then
                ((digit -= 9))
            fi
        fi
        ((sum += digit))
    done
    local check_digit=$((10 - (sum % 10)))
    if ((check_digit == 10)); then
        check_digit=0
    fi
    printf "%d" "$check_digit"
}

generate_valid_imei() {
    local prefix="${imei_prefix[$RANDOM % ${#imei_prefix[@]}]}"
    local suffix=$(printf "%08d" $((RANDOM % 10000000)))
    local full_imei="${prefix}${suffix}"
    local check_digit=$(luhn_checksum "${full_imei}")
    printf "%s%s" "${full_imei}" "${check_digit}"
}

declare -a imei_prefix=("35674108" "35290611" "35397710" "35323210" "35384110"
                        "35982748" "35672011" "35759049" "35266891" "35407115"
                        "35538025" "35480910" "35324590" "35901183" "35139729"
                        "35479164")
