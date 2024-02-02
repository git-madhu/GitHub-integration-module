#!/bin/bash
#################################################################################
#Author: Madhav
# Version: V1
#Date:01-02-2024
#Purpose : This script will help user to get / retrie information for GitHub
#Usage: run the script with 2 arguments .i.e., Github Token & rest api endpoints
#################################################################################

echo " Starting script"


echo "------------------------------------"
echo "------------------------------------"

if [[ ${#@} -lt 2 ]]; then 

	echo  "Please provide two argumnets as a script input"
        echo "usage: $0 [your github token] [REST expression]"
	exit 1
fi

#Setting varibles

GITHUB_TOKEN=$1
GITHUB_REST_API=$2

GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.v3+json"

temp=$(basename "$0")
TMPFILE=$(mktemp "/tmp/${temp}.XXXXXX") || exit 1

function rest_call {
curl -s "$1" -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: Bearer $GITHUB_TOKEN" >> $TMPFILE
}


# single page result-s (no pagination), have no Link: section, the grep result is empty

last_page=$(curl -s -I "https://api.github.com${GITHUB_REST_API}" -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: Bearer $GITHUB_TOKEN" | grep "^Link:" | sed -e 's/^Link:.*page=//g' -e 's/>.*$//g')

## last_page='curl -s -I "https://api.github.com${GITHUB_APT_REST}" -H "${GITHUB_API_HEADER_ACCEPT}"  -H "Authorization: Bearer $GITHUB_TOKEN" |'grep "^Link:" | sed -e 's/^Link:.*page=//g' -e 's/>.*$//g'


# does this result use pagination ?

if [ -z "$last_page" ]; then

	rest_call "https://api.github.com${GITHUB_REST_API}"
        #No - result is in 1 page

else 
        for p in seq 1 "$last_page" ; do


	rest_call "https://api.github.com${GITHUB_REST_API}?page=$p"
        #yes - result in multiple pages
done

fi

cat $TMPFILE
 	
