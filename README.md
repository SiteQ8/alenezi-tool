# AlEnezi Tool: aka SITE

> **All-in-one CTF terminal toolkit. One script. Every category.**

```
    ▄▄▄       ██▓    ▓█████  ███▄    █ ▓█████ ▒███████▒ ██▓
   ▒████▄    ▓██▒    ▓█   ▀  ██ ▀█   █ ▓█   ▀ ▒ ▒ ▒ ▄▀░▓██▒
   ▒██  ▀█▄  ▒██░    ▒███   ▓██  ▀█ ██▒▒███   ░ ▒ ▄▀▒░ ▒██▒
   ░██▄▄▄▄██ ▒██░    ▒▓█  ▄ ▓██▒  ▐▌██▒▒▓█  ▄  ▄▀▒   ░ ░██░
    ▓█   ▓██▒░██████▒░▒████▒▒██░   ▓██░░▒████▒▒███████▒ ░██░

         AlEnezi Tool  aka  S I T E  — CTF Toolkit v2.0
```

---

## Quick Start

```bash
git clone https://github.com/SiteQ8/alenezi-tool
cd alenezi-tool
chmod +x alenezi.sh
./alenezi.sh
```

No installation required. Pure bash.

---

## Modules

| # | Module | Tools Covered |
|---|--------|--------------|
| 1 | **Recon & Enumeration** | nmap (9 modes), masscan, OS detection, vuln scripts |
| 2 | **Web Exploitation** | gobuster, ffuf, nikto, sqlmap, LFI, SSRF, PHP filters, VHost |
| 3 | **Crypto & Encoding** | Base64, Hex, ROT-N, XOR brute, Vigenere, Morse, JWT, RSA, AES |
| 4 | **Steganography** | binwalk, steghide, zsteg, exiftool, foremost, magic bytes |
| 5 | **Forensics & Memory** | volatility, tshark/pcap, foremost, zip cracking |
| 6 | **Binary Exploit / PWN** | checksec, GDB, ROPgadget, shellcode library, ret2libc template |
| 7 | **Password Cracking** | hashcat (wordlist/rules/mask), john, hydra (SSH/HTTP/FTP) |
| 8 | **Reverse Engineering** | radare2, objdump, jadx, ltrace, strace, nm |
| 9 | **Network Tools** | Reverse shell generator, netcat, socat port forward, bind shells |
| 0 | **Notes & Flag Tracker** | Capture flags, session notes, command log |
| r | **Quick Reference** | Linux/Windows PrivEsc, SQLi/XSS payloads, GTFObins, file transfer |

---

## Recommended Tool Install (Debian/Ubuntu/Kali)

```bash
sudo apt update && sudo apt install -y \
  nmap masscan gobuster dirb nikto curl wget sqlmap \
  hydra john hashcat \
  binwalk steghide exiftool foremost \
  gdb ltrace strace objdump readelf \
  openssl python3 netcat-openbsd socat \
  tshark tcpdump radare2 ffuf
```

Python extras:
```bash
pip3 install pwntools gmpy2 sympy
```

---

## Features

- **Global target**: set once, reuse across all modules (`t` from main menu)
- **Session log**: every command logged to `~/.alenezi_session.log`
- **Flag tracker**: save flags as you capture them, count shown on banner
- **Notes**: keep recon notes within the tool
- **Tool checker**: scan your system for missing tools with one keypress (`c`)
- **No deps**: runs on any bash 4+ system

---

## Files Created

| File | Purpose |
|------|---------|
| `~/.alenezi_notes.txt` | Session notes |
| `~/.alenezi_flags.txt` | Captured flags |
| `~/.alenezi_session.log` | Command history |

---

## Legal

This tool is intended for **legal CTF competitions, authorized penetration testing, and educational use only.**  
The author is not responsible for misuse. Always get permission before testing any system.

---

## Author

**AlEnezi**, made for winning CTFs.

---

*"One tool. Every category. Capture the flag."*
