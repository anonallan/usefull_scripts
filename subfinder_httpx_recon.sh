#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

DOMAIN=$1
DOMAINS_FILE="${DOMAIN}.txt"
HTTPX_FILE="httpx.${DOMAIN}.txt"
PORTS_FILE="ports.${DOMAIN}.json"
LIVE_FILE="live_${DOMAIN}.txt"
LOG_FILE="recon_${DOMAIN}_$(date +%Y%m%d_%H%M%S).log"
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; NC='\033[0m'

# Logging function
log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

clear
echo -e "${YELLOW}🚀 ULTRA-VERBOSE GOD-TIER RECON STARTING${NC}"
echo -e "${CYAN}Target: ${GREEN}$DOMAIN${NC} | Log: ${BLUE}$LOG_FILE${NC}"
log "=== RECON SESSION STARTED ==="

# 1. SUBFINDER - MAX VERBOSITY
echo -e "\n${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ 1️⃣ SUBDOMAIN ENUMERATION (subfinder -all)    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
log "Running subfinder -all -d $DOMAIN -o $DOMAINS_FILE"

echo -e "${YELLOW}📊 Live counter: $(tput sc)$(tput cup 24 0)"
subfinder -all -d $DOMAIN -o $DOMAINS_FILE -v 2>&1 | while IFS= read -r line; do
    echo "$line"
    if [[ $line == *"[INF]"* ]]; then
        COUNT=$(wc -l < $DOMAINS_FILE 2>/dev/null || echo 0)
        tput rc; tput ed; echo -ne "${YELLOW}📊 Subdomains found: ${GREEN}$COUNT live${NC}   "
    fi
done

SUB_COUNT=$(wc -l < $DOMAINS_FILE)
log "Subfinder complete: $SUB_COUNT subdomains saved to $DOMAINS_FILE"
echo -e "${GREEN}✅ SUBFINDER: ${SUB_COUNT} subdomains enumerated!${NC}"

# 2. HTTPX - EXTREME VERBOSITY + LIVE PROGRESS
echo -e "\n${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ 2️⃣ LIVE HOST PROBING (httpx)                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
log "Running httpx with stealth flags on $SUB_COUNT subdomains"

LIVE=0; TOTAL=$(wc -l < $DOMAINS_FILE); FAIL=0
echo -e "${YELLOW}📊 Progress: 0/$TOTAL (0%) | Live: 0 | Dead: 0${NC}"

cat $DOMAINS_FILE | httpx \
    -title -status-code -tech-detect -ip -cname -location \
    -pa -retries 3 -threads 100 -random-agent -delay 100ms \
    -tls-probe -http2 -vhost -silent -no-fallback \
    -o $HTTPX_FILE | while read line; do
        TOTAL_DONE=$(( $(wc -l < $HTTPX_FILE 2>/dev/null) + FAIL ))
        PCT=$(( TOTAL_DONE * 100 / TOTAL ))
        
        if [[ $line == *"[200]"* || $line == *"[302]"* || $line == *"[301]"* ]]; then
            ((LIVE++))
            echo -e "${GREEN}✅ LIVE [$LIVE/$TOTAL_DONE] ${line}${NC}"
        elif [[ $line == *"[403]"* ]]; then
            echo -e "${PURPLE}🔒 BLOCKED [$LIVE/$TOTAL_DONE] ${line}${NC}"
        else
            ((FAIL++))
            echo -e "${RED}❌ DEAD [$LIVE/$TOTAL_DONE]${NC}"
        fi
        
        tput rc; echo -ne "${YELLOW}📊 $TOTAL_DONE/$TOTAL ($PCT%) | Live: ${GREEN}$LIVE${YELLOW} | Dead: ${RED}$FAIL${NC}   "
done | tee $LIVE_FILE

LIVE_COUNT=$(wc -l < $HTTPX_FILE)
log "Httpx complete: $LIVE_COUNT live hosts from $TOTAL probed"
echo -e "\n${GREEN}✅ HTTPX: ${LIVE_COUNT} LIVE hosts found!${NC}"

# 3. NAABU - VERBOSE PORT SCANNING
echo -e "\n${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ 3️⃣ STEALTH PORT SCANNING (naabu)            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
log "Running stealth naabu scan on $LIVE_COUNT live hosts"

echo -e "${YELLOW}🔧 Stealth flags: -rate-limit 50 -delay 1s -top-ports 1000 -scan-type c${NC}"
echo -e "${YELLOW}📊 Scanning progress will show live stats...${NC}"

cat $HTTPX_FILE | naabu \
    -top-ports 1000 -rate-limit 50 -delay 1000ms -retries 1 \
    -exclude-cdn -scan-type c -v -stats-interval 15 \
    -silent -no-color -o $PORTS_FILE 2>&1 | while read line; do
        echo -e "${CYAN}[NAABU]${NC} $line"
    done

PORT_COUNT=$(jq '. | length' $PORTS_FILE 2>/dev/null || echo 0)
log "Naabu complete: $PORT_COUNT open ports found"

# 4. VERBOSE SUMMARY
echo -e "\n${PURPLE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║ 📊 ULTIMATE RECON SUMMARY                    ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════╝${NC}"

echo -e "${GREEN}🔍 Subdomains:${NC}     ${SUB_COUNT}"
echo -e "${GREEN}🌐 Live Hosts:${NC}     ${LIVE_COUNT}"
echo -e "${GREEN}🔓 Open Ports:${NC}     ${PORT_COUNT}"
echo -e "${BLUE}📁 Log File:${NC}       $LOG_FILE"

echo -e "\n${GREEN}🔓 TOP 10 OPEN PORTS:${NC}"
cat $PORTS_FILE | jq -r '.[] | "\(.host):\(.ports[]) (\(.service? // "unknown")"' 2>/dev/null | head -10 | \
while read port; do echo "   ${GREEN}🔓 $port${NC}"; done

log "=== RECON SESSION COMPLETE ==="
echo -e "\n${YELLOW}🎉 VERBOSE RECON COMPLETE! Check $LOG_FILE for full details${NC}"
