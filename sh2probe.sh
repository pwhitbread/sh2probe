#!/bin/bash

# sh2probe
# version 1.0

# A bash script to query a BT Smart Hub 2 from the command line
# The data fetched is returned as javascript.
# This script does not do the parsing of the results.

# Router IP address (no trailing slash)
URL="http://192.168.0.1"

# pws is hash of password. I haven't replicated hashing function, so use web browser to get a copy as it doesn't change
#  1. Open Dev Tools - Network
#  2. Trigger login
#  3. Look for login.cgi, review Request and copy pws value

PWS="<insert hash here>"

# Pages to query depending on the required data (other pages may exist):
# cgi_basicBrightness
# cgi_basicMobile
# cgi_basicMyDevice
# cgi_basicStatus
# cgi_basicwifi
# cgi_broadband
# cgi_btAccessControl
# cg_firewall
# cgi_IPv6
# cgi_helpdesk
# cgi_home
# cgi_myNetwork
# cgi_owl
# cgi_system
# cgi_wifi

TARGET="cgi_IPv6"


# Permission to use, copy, modify, and/or distribute this software for
# any purpose with or without fee is hereby granted.

# THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE
# FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
# DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
# AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
# OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.



# Request a session-cookie, and save
curl ${URL} \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:106.0) Gecko/20100101 Firefox/106.0' \
    -H 'Accept: */*' \
    -H 'Accept-Language: en-GB,en;q=0.5' \
    -H 'Accept-Encoding: gzip, deflate' \
    -H 'Content-Type: text/plain;charset=UTF-8' \
    --cookie-jar /tmp/$$.jar | wc  -l
    
URN=$(tail -1  /tmp/$$.jar | awk '{print $7}')
rm /tmp/$$.jar
echo urn cookie: ${URN}

# Call the login script
echo "[Login] (no response expected)"
curl "${URL}/login.cgi" \
    -X POST -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/110.0' \
    -H 'Accept: */*' \
    -H 'Accept-Language: en-GB,en;q=0.5' \
    -H 'Accept-Encoding: gzip, deflate' \
    -H 'Content-Type: text/plain;charset=UTF-8' \
    -H 'Origin: http://192.168.0.1' \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H "Referer: ${URL}" \
    -H "Cookie: urn=${URN}; logout=not" \
    --data-raw "GO=IPv6.htm&usr=admin&pws=${PWS}"
echo "[end Login]"

# Calculate the epoch time that has to be provided for the router to respond
tMagic=$(date +%s%3N)
echo ${tMagic}

FETCHED_JS=$(curl "${URL}/cgi/${TARGET}.js?t=${tMagic}" \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/110.0' \
    -H 'Accept: */*' \
    -H 'Accept-Language: en-GB,en;q=0.5' \
    -H 'Accept-Encoding: gzip, deflate' \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H "Referer: ${URL}/.htm" \
    -H "Cookie: urn=${URN}; logout=not")

echo "$FETCHED_JS"
exit    



