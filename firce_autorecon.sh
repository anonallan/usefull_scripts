#!/bin/bash
# INSTANT_FEEDBACK.sh - Tiny wordlist = hits in 30 seconds
TARGET=${1:?Domain?}
WORDLIST=${2:-/usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt}  # 200 entries = 20sec
DNS_SERVER=${3:-8.8.8.8}

echo "[+] FAST TEST: $TARGET (200 subs in ~20sec)"

# IMMEDIATE screen output - no spinner, no timeout
fierce --domain "$TARGET" --subdomain-file "$WORDLIST" --dns-servers "$DNS_SERVER"

echo -e "\n[+] DONE - Results above ^"

