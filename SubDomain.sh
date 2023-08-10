#!/bin/bash

if [[ $1 == "-h" ]] || [[ $1 == "" ]]; then
    echo "./SubDomain.sh domain output_file"
    exit
fi


domain=$1
outfile=$2
echo "[+]Starting passive sub-domain enum for $1, result will save to $2"


function data_crtsh {
    data=$(curl -s "https://crt.sh/?q=$domain&output=json" | jq -r ".[].common_name" | sort -u)
    echo $data | tr ' ' '\n' >> $outfile
}

function data_dnsdumper {
    grep_csrf_cookie=$(curl "https://dnsdumpster.com" -c - 2>/dev/null| grep csrf)
    post_csrf=$(echo $grep_csrf_cookie | grep csrf | sed 's/.*value="\(.*\)">/\1/' | awk '{print $1}' | head -n 1 )
    cookie_csrf=$(echo $grep_csrf_cookie | grep csrf | sed 's/.*value="\(.*\)">/\1/' | awk '{print $8}' )

    response=$(curl "https://dnsdumpster.com" -H "Content-Type: application/x-www-form-urlencoded" -H "Referer: https://dnsdumpster.com/" -b "csrftoken=$cookie_csrf" --data "csrfmiddlewaretoken=$post_csrf&targetip=$domain&user=free" 2>/dev/null)

    grep_resp=$(echo $response | grep -oE "[a-zA-z0-9\-]*\.$domain" | sort -u)
    echo $grep_resp | tr ' ' '\n' >> $outfile


}

function remove_collision {
    $(sort -u -o $outfile $outfile)
}

data_crtsh
data_dnsdumper

remove_collision

: << "TODO"
+ crt.sh
+ dnsdumpster.com


TODO
