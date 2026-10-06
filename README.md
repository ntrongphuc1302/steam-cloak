# Steam-Cloak

A small Windows batch utility that helps access Steam when DNS is being blocked or hijacked at the ISP level. It can switch the system resolver to Cloudflare or Google (with or without DNS over HTTPS), inspect the current configuration, and run a quick connectivity test.

This tool does **not** change your IP address and does **not** route Steam traffic through a proxy or VPN. It only reconfigures the local DNS resolver so that Steam domain lookups go to a public DNS provider that is not on the ISP block list.

> **Compatibility:** Windows 10 / Windows 11 (PowerShell 5.1+)

---

## Features

- 4 DNS modes: Cloudflare, Google, each with or without DoH.
- 1 restore mode: Automatic / DHCP.
- View currently configured IPv4 / IPv6 DNS per adapter.
- Built-in diagnostic test: DNS resolution, TCP 443, HTTPS HEAD to Steam Store and Steam Community.
- Per-adapter application (only physical adapters that are `Up`).
- Auto flush of the local DNS cache after every change.
- Auto-elevates to Administrator if launched without privileges.

## Quick Start

1. Download `steam-cloak.bat` from the latest release.
2. Right-click the file and choose **Run as administrator** (the script will also auto-elevate).
3. Pick an option from the menu:

   | # | Mode | When to use |
   |---|------|-------------|
   | `[1]` | Cloudflare DNS (IPv4 + IPv6, no DoH) | **Try first** |
   | `[2]` | Google DNS (IPv4 + IPv6, no DoH) | **Try first** |
   | `[3]` | Cloudflare + DNS over HTTPS | **Try after [1] and [2] fail** |
   | `[4]` | Google + DNS over HTTPS | **Try if [3] does not work** |
   | `[5]` | Automatic / DHCP | Restore default |
   | `[6]` | Show current DNS | Inspect the configuration |
   | `[7]` | Test DNS + Steam | Diagnose connectivity |
   | `[0]` | Exit | |

4. If Steam is still unreachable after `[3]` and `[4]`, your ISP is most likely blocking beyond DNS (SNI filtering, IP blocking, or DPI). Switching DNS alone will not be enough in that case.

## What the Tool Changes

Only the per-adapter DNS server addresses and the DoH configuration of the Windows DNS client. Nothing else is modified:

- No registry changes outside the DNS client configuration.
- No system file modification.
- No installation. Removing the `.bat` file fully reverts everything except any DNS configuration you applied (use option `[5]` to restore).

## DNS Endpoints Used

| Provider | IPv4 | IPv6 | DoH template |
|----------|------|------|--------------|
| Cloudflare | `1.1.1.1`, `1.0.0.1` | `2606:4700:4700::1111`, `2606:4700:4700::1001` | `https://cloudflare-dns.com/dns-query` |
| Google | `8.8.8.8`, `8.8.4.4` | `2001:4860:4860::8888`, `2001:4860:4860::8844` | `https://dns.google/dns-query` |

## How the Built-in Test Works

Option `[7]` runs five checks:

1. `nslookup store.steampowered.com` — DNS resolves the Steam Store domain.
2. `nslookup steamcommunity.com` — DNS resolves the Steam Community domain.
3. `Test-NetConnection store.steampowered.com -Port 443` — TCP handshake with the Store.
4. `Test-NetConnection steamcommunity.com -Port 443` — TCP handshake with Community.
5. `Invoke-WebRequest` HEAD against both domains — verifies that an HTTPS request actually completes.

### How to read the results

- **nslookup OK + TCP 443 = True** — DNS and basic connectivity are working. The issue is probably at a higher layer (Steam client, cache, or Steam-specific block).
- **nslookup OK but TCP 443 = False** — Your ISP is blocking beyond DNS. Try a VPN.
- **Both Cloudflare + DoH and Google + DoH fail** — Plain DNS switching is not enough. The block is not based on DNS.

## Important Notes

- **Run as administrator.** The script will auto-elevate, but if UAC is disabled the first launch will fail.
- **Close Steam before switching DNS.** Steam caches DNS responses internally; reopen Steam after the change so it picks up the new resolver.
- **DoH requires Windows 10 19628+ / Windows 11.** On older builds, options `[3]` and `[4]` will fail silently and revert to plain DNS.
- **Corporate / managed devices** may override your DNS settings via Group Policy. In that case this tool will not stick.
- **IPv6 only matters if you actually use IPv6.** If your network is IPv4-only, the IPv6 entries are harmless and ignored.

## Frequently Asked Questions

**Does this tool bypass region locks or licensing?**
No. It only changes DNS. Region locks, payment restrictions, and license enforcement are server-side.

**Will this get my Steam account banned?**
No. It is just DNS. Steam cannot detect it and does not care.

**Why is option [3] or [4] slower than [1] or [2]?**
DoH encrypts every lookup, which adds a small amount of latency. It also requires that `cloudflare-dns.com` and `dns.google` are themselves reachable. If your ISP is blocking them, DoH will not work.

**Can I keep this configuration across reboots?**
Yes. The DNS settings you apply are persistent. The script does not need to run again on reboot.

**How do I undo everything?**
Run option `[5]`. It resets every active physical adapter to Automatic / DHCP and flushes the DNS cache.

## Disclaimer

This tool only changes the local DNS configuration. It does not encrypt your traffic, does not hide your IP, and does not protect your privacy beyond what the chosen DNS provider offers. Using third-party DNS resolvers means your DNS queries are now visible to that provider instead of your ISP — read their privacy policies (Cloudflare: [cloudflare.com/privacypolicy](https://www.cloudflare.com/privacypolicy/), Google: [policies.google.com/privacy](https://policies.google.com/privacy)) before using DoH.

The author is not responsible for any terms-of-service issues that may arise from using this tool with third-party services. Use at your own risk.

## License

MIT — Copyright (c) 2026 [ntrongphuc1302](https://github.com/ntrongphuc1302). See [LICENSE](LICENSE) for the full text.
