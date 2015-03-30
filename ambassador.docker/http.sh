#!/bin/sh
# Author: jonathan lung <auto+vapr@heresjono.com>
# An implementation of some basic http functionality. Depends on sh and socat.
# Meant to be used in a busybox Docker image with socat.

dig() {
    # Usage:
    #     dig address
    nslookup $1 | tail -n +5 | cut -d" " -f 3
}

server_name() {
    # Usage:
    #     server_name server:port
    # Returns the server portion.
    echo "$1" | cut -d ":" -f 1
}

port_number() {
    # Usage:
    #     port_number server:port
    # Returns the port portion.
    echo "$1" | cut -d ":" -f 2
}

http() {
    # Usage:
    #     http server[:port] VERB URL [content]
    # Returns the entire response from an HTTP request. Defaults to port 80.
    http_CONN=$(dig $(server_name $1:80) | head -n 1):$(port_number $1:80)
    if [[ "$4" == "" ]]; then
        (echo -e "$2 $3 HTTP/1.1\nHost: $(server_name $1)\n"; sleep ${HTTP_LATENCY:=0}) | socat TCP:${http_CONN} -
    else
        (echo -e "$2 $3 HTTP/1.1\nHost: $(server_name $1)\nContent-Length: ${#4}\nContent-Type: application/x-www-form-urlencoded\n\n$4"; sleep ${HTTP_LATENCY:=0}) | socat TCP:${http_CONN} -
    fi
}

http_content() {
    # Usage:
    #     http_content server:port VERB URL [content]
    # Returns the content from an HTTP request.
    http_RETRY=${RETRY:=3}
    http_CONTENT=""
    until [[ ${http_RETRY} -eq 0 || "${http_CONTENT}" != "" ]]; do
        http_CONTENT=$(http $* | awk 'BEGIN {CONTENT=0} {if (CONTENT == 1) { print $0 }; if ( $0 ~ /^\s+$/) { CONTENT=1 } }')
        let http_RETRY-=1
    done
    echo "${http_CONTENT}"
}

https() {
    # Usage:
    #     https server[:port] VERB URL [content]
    # Returns the entire response from an HTTPS request. Defaults to port 443.
    # N.B.: Certificate checking does NOT take place. This is INSECURE.

    https_CONN=$(dig $(server_name $1:443) | head -n 1):$(port_number $1:443)
    if [[ "$4" == "" ]]; then
        (echo -e "$2 $3 HTTP/1.1\nHost: $(server_name $1)\n"; sleep ${HTTP_LATENCY:=0}) | socat openssl:${https_CONN},verify=0 -
    else
        (echo -e "$2 $3 HTTP/1.1\nHost: $(server_name $1)\nContent-Length: ${#4}\nContent-Type: application/x-www-form-urlencoded\n\n$4"; sleep ${HTTP_LATENCY:=0}) | socat openssl:${https_CONN},verify=0 -
    fi
}

https_content() {
    # Usage:
    #     https_content server[:port] VERB URL [content]
    # Returns the content from an HTTPS request.
    # N.B.: Certificate checking does NOT take place. This is INSECURE.
    https_RETRY=${RETRY:=3}
    https_CONTENT=""
    until [[ ${https_RETRY} -eq 0 || "${https_CONTENT}" != "" ]]; do
        https_CONTENT=$(https $* | awk 'BEGIN {CONTENT=0} {if (CONTENT == 1) { print $0 }; if ( $0 ~ /^\s+$/) { CONTENT=1 } }')
        let https_RETRY-=1
    done
    echo "${https_CONTENT}"
}