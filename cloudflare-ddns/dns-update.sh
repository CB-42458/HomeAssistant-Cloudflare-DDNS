#!/usr/bin/with-contenv bashio

ZONE_ID=$(bashio::config 'zone_id')
API_TOKEN=$(bashio::config 'api_token')
# DMAINS is a \n separated list of domains
DOMAINS=$(bashio::config 'domains')

message() {
    echo "[$(date)] $1"
}


get_public_ip() {
    # try this cloudflare
    if PUBLIC_IP=$(curl -s https://1.1.1.1/cdn-cgi/trace | grep -i 'ip' | awk -F= '{print $2}'); then
        return
    # try with ifconfig.me
    elif PUBLIC_IP=$(curl -s ifconfig.me); then
        return
    else
        message "ERROR - Unable to get public ip address with cloudflare or ifconfig.me."
        exit 1
    fi
}

get_dns_record() {
    local http_rc
    local curl_tmp
    local stderr_tmp
    local curl_err
    local host_msg
    unset identifier

    curl_tmp="get_dns_record.$$.tmp"
    stderr_tmp="get_dns_record_stderr.$$.tmp"

    http_rc=$(curl --silent --show-error --request GET \
        --url "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/?name=${1}" \
        --header "Authorization: Bearer ${API_TOKEN}" \
        --header "Content-Type: application/json" \
        --output "$curl_tmp" \
        --write-out "%{http_code}" \
        --stderr "$stderr_tmp")

    curl_err=$(<"$stderr_tmp")
    host_msg=$(head -n 1 "$curl_tmp")
    
    if (( http_rc == 200 )); then
        identifier=$(jq -r '.result[]?.id' "$curl_tmp")
        dns_record_ip=$(jq -r '.result[]?.content' "$curl_tmp")
        rm "$curl_tmp" "$stderr_tmp"
    else
        message "ERROR - ${1}: ${curl_err}  HTTP Code: ${http_rc}  Host Msg: ${host_msg}"
        rm "$curl_tmp" "$stderr_tmp"
        exit 1
    fi
}

update_dns_record() {
    local http_rc
    local curl_tmp
    local stderr_tmp
    local curl_err
    local host_msg
    unset patched_addr

    curl_tmp="update_dns_record.$$.tmp"
    stderr_tmp="update_dns_record_stderr.$$.tmp"

    http_rc=$(curl --silent --show-error --request PATCH \
        --url "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${identifier}" \
        --header "Authorization: Bearer ${API_TOKEN}" \
        --header "Content-Type: application/json" \
        --data '{
            "type":"A",
            "name":"'"${1}"'",
            "content":"'"${PUBLIC_IP}"'",
            "proxied":false
        }' \
        --output "$curl_tmp" \
        --write-out "%{http_code}" \
        --stderr "$stderr_tmp")

    curl_err=$(<"$stderr_tmp")
    host_msg=$(head -n 1 "$curl_tmp")
    
    if (( http_rc == 200 )); then
        message "Updated DNS record for ${1} to ${PUBLIC_IP}"
        rm "$curl_tmp" "$stderr_tmp"
    else
        message "ERROR - ${1}: ${curl_err}  HTTP Code: ${http_rc}  Host Msg: ${host_msg}"
        rm "$curl_tmp" "$stderr_tmp"
        exit 1
    fi
}

message "Starting DNS update script"
get_public_ip
message "Public IP: $PUBLIC_IP"
for domain in $DOMAINS; do
    message "Updating DNS record for $domain"
    get_dns_record $domain
    
    if [ "$PUBLIC_IP" != "$dns_record_ip" ]; then
        message "IP address changed from $dns_record_ip to $PUBLIC_IP"
        update_dns_record $domain
    else
        message "IP address is the same as the DNS record"
    fi
done