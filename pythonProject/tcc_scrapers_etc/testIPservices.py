import requests

test_ips = {
    "8.8.8.8": "US",      # Google
    "1.1.1.1": "AU",      # Cloudflare
    "213.186.33.5": "FR", # OVH France
    "77.88.8.8": "RU",    # Yandex
    "202.56.215.55": "IN" # Tata India
}

services = {
    "ipapi.co": lambda ip: f"https://ipapi.co/{ip}/country/",
    "ipinfo.io": lambda ip: f"https://ipinfo.io/{ip}/country",
    "ipwhois.io": lambda ip: f"https://ipwhois.app/json/{ip}",
    "ip-api.com": lambda ip: f"http://ip-api.com/json/{ip}?fields=countryCode"
}

for service, build_url in services.items():
    print(f"\n🔍 Testing service: {service}")
    for ip, expected in test_ips.items():
        try:
            url = build_url(ip)
            resp = requests.get(url, timeout=5)
            resp.raise_for_status()

            if service == "ipwhois.io":
                country = resp.json().get("country_code", "N/A")
            elif service == "ip-api.com":
                country = resp.json().get("countryCode", "N/A")
            else:
                country = resp.text.strip()

            result = "✅" if country == expected else "❌"
            print(f"{ip} → {country} (expected {expected}) {result}")
        except Exception as e:
            print(f"{ip} → ERROR: {e}")
