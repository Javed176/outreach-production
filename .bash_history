# --- STEP 2: RAW DATA & EMAIL EXTRACTION ---
st.header("📋 2. Input Raw Data & Extract Targets")
col_data, col_preview = st.columns([2, 1])

with col_data:
    raw_data_feed = st.text_area(
        "Paste any raw text here (Paste your scraped tables, CSV lines, or raw text logs):", 
        placeholder="Drop raw carrier information here...",
        height=180
    )

# Real-time regex extraction engine
extracted_targets = list(set(re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', raw_data_feed)))
# Clean out non-target standard system keywords if copied over accidentally
extracted_targets = [e for e in extracted_targets if "roserocket" not in e.lower() and "fmcsa" not in e.lower()]

with col_preview:
    st.metric("Extracted Valid Targets", len(extracted_targets))
    st.markdown("**Target List Preview:**")
    if extracted_targets:
        df_preview = pd.DataFrame(extracted_targets, columns=["Target Email"])
        st.dataframe(df_preview, use_container_width=True, height=120)
    else:
        st.info("Waiting for data...")

# --- STEP 3: EDITABLE TEMPLATE ---
st.header("✉️ 3. Customize Your Pitch Template")
email_subject = st.text_input("Email Subject Line:", value="Available Equipment / Top-Tier Dispatch Partnership")
email_body = st.text_area(
    "Email Body Text:", 
    value="Hello,\n\nWe noticed you are running active equipment in this lane. AR Transport provides full-service dispatching with consistent premium loads, direct broker lines, and custom maintenance perks after 1 year.\n\nLet us know if you have trucks open this week!\n\nBest regards,\nTony Burns\nManager, AR Transport",
    height=180
)

# --- BACKEND SMTP ENGINE ---
def send_outreach_email(sender_meta, target_email, subject, body):
    """Executes a secure network SMTP connection step."""
    sender_email = sender_meta["email"]
    sender_password = sender_meta["password"]
    
    if "gmail" in sender_email.lower():
        smtp_host = "smtp.gmail.com"
    elif "outlook" in sender_email.lower() or "hotmail" in sender_email.lower():
        smtp_host = "smtp-mail.outlook.com"
    else:
        smtp_host = "smtp.gmail.com"
        
    try:
        msg = MIMEMultipart()
        msg['From'] = sender_email
        msg['To'] = target_email
        msg['Subject'] = subject
        msg.attach(MIMEText(body, 'plain'))
        
        server = smtplib.SMTP(smtp_host, 587, timeout=5)
        server.starttls()
        server.login(sender_email, sender_password)
        server.sendmail(sender_email, target_email, msg.as_string())
        server.quit()
        return True, "Dispatched successfully"
    except Exception as e:
        return False, str(e)

# --- CONTROLS & LOOP SYSTEM ---
st.markdown("---")
col_ctrl1, col_ctrl2, col_ctrl3 = st.columns(3)

if col_ctrl1.button("🚀 Start Outreach Blast", use_container_width=True):
    if not parsed_senders:
        st.error("Please add at least one valid sender email configuration line.")
    elif not extracted_targets:
        st.error("No target email addresses found to send pitches to.")
    else:
        st.session_state.campaign_running = True
        st.rerun()

if col_ctrl2.button("🛑 STOP Campaign Loop", use_container_width=True):
    st.session_state.campaign_running = False
    st.warning("Campaign paused immediately.")

if col_ctrl3.button("🗑️ Reset Campaign Tracker", use_container_width=True):
    st.session_state.campaign_running = False
    st.session_state.target_idx = 0
    st.session_state.sender_idx = 0
    st.session_state.history_logs = []
    st.success("Trackers and progress metrics reset cleanly.")
    st.rerun()

# --- ACTIVE BLAST LOOP PROCESSING ---
if st.session_state.campaign_running:
    if st.session_state.target_idx >= len(extracted_targets):
        st.session_state.campaign_running = False
        st.success("🎉 Campaign complete! All extracted targets have been messaged.")
        st.rerun()
    else:
        current_target = extracted_targets[st.session_state.target_idx]
        current_sender = parsed_senders[st.session_state.sender_idx % len(parsed_senders)]
        
        status_banner = st.empty()
        status_banner.info(f"Sending line package: From **{current_sender['email']}** ➡️ To **{current_target}**")
        
        success, message = send_outreach_email(current_sender, current_target, email_subject, email_body)
        
        timestamp = time.strftime("%H:%M:%S")
        if success:
            st.session_state.history_logs.append({
                "Timestamp": timestamp,
                "Sender Account": current_sender["email"],
                "Recipient Target": current_target,
                "Status": "🟢 SENT",
                "Details": message
            })
        else:
            st.session_state.history_logs.append({
                "Timestamp": timestamp,
                "Sender Account": current_sender["email"],
                "Recipient Target": current_target,
                "Status": "🔴 FAILED",
                "Details": message
            })
            
        st.session_state.target_idx += 1
        st.session_state.sender_idx += 1
        
        time.sleep(1.5)
        st.rerun()

# --- LIVE OPERATIONS LOG SHEET ---
st.subheader("📊 Live Campaign Delivery Sheet")
col_m1, col_m2 = st.columns(2)
col_m1.metric("Progress", f"{st.session_state.target_idx} / {len(extracted_targets)} Targets")
if parsed_senders:
    col_m2.metric("Next Active Sender Rotation", parsed_senders[st.session_state.sender_idx % len(parsed_senders)]["email"])

if st.session_state.history_logs:
    df_logs = pd.DataFrame(st.session_state.history_logs)
    st.dataframe(df_logs, use_container_width=True)
else:
    st.info("Campaign engine idle. Load raw data text above and click 'Start Outreach Blast'.")
EOF

streamlit run outreach_app.py
source transport_env/bin/activate
notepad.exe outreach_app.py
streamlit run outreach_app.py --server.address 0.0.0.0
streamlit run outreach_app.py --server.port 8555 --server.address 0.0.0.0
notepad.exe outreach_app.py
streamlit run outreach_app.py --server.port 8555 --server.address 0.0.0.0
notepad.exe outreach_app.py
streamlit run outreach_app.py --server.port 8555 --server.address 0.0.0.0
source transport_env/bin/activate
streamlit run outreach_app.py --server.port 8555
notepad.exe outreach_app.py
streamlit run outreach_app.py --server.port 8555 --server.address 0.0.0.0
notepad.exe outreach_app.py
streamlit run outreach_app.py --server.port 8555 --server.address 0.0.0.0
notepad.exe outreach_app.py
streamlit run outreach_app.py --server.port 8555 --server.address 0.0.0.0
notepad.exe outreach_app.py
streamlit run outreach_app.py --server.port 8555 --server.address 0.0.0.0
notepad.exe outreach_app.py
streamlit run outreach_app.py --server.port 8555 --server.address 0.0.0.0
source transport_env/bin/activate
streamlit run outreach_app.py --server.port 8555 --server.address 0.0.0.0
source transport_env/bin/activate
streamlit run outreach_app.py --server.port 8555 --server.address 0.0.0.0
pip install requests pandas
pip install requests pandas --break-system-packages
sudo apt update && sudo apt install python3-requests python3-pandas -y
python3 harvester.py
nano harvester.py
python3 harvester.py
nano harvester.py
rmdir name_of_old_folder
ls
rm harvester.py harvester.py.save outreach_app.py
nano harvester.py
python3 harvester.py
rm harvester.py harvester.py.save outreach_app.py
nano harvester.py
python3 harvester.py
pip install beautifulsoup4 --break-system-packages
nano harvester.py
python3 harvester.py
sudo apt update && sudo apt install python3-tk -y
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import requests
import re
import threading
import time
import urllib.parse
import pandas as pd
# High-fidelity desktop browser layout profile to bypass 403 blocks
BROWSER_HEADERS = {
}
class HarvesterApp:
if __name__ == "__main__":;     root = tk.Tk()
clear
nano app.py
python3 app.py
nano app.py
nano ~/Desktop/CarrierHarvester.desktop
python3 app.py
pip install pandas requests beautifulsoup4 --break-system-packages
python3 app.py
sudo apt update && sudo apt install python3-tk -y
python3 app.py
explorer.exe .
cp leads.csv /mnt/c/Users/Public/Desktop/ 2>/dev/null || cp leads.csv /mnt/c/
python3 app.py
cat << 'EOF' > app.py
import requests
import re
import time
import urllib.parse
import csv

START_MC = 1400000    
TOTAL_COUNT = 20      
OUTPUT_FILE = "/mnt/c/leads.csv"

BROWSER_HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
}

def hunt_web_email(company, location):
    if not company or company == "UNKNOWN":
        return "No Public Email"
    query = f'"{company}" {location} carrier contact email'
    url = f"https://html.duckduckgo.com/html/?q={urllib.parse.quote_plus(query)}"
    try:
        time.sleep(0.5)
        res = requests.get(url, headers=BROWSER_HEADERS, timeout=5.0)
        if res.status_code == 200:
            emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
            clean = [e for e in emails if "duckduckgo" not in e.lower() and "fmcsa" not in e.lower() and not e.endswith(('.png', '.jpg'))]
            if clean:
                return clean[0].lower()
    except: pass
    return "No Public Email"

def fetch_carrier(mc):
    url = f"https://li-public.fmcsa.dot.gov/l_i/pk_authority.v_authority_det?pv_ap_docket={mc}&pv_v_prefix=MC"
    try:
        res = requests.get(url, headers=BROWSER_HEADERS, timeout=5.0)
        if res.status_code == 200 and "Legal Name" in res.text:
            name_m = re.search(r'Legal Name:\s*([^<>\n\r]+)', res.text, re.IGNORECASE)
            name = name_m.group(1).strip().upper() if name_m else "UNKNOWN"
            name = re.sub(r'\s+', ' ', name).replace('&NBSP;', '')
            
            status = "🟢 ACTIVE" if "AUTHORIZED" in res.text.upper() else "🔴 INACTIVE"
            loc_m = re.search(r'Legal Address:[^>]*>([^<>]+),\s*([A-Z]{2})', res.text)
            location = f"{loc_m.group(1).strip()}, {loc_m.group(2).strip()}" if loc_m else "USA"
            
            emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
            email = emails[0].lower() if (emails and "fmcsa" not in emails[0].lower()) else "No Public Email"
            
            return {"mc": f"MC-{mc}", "name": name, "status": status, "email": email, "location": location}
    except: pass
    return None

print("🚀 Starting Carrier Email Harvester Engine...")
print(f"Creating offline spreadsheet file: '{OUTPUT_FILE}'\n")

with open(OUTPUT_FILE, mode='w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(["MC Number", "Carrier Business Name", "Operating Status", "Extracted Email", "Base Location"])

    current_mc = START_MC
    for i in range(TOTAL_COUNT):
        print(f"[{i+1}/{TOTAL_COUNT}] Scanning MC-{current_mc}... ", end="", flush=True)
        
        data = fetch_carrier(current_mc)
        if data:
            if data["email"] == "No Public Email":
                data["email"] = hunt_web_email(data["name"], data["location"])
            print(f"✅ Found: {data['name'][:25]} -> {data['email']}")
            writer.writerow([data["mc"], data["name"], data["status"], data["email"], data["location"]])
        else:
            print("❌ Invalid/Dismissed Record")
            writer.writerow([f"MC-{current_mc}", "UNISSUED RECORD", "❌ INACTIVE", "No Public Email", "N/A"])
            
        current_mc += 1
        time.sleep(0.4)

print(f"\n📊 Batch complete! Open your Windows C: Drive to find '{OUTPUT_FILE}'")
EOF

cat << 'EOF' > app.py
import requests
import re
import time
import urllib.parse
import csv

START_MC = 1400000    
TOTAL_COUNT = 20      
OUTPUT_FILE = "/mnt/c/leads.csv"

BROWSER_HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
}

def hunt_web_email(company, location):
    if not company or company == "UNKNOWN":
        return "No Public Email"
    query = f'"{company}" {location} carrier contact email'
    url = f"https://html.duckduckgo.com/html/?q={urllib.parse.quote_plus(query)}"
    try:
        time.sleep(0.5)
        res = requests.get(url, headers=BROWSER_HEADERS, timeout=5.0)
        if res.status_code == 200:
            emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
            clean = [e for e in emails if "duckduckgo" not in e.lower() and "fmcsa" not in e.lower() and not e.endswith(('.png', '.jpg'))]
            if clean:
                return clean[0].lower()
    except: pass
    return "No Public Email"

def fetch_carrier(mc):
    url = f"https://li-public.fmcsa.dot.gov/l_i/pk_authority.v_authority_det?pv_ap_docket={mc}&pv_v_prefix=MC"
    try:
        res = requests.get(url, headers=BROWSER_HEADERS, timeout=5.0)
        if res.status_code == 200 and "Legal Name" in res.text:
            name_m = re.search(r'Legal Name:\s*([^<>\n\r]+)', res.text, re.IGNORECASE)
            name = name_m.group(1).strip().upper() if name_m else "UNKNOWN"
            name = re.sub(r'\s+', ' ', name).replace('&NBSP;', '')
            
            status = "🟢 ACTIVE" if "AUTHORIZED" in res.text.upper() else "🔴 INACTIVE"
            loc_m = re.search(r'Legal Address:[^>]*>([^<>]+),\s*([A-Z]{2})', res.text)
            location = f"{loc_m.group(1).strip()}, {loc_m.group(2).strip()}" if loc_m else "USA"
            
            emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
            email = emails[0].lower() if (emails and "fmcsa" not in emails[0].lower()) else "No Public Email"
            
            return {"mc": f"MC-{mc}", "name": name, "status": status, "email": email, "location": location}
    except: pass
    return None

print("🚀 Starting Carrier Email Harvester Engine...")
print(f"Creating offline spreadsheet file: '{OUTPUT_FILE}'\n")

with open(OUTPUT_FILE, mode='w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(["MC Number", "Carrier Business Name", "Operating Status", "Extracted Email", "Base Location"])

    current_mc = START_MC
    for i in range(TOTAL_COUNT):
        print(f"[{i+1}/{TOTAL_COUNT}] Scanning MC-{current_mc}... ", end="", flush=True)
        
        data = fetch_carrier(current_mc)
        if data:
            if data["email"] == "No Public Email":
                data["email"] = hunt_web_email(data["name"], data["location"])
            print(f"✅ Found: {data['name'][:25]} -> {data['email']}")
            writer.writerow([data["mc"], data["name"], data["status"], data["email"], data["location"]])
        else:
            print("❌ Invalid/Dismissed Record")
            writer.writerow([f"MC-{current_mc}", "UNISSUED RECORD", "❌ INACTIVE", "No Public Email", "N/A"])
            
        current_mc += 1
        time.sleep(0.4)

print(f"\n📊 Batch complete! Open your Windows C: Drive to find '{OUTPUT_FILE}'")
EOF

curl -s "https://pastebin.com/raw/LhCHmK41" > app.py 2>/dev/null || cat << 'EOF' > app.py
import requests, re, time, urllib.parse, csv
START_MC, TOTAL_COUNT, OUTPUT_FILE = 1400000, 20, "/mnt/c/leads.csv"
BROWSER_HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
def hunt_web_email(c, l):
    if not c or c == "UNKNOWN": return "No Public Email"
    try:
        res = requests.get(f"https://html.duckduckgo.com/html/?q={urllib.parse.quote_plus(f'\"{c}\" {l} carrier contact email')}", headers=BROWSER_HEADERS, timeout=5.0)
        emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
        clean = [e for e in emails if "duckduckgo" not in e.lower() and "fmcsa" not in e.lower() and not e.endswith(('.png', '.jpg'))]
        if clean: return clean[0].lower()
    except: pass
    return "No Public Email"
def fetch_carrier(mc):
    try:
        res = requests.get(f"https://li-public.fmcsa.dot.gov/l_i/pk_authority.v_authority_det?pv_ap_docket={mc}&pv_v_prefix=MC", headers=BROWSER_HEADERS, timeout=5.0)
        if res.status_code == 200 and "Legal Name" in res.text:
            n = re.search(r'Legal Name:\s*([^<>\n\r]+)', res.text, re.IGNORECASE)
            name = re.sub(r'\s+', ' ', n.group(1).strip().upper()).replace('&NBSP;', '') if n else "UNKNOWN"
            status = "🟢 ACTIVE" if "AUTHORIZED" in res.text.upper() else "🔴 INACTIVE"
            l = re.search(r'Legal Address:[^>]*>([^<>]+),\s*([A-Z]{2})', res.text)
            loc = f"{l.group(1).strip()}, {l.group(2).strip()}" if l else "USA"
            ems = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
            email = ems[0].lower() if (ems and "fmcsa" not in ems[0].lower()) else "No Public Email"
            return {"mc": f"MC-{mc}", "name": name, "status": status, "email": email, "location": loc}
    except: pass
    return None
print("🚀 Starting Carrier Email Harvester Engine...\n")
with open(OUTPUT_FILE, mode='w', newline='', encoding='utf-8') as f:
    w = csv.writer(f)
    w.writerow(["MC Number", "Carrier Business Name", "Operating Status", "Extracted Email", "Base Location"])
    curr = START_MC
    for i in range(TOTAL_COUNT):
        print(f"[{i+1}/{TOTAL_COUNT}] Scanning MC-{curr}... ", end="", flush=True)
        d = fetch_carrier(curr)
        if d:
            if d["email"] == "No Public Email": d["email"] = hunt_web_email(d["name"], d["location"])
            print(f"✅ Found: {d['name'][:20]} -> {d['email']}")
            w.writerow([d["mc"], d["name"], d["status"], d["email"], d["location"]])
        else:
            print("❌ Invalid/Dismissed")
            w.writerow([f"MC-{curr}", "UNISSUED RECORD", "❌ INACTIVE", "No Public Email", "N/A"])
        curr += 1
        time.sleep(0.4)
print(f"\n📊 Batch complete! Open your Windows C: Drive to find 'leads.csv'")
EOF

curl -s "https://pastebin.com/raw/LhCHmK41" > app.py 2>/dev/null || cat << 'EOF' > app.py
import requests, re, time, urllib.parse, csv
START_MC, TOTAL_COUNT, OUTPUT_FILE = 1400000, 20, "/mnt/c/leads.csv"
BROWSER_HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
def hunt_web_email(c, l):
    if not c or c == "UNKNOWN": return "No Public Email"
    try:
        res = requests.get(f"https://html.duckduckgo.com/html/?q={urllib.parse.quote_plus(f'\"{c}\" {l} carrier contact email')}", headers=BROWSER_HEADERS, timeout=5.0)
        emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
        clean = [e for e in emails if "duckduckgo" not in e.lower() and "fmcsa" not in e.lower() and not e.endswith(('.png', '.jpg'))]
        if clean: return clean[0].lower()
    except: pass
    return "No Public Email"
def fetch_carrier(mc):
    try:
        res = requests.get(f"https://li-public.fmcsa.dot.gov/l_i/pk_authority.v_authority_det?pv_ap_docket={mc}&pv_v_prefix=MC", headers=BROWSER_HEADERS, timeout=5.0)
        if res.status_code == 200 and "Legal Name" in res.text:
            n = re.search(r'Legal Name:\s*([^<>\n\r]+)', res.text, re.IGNORECASE)
            name = re.sub(r'\s+', ' ', n.group(1).strip().upper()).replace('&NBSP;', '') if n else "UNKNOWN"
            status = "🟢 ACTIVE" if "AUTHORIZED" in res.text.upper() else "🔴 INACTIVE"
            l = re.search(r'Legal Address:[^>]*>([^<>]+),\s*([A-Z]{2})', res.text)
            loc = f"{l.group(1).strip()}, {l.group(2).strip()}" if l else "USA"
            ems = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
            email = ems[0].lower() if (ems and "fmcsa" not in ems[0].lower()) else "No Public Email"
            return {"mc": f"MC-{mc}", "name": name, "status": status, "email": email, "location": loc}
    except: pass
    return None
print("🚀 Starting Carrier Email Harvester Engine...\n")
with open(OUTPUT_FILE, mode='w', newline='', encoding='utf-8') as f:
    w = csv.writer(f)
    w.writerow(["MC Number", "Carrier Business Name", "Operating Status", "Extracted Email", "Base Location"])
    curr = START_MC
    for i in range(TOTAL_COUNT):
        print(f"[{i+1}/{TOTAL_COUNT}] Scanning MC-{curr}... ", end="", flush=True)
        d = fetch_carrier(curr)
        if d:
            if d["email"] == "No Public Email": d["email"] = hunt_web_email(d["name"], d["location"])
            print(f"✅ Found: {d['name'][:20]} -> {d['email']}")
            w.writerow([d["mc"], d["name"], d["status"], d["email"], d["location"]])
        else:
            print("❌ Invalid/Dismissed")
            w.writerow([f"MC-{curr}", "UNISSUED RECORD", "❌ INACTIVE", "No Public Email", "N/A"])
        curr += 1
        time.sleep(0.4)
print(f"\n📊 Batch complete! Open your Windows C: Drive to find 'leads.csv'")
EOF

python3 app.py
curl -s "https://pastebin.com/raw/LhCHmK41" > app.py 2>/dev/null || cat << 'EOF' > app.py
import requests, re, time, urllib.parse, csv
START_MC, TOTAL_COUNT, OUTPUT_FILE = 1400000, 20, "/mnt/c/leads.csv"
BROWSER_HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
def hunt_web_email(c, l):
    if not c or c == "UNKNOWN": return "No Public Email"
    try:
        res = requests.get(f"https://html.duckduckgo.com/html/?q={urllib.parse.quote_plus(f'\"{c}\" {l} carrier contact email')}", headers=BROWSER_HEADERS, timeout=5.0)
        emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
        clean = [e for e in emails if "duckduckgo" not in e.lower() and "fmcsa" not in e.lower() and not e.endswith(('.png', '.jpg'))]
        if clean: return clean[0].lower()
    except: pass
    return "No Public Email"
def fetch_carrier(mc):
    try:
        res = requests.get(f"https://li-public.fmcsa.dot.gov/l_i/pk_authority.v_authority_det?pv_ap_docket={mc}&pv_v_prefix=MC", headers=BROWSER_HEADERS, timeout=5.0)
        if res.status_code == 200 and "Legal Name" in res.text:
            n = re.search(r'Legal Name:\s*([^<>\n\r]+)', res.text, re.IGNORECASE)
            name = re.sub(r'\s+', ' ', n.group(1).strip().upper()).replace('&NBSP;', '') if n else "UNKNOWN"
            status = "🟢 ACTIVE" if "AUTHORIZED" in res.text.upper() else "🔴 INACTIVE"
            l = re.search(r'Legal Address:[^>]*>([^<>]+),\s*([A-Z]{2})', res.text)
            loc = f"{l.group(1).strip()}, {l.group(2).strip()}" if l else "USA"
            ems = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
            email = ems[0].lower() if (ems and "fmcsa" not in ems[0].lower()) else "No Public Email"
            return {"mc": f"MC-{mc}", "name": name, "status": status, "email": email, "location": loc}
    except: pass
    return None
print("🚀 Starting Carrier Email Harvester Engine...\n")
with open(OUTPUT_FILE, mode='w', newline='', encoding='utf-8') as f:
    w = csv.writer(f)
    w.writerow(["MC Number", "Carrier Business Name", "Operating Status", "Extracted Email", "Base Location"])
    curr = START_MC
    for i in range(TOTAL_COUNT):
        print(f"[{i+1}/{TOTAL_COUNT}] Scanning MC-{curr}... ", end="", flush=True)
        d = fetch_carrier(curr)
        if d:
            if d["email"] == "No Public Email": d["email"] = hunt_web_email(d["name"], d["location"])
            print(f"✅ Found: {d['name'][:20]} -> {d['email']}")
            w.writerow([d["mc"], d["name"], d["status"], d["email"], d["location"]])
        else:
            print("❌ Invalid/Dismissed")
            w.writerow([f"MC-{curr}", "UNISSUED RECORD", "❌ INACTIVE", "No Public Email", "N/A"])
        curr += 1
        time.sleep(0.4)
print(f"\n📊 Batch complete! Open your Windows C: Drive to find 'leads.csv'")
EOF

sed -i 's|"/mnt/c/leads.csv"|"leads.csv"|g' app.py
python3 app.py
explorer.exe leads.csv
MC Number,Carrier Business Name,Operating Status,Extracted Email,Base Location
MC-1400000,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400001,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400002,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400003,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400004,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400005,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400006,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400007,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400008,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400009,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400010,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400011,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400012,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400013,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400014,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400015,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400016,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400017,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400018,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
MC-1400019,UNISSUED RECORD,❌ INACTIVE,No Public Email,N/A
python3 app.py
explorer.exe leads.csv
sed -i 's/START_MC = 150000/START_MC = 1066434/g' app.py
python3 app.py
sed -i 's/START_MC = .*/START_MC = 1066434/g' app.py
python3 app.py
explorer.exe leads.csv
cat << 'EOF' > app.py
import requests, re, time, urllib.parse, csv
START_MC, TOTAL_COUNT, OUTPUT_FILE = 1066434, 20, "leads.csv"
BROWSER_HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
def hunt_web_email(c, l):
    if not c or c == "UNKNOWN": return "No Public Email"
    try:
        res = requests.get(f"https://html.duckduckgo.com/html/?q={urllib.parse.quote_plus(f'\"{c}\" {l} carrier contact email')}", headers=BROWSER_HEADERS, timeout=5.0)
        emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
        clean = [e for e in emails if "duckduckgo" not in e.lower() and "fmcsa" not in e.lower() and not e.endswith(('.png', '.jpg'))]
        if clean: return clean[0].lower()
    except: pass
    return "No Public Email"
def fetch_carrier(mc):
    try:
        res = requests.get(f"https://li-public.fmcsa.dot.gov/l_i/pk_authority.v_authority_det?pv_ap_docket={mc}&pv_v_prefix=MC", headers=BROWSER_HEADERS, timeout=5.0)
        if res.status_code == 200 and "Legal Name" in res.text:
            n = re.search(r'Legal Name:\s*([^<>\n\r]+)', res.text, re.IGNORECASE)
            name = re.sub(r'\s+', ' ', n.group(1).strip().upper()).replace('&NBSP;', '') if n else "UNKNOWN"
            status = "🟢 ACTIVE" if "AUTHORIZED" in res.text.upper() else "🔴 INACTIVE"
            l = re.search(r'Legal Address:[^>]*>([^<>]+),\s*([A-Z]{2})', res.text)
            loc = f"{l.group(1).strip()}, {l.group(2).strip()}" if l else "USA"
            ems = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
            email = ems[0].lower() if (ems and "fmcsa" not in ems[0].lower()) else "No Public Email"
            return {"mc": f"MC-{mc}", "name": name, "status": status, "email": email, "location": loc}
    except: pass
    return None
print("🚀 Starting Carrier Email Harvester Engine...\n")
with open(OUTPUT_FILE, mode='w', newline='', encoding='utf-8') as f:
    w = csv.writer(f)
    w.writerow(["MC Number", "Carrier Business Name", "Operating Status", "Extracted Email", "Base Location"])
    curr = START_MC
    for i in range(TOTAL_COUNT):
        print(f"[{i+1}/{TOTAL_COUNT}] Scanning MC-{curr}... ", end="", flush=True)
        d = fetch_carrier(curr)
        if d:
            if d["email"] == "No Public Email": d["email"] = hunt_web_email(d["name"], d["location"])
            print(f"✅ Found: {d['name'][:20]} -> {d['email']}")
            w.writerow([d["mc"], d["name"], d["status"], d["email"], d["location"]])
        else:
            print("❌ Invalid/Dismissed")
            w.writerow([f"MC-{curr}", "UNISSUED RECORD", "❌ INACTIVE", "No Public Email", "N/A"])
        curr += 1
        time.sleep(0.4)
print(f"\n📊 Batch complete! Open your Windows file to find 'leads.csv'")
EOF

cat << 'EOF' > app.py
import requests, re, time, urllib.parse, csv
START_MC, TOTAL_COUNT, OUTPUT_FILE = 1066434, 20, "leads.csv"
BROWSER_HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
def hunt_web_email(c, l):
    if not c or c == "UNKNOWN": return "No Public Email"
    try:
        res = requests.get(f"https://html.duckduckgo.com/html/?q={urllib.parse.quote_plus(f'\"{c}\" {l} carrier contact email')}", headers=BROWSER_HEADERS, timeout=5.0)
        emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
        clean = [e for e in emails if "duckduckgo" not in e.lower() and "fmcsa" not in e.lower() and not e.endswith(('.png', '.jpg'))]
        if clean: return clean[0].lower()
    except: pass
    return "No Public Email"
def fetch_carrier(mc):
    try:
        res = requests.get(f"https://li-public.fmcsa.dot.gov/l_i/pk_authority.v_authority_det?pv_ap_docket={mc}&pv_v_prefix=MC", headers=BROWSER_HEADERS, timeout=5.0)
        if res.status_code == 200 and "Legal Name" in res.text:
            n = re.search(r'Legal Name:\s*([^<>\n\r]+)', res.text, re.IGNORECASE)
            name = re.sub(r'\s+', ' ', n.group(1).strip().upper()).replace('&NBSP;', '') if n else "UNKNOWN"
            status = "🟢 ACTIVE" if "AUTHORIZED" in res.text.upper() else "🔴 INACTIVE"
            l = re.search(r'Legal Address:[^>]*>([^<>]+),\s*([A-Z]{2})', res.text)
            loc = f"{l.group(1).strip()}, {l.group(2).strip()}" if l else "USA"
            ems = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
            email = ems[0].lower() if (ems and "fmcsa" not in ems[0].lower()) else "No Public Email"
            return {"mc": f"MC-{mc}", "name": name, "status": status, "email": email, "location": loc}
    except: pass
    return None
print("🚀 Starting Carrier Email Harvester Engine...\n")
with open(OUTPUT_FILE, mode='w', newline='', encoding='utf-8') as f:
    w = csv.writer(f)
    w.writerow(["MC Number", "Carrier Business Name", "Operating Status", "Extracted Email", "Base Location"])
    curr = START_MC
    for i in range(TOTAL_COUNT):
        print(f"[{i+1}/{TOTAL_COUNT}] Scanning MC-{curr}... ", end="", flush=True)
        d = fetch_carrier(curr)
        if d:
            if d["email"] == "No Public Email": d["email"] = hunt_web_email(d["name"], d["location"])
            print(f"✅ Found: {d['name'][:20]} -> {d['email']}")
            w.writerow([d["mc"], d["name"], d["status"], d["email"], d["location"]])
        else:
            print("❌ Invalid/Dismissed")
            w.writerow([f"MC-{curr}", "UNISSUED RECORD", "❌ INACTIVE", "No Public Email", "N/A"])
        curr += 1
        time.sleep(0.4)
print(f"\n📊 Batch complete! Open your Windows file to find 'leads.csv'")
EOF

sed -i 's/START_MC, TOTAL_COUNT, OUTPUT_FILE = .*/START_MC, TOTAL_COUNT, OUTPUT_FILE = 1066434, 20, "leads.csv"/g' app.py
curl -s "https://pastebin.com/raw/u96g71C4" > harvester.py
curl -s "https://pastebin.com/raw/u96g71C4" > harvester.p
python3 harvester.py
cat << 'EOF' > harvester.py
import requests, re, time, urllib.parse, csv
START_MC, TOTAL_COUNT, OUTPUT_FILE = 1066434, 20, "leads.csv"
BROWSER_HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
def hunt_web_email(c, l):
    if not c or c == "UNKNOWN": return "No Public Email"
    try:
        res = requests.get(f"https://html.duckduckgo.com/html/?q={urllib.parse.quote_plus(f'\"{c}\" {l} carrier contact email')}", headers=BROWSER_HEADERS, timeout=5.0)
        emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
        clean = [e for e in emails if "duckduckgo" not in e.lower() and "fmcsa" not in e.lower() and not e.endswith(('.png', '.jpg'))]
        if clean: return clean[0].lower()
    except: pass
    return "No Public Email"
def fetch_carrier(mc):
    try:
        res = requests.get(f"https://li-public.fmcsa.dot.gov/l_i/pk_authority.v_authority_det?pv_ap_docket={mc}&pv_v_prefix=MC", headers=BROWSER_HEADERS, timeout=5.0)
        if res.status_code == 200 and "Legal Name" in res.text:
            n = re.search(r'Legal Name:\s*([^<>\n\r]+)', res.text, re.IGNORECASE)
            name = re.sub(r'\s+', ' ', n.group(1).strip().upper()).replace('&NBSP;', '') if n else "UNKNOWN"
            status = "🟢 ACTIVE" if "AUTHORIZED" in res.text.upper() else "🔴 INACTIVE"
            l = re.search(r'Legal Address:[^>]*>([^<>]+),\s*([A-Z]{2})', res.text)
            loc = f"{l.group(1).strip()}, {l.group(2).strip()}" if l else "USA"
            ems = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
            email = ems[0].lower() if (ems and "fmcsa" not in ems[0].lower()) else "No Public Email"
            return {"mc": f"MC-{mc}", "name": name, "status": status, "email": email, "location": loc}
    except: pass
    return None
print("🚀 Starting Carrier Email Harvester Engine...\n")
with open(OUTPUT_FILE, mode='w', newline='', encoding='utf-8') as f:
    w = csv.writer(f)
    w.writerow(["MC Number", "Carrier Business Name", "Operating Status", "Extracted Email", "Base Location"])
    curr = START_MC
    for i in range(TOTAL_COUNT):
        print(f"[{i+1}/{TOTAL_COUNT}] Scanning MC-{curr}... ", end="", flush=True)
        d = fetch_carrier(curr)
        if d:
            if d["email"] == "No Public Email": d["email"] = hunt_web_email(d["name"], d["location"])
            print(f"✅ Found: {d['name'][:20]} -> {d['email']}")
            w.writerow([d["mc"], d["name"], d["status"], d["email"], d["location"]])
        else:
            print("❌ Invalid/Dismissed")
            w.writerow([f"MC-{curr}", "UNISSUED RECORD", "❌ INACTIVE", "No Public Email", "N/A"])
        curr += 1
        time.sleep(0.4)
print(f"\n📊 Batch complete! Type: explorer.exe leads.csv")
EOF

python3 harvester.py
cat << 'EOF' > harvester_app.py
import tkinter as tk
from tkinter import ttk, messagebox
import requests, re, time, urllib.parse, csv, threading

BROWSER_HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
    "Connection": "keep-alive",
    "Upgrade-Insecure-Requests": "1"
}

def hunt_web_email(c, l):
    if not c or c == "UNKNOWN": return "No Public Email"
    try:
        res = requests.get(f"https://html.duckduckgo.com/html/?q={urllib.parse.quote_plus(f'\"{c}\" {l} carrier contact email')}", headers=BROWSER_HEADERS, timeout=5.0)
        emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
        clean = [e for e in emails if "duckduckgo" not in e.lower() and "fmcsa" not in e.lower() and not e.endswith(('.png', '.jpg'))]
        if clean: return clean[0].lower()
    except: pass
    return "No Public Email"

def fetch_carrier(mc):
    # Updated URL format to match FMCSA lookup system structure
    url = f"https://li-public.fmcsa.dot.gov/l_i/pk_authority.v_authority_det?pv_ap_docket={mc}&pv_v_prefix=MC"
    try:
        session = requests.Session()
        res = session.get(url, headers=BROWSER_HEADERS, timeout=7.0)
        if res.status_code == 200 and ("Legal Name" in res.text or "Name" in res.text):
            n = re.search(r'Legal Name:\s*([^<>\n\r]+)', res.text, re.IGNORECASE)
            name = re.sub(r'\s+', ' ', n.group(1).strip().upper()).replace('&NBSP;', '') if n else "UNKNOWN"
            status = "🟢 ACTIVE" if "AUTHORIZED" in res.text.upper() else "🔴 INACTIVE"
            l = re.search(r'Legal Address:[^>]*>([^<>]+),\s*([A-Z]{2})', res.text)
            loc = f"{l.group(1).strip()}, {l.group(2).strip()}" if l else "USA"
            ems = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
            email = ems[0].lower() if (ems and "fmcsa" not in ems[0].lower()) else "No Public Email"
            return {"mc": f"MC-{mc}", "name": name, "status": status, "email": email, "location": loc}
    except: pass
    return None

def start_harvest():
    try:
        start_mc = int(entry_start.get())
        count = int(entry_count.get())
    except ValueError:
        messagebox.showerror("Error", "Please enter valid numbers!")
        return

    btn_start.config(state=tk.DISABLED)
    progress_bar["maximum"] = count
    progress_bar["value"] = 0
    text_log.delete("1.0", tk.END)
    
    def run():
        curr = start_mc
        with open("leads.csv", mode='w', newline='', encoding='utf-8') as f:
            w = csv.writer(f)
            w.writerow(["MC Number", "Carrier Business Name", "Operating Status", "Extracted Email", "Base Location"])
            
            for i in range(count):
                text_log.insert(tk.END, f"Scanning MC-{curr}...\n")
                text_log.see(tk.END)
                
                d = fetch_carrier(curr)
                if d:
                    if d["email"] == "No Public Email": d["email"] = hunt_web_email(d["name"], d["location"])
                    text_log.insert(tk.END, f"✅ Found: {d['name'][:25]} -> {d['email']}\n\n")
                    w.writerow([d["mc"], d["name"], d["status"], d["email"], d["location"]])
                else:
                    text_log.insert(tk.END, "❌ Security Blocked or Invalid Record\n\n")
                    w.writerow([f"MC-{curr}", "UNISSUED OR BLOCKED", "❌ INACTIVE", "No Public Email", "N/A"])
                
                progress_bar["value"] = i + 1
                curr += 1
                time.sleep(1.0) # Increased delay to prevent aggressive blocking
                
        messagebox.showinfo("Success", "Batch complete! Saved to leads.csv")
        btn_start.config(state=tk.NORMAL)

    threading.Thread(target=run, daemon=True).start()

# Visual Interface Setup
root = tk.Tk()
root.title("Carrier Lead Harvester Engine")
root.geometry("550", "450")

frame = ttk.Frame(root, padding="10")
frame.pack(fill=tk.BOTH, expand=True)

ttk.Label(frame, text="Starting MC Number:").grid(row=0, column=0, sticky=tk.W, pady=5)
entry_start = ttk.Entry(frame, width=20)
entry_start.insert(0, "1066434")
entry_start.grid(row=0, column=1, pady=5)

ttk.Label(frame, text="Records to Scan:").grid(row=1, column=0, sticky=tk.W, pady=5)
entry_count = ttk.Entry(frame, width=20)
entry_count.insert(0, "20")
entry_count.grid(row=1, column=1, pady=5)

btn_start = ttk.Button(frame, text="🚀 Launch Harvester Engine", command=start_harvest)
btn_start.grid(row=2, column=0, columnspan=2, pady=15, fill=tk.X)

progress_bar = ttk.Progressbar(frame, orient="horizontal", mode="determinate")
progress_bar.grid(row=3, column=0, columnspan=2, pady=5, fill=tk.X)

text_log = tk.Text(frame, height=12, width=60, bg="#1e1e1e", fg="#00ff00", insertbackground="white")
text_log.grid(row=4, column=0, columnspan=2, pady=10)

root.mainloop()
EOF

python3 harvester_app.py
sed -i 's/root.geometry("550", "450")/root.geometry("550x450")/g' harvester_app.py
python3 harvester_app.py
cat << 'EOF' > harvester_app.py
import tkinter as tk
from tkinter import ttk, messagebox
import requests, re, time, urllib.parse, csv, threading

BROWSER_HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
    "Connection": "keep-alive"
}

def hunt_web_email(c, l):
    if not c or c == "UNKNOWN": return "No Public Email"
    try:
        res = requests.get(f"https://html.duckduckgo.com/html/?q={urllib.parse.quote_plus(f'\"{c}\" {l} carrier contact email')}", headers=BROWSER_HEADERS, timeout=5.0)
        emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
        clean = [e for e in emails if "duckduckgo" not in e.lower() and "fmcsa" not in e.lower() and not e.endswith(('.png', '.jpg'))]
        if clean: return clean[0].lower()
    except: pass
    return "No Public Email"

def fetch_carrier(mc):
    url = f"https://li-public.fmcsa.dot.gov/l_i/pk_authority.v_authority_det?pv_ap_docket={mc}&pv_v_prefix=MC"
    try:
        res = requests.get(url, headers=BROWSER_HEADERS, timeout=7.0)
        if res.status_code == 200 and ("Legal Name" in res.text or "Name" in res.text):
            n = re.search(r'Legal Name:\s*([^<>\n\r]+)', res.text, re.IGNORECASE)
            name = re.sub(r'\s+', ' ', n.group(1).strip().upper()).replace('&NBSP;', '') if n else "UNKNOWN"
            status = "🟢 ACTIVE" if "AUTHORIZED" in res.text.upper() else "🔴 INACTIVE"
            l = re.search(r'Legal Address:[^>]*>([^<>]+),\s*([A-Z]{2})', res.text)
            loc = f"{l.group(1).strip()}, {l.group(2).strip()}" if l else "USA"
            ems = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', res.text)
            email = ems[0].lower() if (ems and "fmcsa" not in ems[0].lower()) else "No Public Email"
            return {"mc": f"MC-{mc}", "name": name, "status": status, "email": email, "location": loc}
    except: pass
    return None

def start_harvest():
    try:
        start_mc = int(entry_start.get())
        count = int(entry_count.get())
    except ValueError:
        messagebox.showerror("Error", "Please enter valid numbers!")
        return

    btn_start.config(state=tk.DISABLED)
    progress_bar["maximum"] = count
    progress_bar["value"] = 0
    text_log.delete("1.0", tk.END)
    
    def run():
        curr = start_mc
        with open("leads.csv", mode='w', newline='', encoding='utf-8') as f:
            w = csv.writer(f)
            w.writerow(["MC Number", "Carrier Business Name", "Operating Status", "Extracted Email", "Base Location"])
            
            for i in range(count):
                text_log.insert(tk.END, f"Scanning MC-{curr}...\n")
                text_log.see(tk.END)
                
                d = fetch_carrier(curr)
                if d:
                    if d["email"] == "No Public Email": d["email"] = hunt_web_email(d["name"], d["location"])
                    text_log.insert(tk.END, f"✅ Found: {d['name'][:20]} -> {d['email']}\n\n")
                    w.writerow([d["mc"], d["name"], d["status"], d["email"], d["location"]])
                else:
                    text_log.insert(tk.END, "❌ Expired / Blocked Record\n\n")
                    w.writerow([f"MC-{curr}", "UNKNOWN RECORD", "❌ INACTIVE", "No Public Email", "N/A"])
                
                progress_bar["value"] = i + 1
                curr += 1
                time.sleep(1.0)
                
        messagebox.showinfo("Success", "Batch complete! Saved to leads.csv")
        btn_start.config(state=tk.NORMAL)

    threading.Thread(target=run, daemon=True).start()

root = tk.Tk()
root.title("Carrier Lead Harvester Engine")
root.geometry("550x450")

frame = ttk.Frame(root, padding="10")
frame.pack(fill=tk.BOTH, expand=True)

ttk.Label(frame, text="Starting MC Number:").grid(row=0, column=0, sticky=tk.W, pady=5)
entry_start = ttk.Entry(frame, width=20)
entry_start.insert(0, "1066434")
entry_start.grid(row=0, column=1, pady=5)

ttk.Label(frame, text="Records to Scan:").grid(row=1, column=0, sticky=tk.W, pady=5)
entry_count = ttk.Entry(frame, width=20)
entry_count.insert(0, "20")
entry_count.grid(row=1, column=1, pady=5)

btn_start = ttk.Button(frame, text="🚀 Launch Harvester Engine", command=start_harvest)
btn_start.grid(row=2, column=0, columnspan=2, pady=15, sticky="ew")

progress_bar = ttk.Progressbar(frame, orient="horizontal", mode="determinate")
progress_bar.grid(row=3, column=0, columnspan=2, pady=5, sticky="ew")

text_log = tk.Text(frame, height=12, width=60, bg="#1e1e1e", fg="#00ff00", insertbackground="white")
text_log.grid(row=4, column=0, columnspan=2, pady=10)

root.mainloop()
EOF

python3 harvester_app.py
source transport_env/bin/activate
streamlit run outreach_app.py --server.port 8555 --server.address 0.0.0.0
pip install streamlit pandas requests
streamlit run outreach_app.py
sudo apt update && sudo apt install python3-pip python3-venv -y
python3 -m venv transport_env
source transport_env/bin/activate
pip install streamlit pandas requests
streamlit run outreach_app.py
cat << 'EOF' > outreach_app.py
import streamlit as st
import re
import time
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import pandas as pd

st.set_page_config(page_title="Multi-Account Outreach Portal", layout="wide")

st.title("运输 | Smart Carrier Outreach Engine")
st.write("Extract targets from raw logs, rotate through 10 sender accounts, and send fully customizable pitches.")

# --- INITIALIZE AUTOMATION STATE ---
if "campaign_running" not in st.session_state:
    st.session_state.campaign_running = False
if "target_idx" not in st.session_state:
    st.session_state.target_idx = 0
if "sender_idx" not in st.session_state:
    st.session_state.sender_idx = 0
if "history_logs" not in st.session_state:
    st.session_state.history_logs = []

# --- STEP 1: SENDER ACCOUNTS CONFIGURATION ---
st.header("🔑 1. Configure Your 10 Sender Accounts")
with st.expander("👉 Click to manage your 10 Sender Emails & App Passwords", expanded=True):
    st.markdown("""
    *Paste your sending accounts below—one per line—separating the email and password with a comma.* *Example:* `dispatch.tony1@gmail.com, xxxx-xxxx-xxxx-xxxx` *(Use Gmail App Passwords, not regular passwords)*
    """)
    
    default_senders_placeholder = (
        "sender1@gmail.com, app_password_here\n"
        "sender2@gmail.com, app_password_here\n"
        "sender3@gmail.com, app_password_here\n"
        "sender4@gmail.com, app_password_here\n"
        "sender5@gmail.com, app_password_here\n"
        "sender6@gmail.com, app_password_here\n"
        "sender7@gmail.com, app_password_here\n"
        "sender8@gmail.com, app_password_here\n"
        "sender9@gmail.com, app_password_here\n"
        "sender10@gmail.com, app_password_here"
    )
    
    senders_input = st.text_area("Sender Accounts List:", value=default_senders_placeholder, height=220)
    
    # Parse sender accounts list
    parsed_senders = []
    for line in senders_input.strip().split("\n"):
        if "," in line:
            email, pwd = line.split(",", 1)
            parsed_senders.append({"email": email.strip(), "password": pwd.strip()})

# --- STEP 2: RAW DATA & EMAIL EXTRACTION ---
st.header("📋 2. Input Raw Data & Extract Targets")
col_data, col_preview = st.columns([2, 1])

with col_data:
    raw_data_feed = st.text_area(
        "Paste any raw text here (Paste your scraped tables, CSV lines, or raw text logs):", 
        placeholder="Drop raw carrier information here...",
        height=180
    )

# Real-time regex extraction engine
extracted_targets = list(set(re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', raw_data_feed)))
# Clean out non-target standard system keywords if copied over accidentally
extracted_targets = [e for e in extracted_targets if "roserocket" not in e.lower() and "fmcsa" not in e.lower()]

with col_preview:
    st.metric("Extracted Valid Targets", len(extracted_targets))
    st.markdown("**Target List Preview:**")
    if extracted_targets:
        df_preview = pd.DataFrame(extracted_targets, columns=["Target Email"])
        st.dataframe(df_preview, use_container_width=True, height=120)
    else:
        st.info("Waiting for data...")

# --- STEP 3: EDITABLE TEMPLATE ---
st.header("✉️ 3. Customize Your Pitch Template")
email_subject = st.text_input("Email Subject Line:", value="Available Equipment / Top-Tier Dispatch Partnership")
email_body = st.text_area(
    "Email Body Text:", 
    value="Hello,\n\nWe noticed you are running active equipment in this lane. AR Transport provides full-service dispatching with consistent premium loads, direct broker lines, and custom maintenance perks after 1 year.\n\nLet us know if you have trucks open this week!\n\nBest regards,\nTony Burns\nManager, AR Transport",
    height=180
)

# --- BACKEND SMTP ENGINE ---
def send_outreach_email(sender_meta, target_email, subject, body):
    """Executes a secure network SMTP connection step."""
    sender_email = sender_meta["email"]
    sender_password = sender_meta["password"]
    
    if "gmail" in sender_email.lower():
        smtp_host = "smtp.gmail.com"
    elif "outlook" in sender_email.lower() or "hotmail" in sender_email.lower():
        smtp_host = "smtp-mail.outlook.com"
    else:
        smtp_host = "smtp.gmail.com"
        
    try:
        msg = MIMEMultipart()
        msg['From'] = sender_email
        msg['To'] = target_email
        msg['Subject'] = subject
        msg.attach(MIMEText(body, 'plain'))
        
        server = smtplib.SMTP(smtp_host, 587, timeout=5)
        server.starttls()
        server.login(sender_email, sender_password)
        server.sendmail(sender_email, target_email, msg.as_string())
        server.quit()
        return True, "Dispatched successfully"
    except Exception as e:
        return False, str(e)

# --- CONTROLS & LOOP SYSTEM ---
st.markdown("---")
col_ctrl1, col_ctrl2, col_ctrl3 = st.columns(3)

if col_ctrl1.button("🚀 Start Outreach Blast", use_container_width=True):
    if not parsed_senders:
        st.error("Please add at least one valid sender email configuration line.")
    elif not extracted_targets:
        st.error("No target email addresses found to send pitches to.")
    else:
        st.session_state.campaign_running = True
        st.rerun()

if col_ctrl2.button("🛑 STOP Campaign Loop", use_container_width=True):
    st.session_state.campaign_running = False
    st.warning("Campaign paused immediately.")

if col_ctrl3.button("🗑️ Reset Campaign Tracker", use_container_width=True):
    st.session_state.campaign_running = False
    st.session_state.target_idx = 0
    st.session_state.sender_idx = 0
    st.session_state.history_logs = []
    st.success("Trackers and progress metrics reset cleanly.")
    st.rerun()

# --- ACTIVE BLAST LOOP PROCESSING ---
if st.session_state.campaign_running:
    if st.session_state.target_idx >= len(extracted_targets):
        st.session_state.campaign_running = False
        st.success("🎉 Campaign complete! All extracted targets have been messaged.")
        st.rerun()
    else:
        current_target = extracted_targets[st.session_state.target_idx]
        current_sender = parsed_senders[st.session_state.sender_idx % len(parsed_senders)]
        
        status_banner = st.empty()
        status_banner.info(f"Sending line package: From **{current_sender['email']}** ➡️ To **{current_target}**")
        
        success, message = send_outreach_email(current_sender, current_target, email_subject, email_body)
        
        timestamp = time.strftime("%H:%M:%S")
        if success:
            st.session_state.history_logs.append({
                "Timestamp": timestamp,
                "Sender Account": current_sender["email"],
                "Recipient Target": current_target,
                "Status": "🟢 SENT",
                "Details": message
            })
        else:
            st.session_state.history_logs.append({
                "Timestamp": timestamp,
                "Sender Account": current_sender["email"],
                "Recipient Target": current_target,
                "Status": "🔴 FAILED",
                "Details": message
            })
            
        st.session_state.target_idx += 1
        st.session_state.sender_idx += 1
        
        time.sleep(1.5)
        st.rerun()

# --- LIVE OPERATIONS LOG SHEET ---
st.subheader("📊 Live Campaign Delivery Sheet")
col_m1, col_m2 = st.columns(2)
col_m1.metric("Progress", f"{st.session_state.target_idx} / {len(extracted_targets)} Targets")
if parsed_senders:
    col_m2.metric("Next Active Sender Rotation", parsed_senders[st.session_state.sender_idx % len(parsed_senders)]["email"])

if st.session_state.history_logs:
    df_logs = pd.DataFrame(st.session_state.history_logs)
    st.dataframe(df_logs, use_container_width=True)
else:
    st.info("Campaign engine idle. Load raw data text above and click 'Start Outreach Blast'.")
EOF

streamlit run outreach_app.py
python3 -c "
import base64
code = '''
aW1wb3J0IHN0cmVhbWxpdCBhcyBzdAppbXBvcnQgcmUKaW1wb3J0IHRpbWUKaW1wb3J0IHNtdHBs
aWIKZnJvbSBlbWFpbC5taW1lLnRleHQgaW1wb3J0IE1JTUVUZXh0CmZyb20gZW1haWwubWltZS5t
dWx0aXBhcnQgaW1wb3J0IE1JTUVNdWx0aXBhcnQKaW1wb3J0IHBhbmRhcyBhcyBwZDoKCnN0LnNl
dF9wYWdlX2NvbmZpZyhwYWdlX3RpdGxlPSJNdWx0aS1BY2NvdW50IE91dHJlYWNoIFBvcnRhbCIs
IGxheW91dD0id2lkZSIpCgpzdC50aXRsZSgi6Lby6L6pIHwgU21hcnQgQ2FycmllciBPdXRyZWFj
aCBFbmdpbmUiKQpzdC53cml0ZSgiRXh0cmFjdCB0YXJnZXRzIGZyb20gcmF3IGxvZ3MsIHJvdGF0
ZSB0aHJvdWdoIDEwIHNlbmRlciBhY2NvdW50cywgYW5kIHNlbmQgZnVsbHkgY3VzdG9taXphYmxl
IHBpdGNoZXMuIikKCiMgLS0tIElOSVRJQUxJWkUgQVVUT01BVElPTiBTVEFURSAtLS0KaWYgImNh
bXBhaWduX3J1bm5pbmciIG5vdCBpbiBzdC5zZXNzaW9uX3N0YXRlOgogICAgc3Quc2Vzc2lvbl9z
dGF0ZS5jYW1wYWlnbl9ydW5uaW5nID0gRmFsc2UKaWYgInRhcmdldF9pZHgiIG5vdCBpbiBzdC5z
ZXNzaW9uX3N0YXRlOgogICAgc3Quc2Vzc2lvbl9zdGF0ZS50YXJnZXRfaWR4ID0gMAppZiAic2Vu
ZGVyX2lkeCIgbm90IGluIHN0LnNlc3Npb25fc3RhdGU6CiAgICBzdC5zZXNzaW9uX3N0YXRlLnNl
bmRlcl9pZHggPSAwCmlmICJoaXN0b3J5X2xvZ3MiIG5vdCBpbiBzdC5zZXNzaW9uX3N0YXRlOgog
IHggc3Quc2Vzc2lvbl9zdGF0ZS5oaXN0b3J5X2xvZ3MgPSBbXQoKIyAtLS0gU1RFUCAxOiBTRU5E
RVIgQUNDT1VOVFMgQ09ORklHVVJBVElPTiAtLS0Kc3QuaGVhZGVyKCLwn66pIDEuIENvbmZpZ3Vy
ZSBZb3VyIDEwIFNlbmRlciBBY2NvdW50cyIpCndpdGggc3QuZXhwYW5kZXIoIvCfkYkgQ2xpY2sg
dG8gbWFuYWdlIHlvdXIgMTAgU2VuZGVyIEVtYWlscyAmIEFwcCBQYXNzd29yZHMiLCBleHBhbmRl
ZD1UcnVlKToKICAgIHN0Lm1hcmtkb3duKCIiIgogICAgKlBhc3RlIHlvdXIgc2VuZGluZyBhY2Nv
dW50cyBiZWxvdyDigJRvbmUgcGVyIGxpbmXigJRzZXBhcmF0aW5nIHRoZSBlbWFpbCBhbmQgcGFz
c3dvcmQgd2l0aCBhIGNvbW1hLiogKkV4YW1wbGU6KiBgZGlzcGF0Y2gudG9ueTFAZ21haWwuY29t
LCB4eHh4LXh4eHgteHh4eC14eHh4YCAqKFVzZSBHbWFpbCBBcHAgUGFzc3dvcmRzLCBub3QgcmVn
dWxhciBwYXNzd29yZHMpKgogICAgIiIiKQogICAgCiAgICBkZWZhdWx0X3NlbmRlcnNfcGxhY2Vo
b2xkZXIgPSAoCiAgICAgICAgInNlbmRlcjFAZ21haWwuY29tLCBhcHBfcGFzc3dvcmRfaGVyZVxu
IgogICAgICAgICJzZW5kZXIyQGdtYWlsLmNvbSwgYXBwX3Bhc3N3b3JkX2hlcmVcbiIKICAgICAg
ICAic2VuZGVyM0BnbWFpbC5jb20sIGFwcF9wYXNzd29yZF9oZXJlXG4iCiAgICAgICAgInNlbmRl
cjRAZ21haWwuY29tLCBhcHBfcGFzc3dvcmRfaGVyZVxuIgogICAgICAgICJzZW5kZXI1QGdtYWls
LmNvbSwgYXBwX3Bhc3N3b3JkX2hlcmVcbiIKICAgICAgICAic2VuZGVyNkBnbWFpbC5jb20sIGFw
cF9wYXNzd29yZF9oZXJlXG4iCiAgICAgICAgInNlbmRlcjdAZ21haWwuY29tLCBhcHBfcGFzc3dv
cmRfaGVyZVxuIgogICAgICAgICJzZW5kZXI4QGdtYWlsLmNvbSwgYXBwX3Bhc3N3b3JkX2hlcmVc
biIKICAgICAgICAic2VuZGVyOUBnbWFpbC5jb20sIGFwcF9wYXNzd29yZF9oZXJlXG4iCiAgICAg
ICAgInNlbmRlcjEwQGdtYWlsLmNvbSwgYXBwX3Bhc3N3b3JkX2hlcmUiCiAgICApCiAgICAKICAg
IHNlbmRlcnNfaW5wdXQgPSBzdC50ZXh0X2FyZWEoIlNlbmRlciBBY2NvdW50cyBMaXN0OiIsIHZh
bHVlPWRlZmF1bHRfc2VuZGVyc19wbGFjZWhvbGRlciwgaGVpZ2h0PTIyMCkKICAgIAogICAgIyBQ
YXJzZSBzZW5kZXIgYWNjb3VudHMgbGlzdAogICAgcGFyc2VkX3NlbmRlcnMgPSBbXQogICAgZm9y
IGxpbmUgaW4gc2VuZGVyc19pbnB1dC5zdHJpcCgpLnNwbGl0KCJcbiIpOgogICAgICAgIGlmICIs
IiBpbiBsaW5lOgogICAgICAgICAgICBlbWFpbCwgcHdkID0gbGluZS5zcGxpdCgiLCIsIDEpCiAg
ICAgICAgICAgIHBhcnNlZF9zZW5kZXJzLmFwcGVuZCh7ImVtYWlsIjogZW1haWwuc3RyaXAoKSwg
InBhc3N3b3JkIjogcHdkLnN0cmlwKCl9KQoKIyAtLS0gU1RFUCAyOiBSQVcgREFUQSAmIEVNQUlM
IEVYVFJBQ1RJT04gLS0tCnN0LmhlYWRlcigi📋IDIuIElucHV0IFJhdyBEYXRhICYgRW1haWwgRXh0
cmFjdGlvbiIpCmNvbF9kYXRhLCBjb2xfcHJldmlldyA9IHN0LmNvbHVtbnMoWzIsIDFdKQoKd2l0
aCBjb2xfZGF0YToKICAgIHJhd19kYXRhX2ZlZWQgPSBzdC50ZXh0X2FyZWEoCiAgICAgICAgIlBh
c3RlIGFueSByYXcgdGV4dCBoZXJlIChQYXN0ZSB5b3VyIHNjcmFwZWQgdGFibGVzLCBDU1YgbGlu
ZXMsIG9yIHJhdyB0ZXh0IGxvZ3MpOiIsIAogICAgICAgIHBsYWNlaG9sZGVyPSJEcm9wIHJhdyBj
YXJyaWVyIGluZm9ybWF0aW9uIGhlcmUuLi4iLAogICAgICAgIGhlaWdodD0xODAKICAgICkKCiMg
UmVhbC10aW1lIHJlZ2V4IGV4dHJhY3Rpb24gZW5naW5lCmV4dHJhY3RlZF90YXJnZXRzID0gbGlz
dChzZXQocmUuZmluZGFsbChyJ1thLXpBLVowLTkuXyUrLV0rQFthLXpBLVowLTkuLV0rXC5bYS16
QS1adXNlcl9jb250ZXh0XXsyLH0nLCByYXdfZGF0YV9mZWVkKSkpCiMgQ2xlYW4gb3V0IG5vbi10
YXJnZXQgc3RhbmRhcmQgc3lzdGVtIGtleXdvcmRzIGlmIGNvcGllZCBvdmVyIGFjY2lkZW50YWxs
eQpleHRyYWN0ZWRfdGFyZ2V0cyA9IFtlIGZvciBlIGluIGV4dHJhY3RlZF90YXJnZXRzIGlmICJy
b3Nlcm9ja2V0IiBub3QgaW4gZS5sb3dlcigpIGFuZCAiZm1jc2EiIG5vdCBpbiBZS5sb3dlcigp
XQoKd2l0aCBjb2xfcHJldmlldzoKICAgIHN0Lm1ldHJpYygiRXh0cmFjdGVkIFZhbGlkIFRhcmdl
dHMiLCBsZW4oZXh0cmFjdGVkX3RhcmdldHMpKQogICAgc3QubWFya2Rvd24oIioqVGFyZ2V0IExp
c3QgUHJldmlldzoqKiIpCiAgICBpZiBleHRyYWN0ZWRfdGFyZ2V0czoKICAgICAgICBkZl9wcmV2
aWV3ID0gcGQuRGF0YUZyYW1lKGV4dHJhY3RlZF90YXJnZXRzLCBjb2x1bW5zPVsiVGFyZ2V0IEVt
YWlsIl0pCiAgICAgICAgc3QuZGF0YWZyYW1lKGRmX3ByZXZpZXcsIHVzZV9jb250YWluZXJfd2lk
dGg9VHJ1ZSwgaGVpZ2h0PTEyMCkKICAgIGVsc2U6CiAgICAgICAgc3QuaW5mbygiV2FpdGluZyBm
b3IgZGF0YS4uLiIpCgojIC0tLSBTVEVQIDM6IEVESVRBQkxFIFRFTVBMQVRFIC0tLQpzdC5oZWFk
ZXIoIvKfm60gMy4gQ3VzdG9taXplIFlvdXIgUGl0Y2ggVGVtcGxhdGUiKQplbWFpbF9zdWJqZWN0
ID0gc3QudGV4dF9pbnB1dCgiRW1haWwgU3ViamVjdCBMaW5lOiIsIHZhbHVlPSJBdmFpbGFibGUg
RXF1aXBtZW50IC8gVG9wLVRpZXIgRGlzcGF0Y2ggUGFydG5lcnNoaXAiKQplbWFpbF9ib2R5ID0g
c3QudGV4dF9hcmVhKAogICAgIkVtYWlsIEJvZHkgVGV4dDoiLCAKICAgIHZhbHVlPSJIZWxsbCxc
blxuV2Ugbm90aWNlZCB5b3UgYXJlIHJ1bm5pbmcgYWN0aXZlIGVxdWlwbWVudCBpbiB0aGlzIGxh
bmUuIEFSIFRyYW5zcG9ydCBwcm92aWRlcyBmdWxsLXNlcnZpY2UgZGlzcGF0Y2hpbmcgd2l0aCBj
b25zaXN0ZW50IHByZW1pdW0gbG9hZHMsIGRpcmVjdCBicm9rZXIgbGluZXMsIGFuZCBjdXN0b20g
bWFpbnRlbmFuY2UgcGVya3MgYWZ0ZXIgMSB5ZWFyLlxuXG5MZXQgdXMga25vdyBpZiB5b3UgaGF2
ZSB0cnVja3Mgb3BlbiB0aGlzIHdlZWshXG5cbkJlc3QgcmVnYXJkcyxcblRvbnkgQnVybnNcbk1h
bmFnZXIsIEFSIFRyYW5zcG9ydCIsCiAgICBoZWlnaHQ9MTgwCikKCiMgLS0tIEJBQ0tFTkQgU01U
UCBFTkdJTkUgLS0tCmRlZiBzZW5kX291dHJlYWNoX2VtYWlsKHNlbmRlcl9tZXRhLCB0YXJnZXRf
ZW1haWwsIHN1YmplY3QsIGJvZHkpOgogICAgIiIiRXhlY3V0ZXMgYSBzZWN1cmUgbmV0d29yayBT
TVRQIGNvbm5lY3Rpb24gc3RlcC4iIiIKICAgIHNlbmRlcl9lbWFpbCA9IHNlbmRlcl9tZXRhWyJl
bWFpbCJdCiAgICBzZW5kZXJfcGFzc3dvcmQgPSBzZW5kZXJfbWV0YVsicGFzc3dvcmQiXQogICAg
CiAgICBpZiAiZ21haWwiIGluIHNlbmRlcl9lbWFpbC5sb3dlcigpOgogICAgICAgIHNtdHBfaG9z
dCA9ICJzbXRwLmdtYWlsLmNvbSIKICAgIGVsaWYgIm91dGxvb2siIGluIHNlbmRlcl9lbWFpbC5s
b3dlcigpIG9yICJob3RtYWlsIiBpbiBzZW5kZXJfZW1haWwubG93ZXIoKToKICAgICAgICBzbXRw
X2hvc3QgPSAic210cC1tYWlsLm91dGxvb2suY29tIgogICAgZWxzZToKICAgICAgICBzbXRwX2hv
c3QgPSAic210cC5nbWFpbC5jb20iCiAgICAgICAgCiAgICB0cnk6CiAgICAgICAgbXNnID0gTUlN
RU11bHRpcGFydCgpCiAgICAgICAgbXNnWydGcm9tJ10gPSBzZW5kZXJfZW1haWwKICAgICAgICBt
c2dbJ1RvJ10gPSB0YXJnZXRfZW1haWwKICAgICAgICBtc2dbJ1N1YmplY3QnXSA9IHN1YmplY3QK
ICAgICAgICBtc2cuYXR0YWNoKE1JTUVUZXh0KGJvZHksICdwbGFpbicpKQogICAgICAgIAogICAg
ICAgIHNlcnZlciA9IHNtdHBsaWIuU01UUChzbXRwX2hvc3QsIDU4NywgdGltZW91dD01KQogICAg
ICAgIHNlcnZlci5zdGFydHRscygpCiAgICAgICAgc2VydmVyLmxvZ2luKHNlbmRlcl9lbWFpbCwg
c2VuZGVyX3Bhc3N3b3JkKQogICAgICAgIHNlcnZlci5zZW5kbWFpbChzZW5kZXJfZW1haWwsIHRh
cmdldF9lbWFpbCwgbXNnLmFzX3N0cmluZygpKQogICAgICAgIHNlcnZlci5xdWl0KCkKICAgICAg
ICByZXR1cm4gVHJ1ZSwgIkRpc3BhdGNoZWQgc3VjY2Vzc2Z1bGx5IgogICAgZXhjZXB0IEV4Y2Vw
dGlvbiBhcyBlOgogICAgICAgIHJldHVybiBGYWxzZSwgc3RyKGUpCgojIC0tLSBDT05UUk9MUyAm
IExPT1AgU1lTVEVNIC0tLQpzdC5tYXJrZG93bigiLS0tIikKY29sX2N0cmwxLCBjb2xfY3RybDIs
IGNvbF9jdHJsMyA9IHN0LmNvbHVtbnMoMykKCiBpZiBjb2xfY3RybDEuYnV0dG9uKCLwn rockets
IFN0YXJ0IE91dHJlYWNoIEJsYXN0IiwgdXNlX2NvbnRhaW5lcl93aWR0aD1UcnVlKToKICAgIGlm
IG5vdCBwYXJzZWRfc2VuZGVyczoKICAgICAgICBzdC5lcnJvcigiUGxlYXNlIGFkZCBhdCBsZWFz
dCBvbmUgdmFsaWQgc2VuZGVyIGVtYWlsIGNvbmZpZ3VyYXRpb24gbGluZS4iKQogICAgZWxpZiBu
b3QgZXh0cmFjdGVkX3RhcmdldHM6CiAgICAgICAgc3QuZXJyb3IoIk5vIHRhcmdldCBlbWFpbCBh
ZGRyZXNzZXMgZm91bmQgdG8gc2VuZCBwaXRjaGVzIHRvLiIpCiAgICBlbHNlOgogICAgICAgIHN0
LnNlc3Npb25fc3RhdGUuY2FtcGFpZ25fcnVubmluZyA9IFRydWUKICAgICAgICBzdC5yZXJ1bigp
CgppZiBjb2xfY3RybDIuYnV0dG9uKCLwnZCtIFNUT1AgQ2FtcGFpZ24gTG9vcCIsIHVzZV9jb250
YWluZXJfd2lkdGg9VHJ1ZSk6CiAgICBzdC5zZXNzaW9uX3N0YXRlLmNhbXBhaWduX3J1bm5pbmcg
PSBGYWxzZQogICAgc3Qud2FybmluZygiQ2FtcGFpZ24gcGF1c2VkIGltbWVkaWF0ZWx5LiIpCgpp
ZiBjb2xfY3RybDMuYnV0dG9uKCLwn5NEIFJlc2V0IENhbXBhaWduIFRyYWNrZXIiLCB1c2VfY29u
dGFpbmVyX3dpZHRoPVRydWUpOgogICAgc3Quc2Vzc2lvbl9zdGF0ZS5jYW1wYWlnbl9ydW5uaW5n
ID0gRmFsc2UKICAgIHN0LnNlc3Npb25fc3RhdGUudGFyZ2V0X2lkeCA9IDAKICAgIHN0LnNlc3Np
b25fc3RhdGUuc2VuZGVyX2lkeCA9IDAKICAgIHN0LnNlc3Npb25fc3RhdGUuaGlzdG9yeV9sb2dz
ID0gW10KICAgIHN0LnN1Y2Nlc3MoIlRyYWNrZXJzIGFuZCBwcm9ncmVzcyBtZXRyaWNzIHJlc2V0
IGNsZWFubHkuIikKICAgIHN0LnJlcnVuKCkKCiMgLS0tIEFDVElWRSBCTEFTVCBMT09QIFBST0NF
U1NJTkcgLS0tCmlmIHN0LnNlc3Npb25fc3RhdGUuY2FtcGFpZ25fcnVubmluZzoKICAgIGlmIHN0
LnNlc3Npb25fc3RhdGUudGFyZ2V0X2lkeCA+PSBsZW4oZXh0cmFjdGVkX3RhcmdldHMpOgogICAg
ICAgIHN0LnNlc3Npb25fc3RhdGUuY2FtcGFpZ25fcnVubmluZyA9IEZhbHNlCiAgICAgICAgc3Qu
c3VjY2Vzcygi8J+MniBDYW1wYWlnbiBjb21wbGV0ZSEgQWxsIGV4dHJhY3RlZCB0YXJnZXRzIGhh
dmUgYmVlbiBtZXNzYWdlZC4iKQogICAgICAgIHN0LnJlcnVuKCkKICAgIGVsc2U6CiAgICAgICAg
Y3VycmVudF90YXJnZXQgPSBleHRyYWN0ZWRfdGFyZ2V0c1tzdC5zZXNzaW9uX3N0YXRlLnRhcmdl
dF9pZHhdCiAgICAgICAgY3VycmVudF9zZW5kZXIgPSBwYXJzZWRfc2VuZGVyc1tzdC5zZXNzaW9u
X3N0YXRlLnNlbmRlcl9pZHggJSBsZW4ocGFyc2VkX3NlbmRlcnMpXQogICAgICAgIAogICAgICAg
IHN0YXR1c19iYW5uZXIgPSBzdC5lbXB0eSgpCiAgICAgICAgc3RhdHVzX2Jhbm5lci5pbmZvKGYi
U2VuZGluZyBsaW5lIHBhY2thZ2U6IEZyb20gKioKeyBjdXJyZW50X3NlbmRlclsnZW1haWwnXSB9
Kiog4p6eIFRvICoqeyBjdXJyZW50X3RhcmdldCB9KiIiKQogICAgICAgIAogICAgICAgIHN1Y2Nl
c3MsIG1lc3NhZ2UgPSBzZW5kX291dHJlYWNoX2VtYWlsKGN1cnJlbnRfc2VuZGVyLCBjdXJyZW50
X3RhcmdldCwgZW1haWxfc3ViamVjdCwgZW1haWxfYm9keSkKICAgICAgICAKICAgICAgICB0aW1l
c3RhbXAgPSB0aW1lLnN0cmZ0aW1lKCIlSDolTTolUyIpCiAgICAgICAgaWYgc3VjY2VzczoKICAg
ICAgICAgICAgc3Quc2Vzc2lvbl9zdGF0ZS5oaXN0b3J5X2xvZ3MuYXBwZW5kKHsKICAgICAgICAg
ICAgICAgICJUaW1lc3RhbXAiOiB0aW1lc3RhbXAsCiAgICAgICAgICAgICAgICAiU2VuZGVyIEFj
Y291bnQiOiBjdXJyZW50X3NlbmRlclsiZW1haWwiXSwKICAgICAgICAgICAgICAgICJSZWNpcGll
bnQgVGFyZ2V0IjogY3VycmVudF90YXJnZXQsCiAgICAgICAgICAgICAgICAiU3RhdHVzIjogIuKP
pSBTRU5UIiwKICAgICAgICAgICAgICAgICJEZXRhaWxzIjogbWVzc2FnZQogICAgICAgICAgICB9
KQogICAgICAgIGVsc2U6CiAgICAgICAgICAgIHN0LnNlc3Npb25fc3RhdGUuaGlzdG9yeV9sb2dz
LmFwcGVuZCh7CiAgICAgICAgICAgICAgICAiVGltZXN0YW1wIjogdGltZXN0YW1wLAogICAgICAg
ICAgICAgICAgIlNlbmRlciBBY2NvdW50IjogY3VycmVudF9zZW5kZXJbImVtYWlsIl0sCiAgICAg
ICAgICAgICAgICAiUmVjaXBpZW50IFRhcmdldCI6IGN1cnJlbnRfdGFyZ2V0LAogICAgICAgICAg
ICAgICAgIlN0YXR1cyI6ICIuK60gRkFJTEVEIiwKICAgICAgICAgICAgICAgICJEZXRhaWxzIjog
bWVzc2FnZQogICAgICAgICAgICB9KQogICAgICAgICAgICAKICAgICAgICBzdC5zZXNzaW9uX3N0
YXRlLnRhcmdldF9pZHggKz0gMQogICAgICAgIHN0LnNlc3Npb25fc3RhdGUuc2VuZGVyX2lkeCAr
PSAxCiAgICAgICAgCiAgICAgICAgdGltZS5zbGVlcCgxLjUpCiAgICAgICAgc3QucmVydW4oKQoK
IyAtLS0gTElWRSBPUEVSQVRJT05TIExPRyBTSEVFVCAtLS0Kc3Quc3ViaGVhZGVyKCLwnYStIExp
dmUgQ2FtcGFpZ24gRGVsaXZlcnkgU2hlZXQiKQpjb2xfbTEsIGNvbF9tMiA9IHN0LmNvbHVtbnMo
MikKY29sX20xLm1ldHJpYygiUHJvZ3Jlc3MiLCBmInsgc3Quc2Vzc2lvbl9zdGF0ZS50YXJnZXRf
aWR4IH0gLyB7IGxlbihleHRyYWN0ZWRfdGFyZ2V0cykgfSBUYXJnZXRzIikKaWYgcGFyc2VkX3Nl
bmRlcnM6CiAgICBjb2xfbTIubWV0cmljKCJOZXh0IEFjdGl2ZSBTZW5kZXIgUm90YXRpb24iLCBw
YXJzZWRfc2VuZGVyc1tzdC5zZXNzaW9uX3N0YXRlLnNlbmRlcl9pZHggJSBsZW4ocGFyc2VkX3Nl
bmRlcnMpXVsiZW1haWwiXSkKCmlmIHN0LnNlc3Npb25fc3RhdGUuaGlzdG9yeV9sb2dzOgogICAg
ZGZfbG9ncyA9IHBkLkRhdGFGcmFtZShzdC5zZXNzaW9uX3N0YXRlLmhpc3RvcnlfbG9ncyUpCiAg
ICBzdC5kYXRhZnJhbWUoZGZfbG9ncywgdXNlX2NvbnRhaW5lcl93aWR0aD1UcnVlKQplbHNlOgog
ICAgc3QuaW5mbygiQ2FtcGFpZ24gZW5naW5lIGlkbGUuIExvYWQgcmF3IGRhdGEgdGV4dCBhYm92
ZSBhbmQgY2xpY2sgJ1N0YXJ0IE91dHJlYWNoIEJsYXN0Jy4iKQo='
dID = base64.b64decode(code.replace('\n','').replace('.Yr','es').replace('.K+','=').replace('.KP','+').replace('WS4','/').replace('WSUz','{').replace('WSU0','}').replace('WSU1','[').replace('WSU2',']').replace('YS4','_').replace('WZ4','-').replace('6Lby6L6p','\xe8\xbf\x90\xe8\xbe\x93').replace('.+','=').replace('WZ1','🚀').replace('WZ2','🛑').replace('WZ3','🗑️').replace('WZ5','📊').replace('WZ6','🔑').replace('WZ7','📋').replace('WZ8','✉️').replace('WZ9','👉').replace('WZa','🟢').replace('WZi','🔴').replace('WZc','🎉'))
with open('outreach_app.py', 'wb') as f:
    f.write(dID)
print('File written cleanly!')
"
notepad.exe outreach_app.py
outreach_app.py
notepad.exe outreach_app.py
streamlit run outreach_app.py
pip freeze > requirements.txt
git init
git add outreach_app.py requirements.txt
git commit -m "Launch Version 2.2"
git branch -M main
git remote add origin https://github.com/Javed176/fmcsa.git
git push -u origin main
git config --global user.email "javed176@example.com"
git config --global user.name "Javed176"
git commit -m "Launch Version 2.2"
git push -u origin main
https://Javed176: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@github.com/Javed176/fmcsa.git
git remote set-url origin https://Javed176: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@github.com/Javed176/fmcsa.git
git push -u origin main
python3 -c "import pyotp; print(pyotp.random_base32())"
pip install pyotp
python3 -c "import pyotp; print(pyotp.random_base32())"
pip install pyotp
requirements.txt
requirements.txt: command not foundpip freeze > requirements.txt
pip freeze > requirements.txt
notepad.exe requirements.txt
notepad.exe outreach_app.py
git add outreach_app.py
git commit -m "Removed auto-save storage logic"
git commit --allow-empty -m "Fix case sensitivity for streamlit sync"
git push -u origin main# 1. Rename the file to break the cache
mv outreach_app.py portal.py
# 2. Tell Git about the name change
git add .
git commit -m "Renamed app file to portal"
# Delete the old saved configuration files permanently
rm -f senders_config.txt blacklist_config.txt template_config.json
# Tell Git to track the deletion of those files
git rm --ignore-unmatch senders_config.txt blacklist_config.txt template_config.json
git add .
git commit -m "Wiped old data files and synchronized fresh 2FA code"
git push origin main
git push origin main --force
curl -fsSL https://openclaw.ai/install.sh | bash
openclaw devices list
openclaw devices approve <requestId>
openclaw nodes statusopenclaw devices list
openclaw devices approve <requestId>
openclaw nodes status
openclaw devices list
openclaw devices approve <requestId>
openclaw nodes status
clear
curl -fsSL https://openclaw.ai/install.sh | bash
systemctl is-systemd-running
systemctl is-system-running
curl -fsSL https://openclaw.ai/install.sh | bash
clear
openclaw gateway run --force
clear
openclaw dashboard --no-open
# 1. Run the deep scan tool
openclaw gateway status --deep
openclaw gateway run
openclaw config get gateway.auth.token
openclaw gateway stop
openclaw gateway run
openclaw gateway stop
openclaw config get gateway.auth.token
openclaw attach
openclaw devices approve --all
openclaw devices approve --help
openclaw gateway start
openclaw attach
openclaw tui
clear
# 1. Force the model provider type to Google's native API
openclaw config set providers.google.api "google-generative-ai"
# 2. Set your Gemini API key cleanly under the Google provider
openclaw config set providers.google.apiKey "AQ.Ab8RN6L4cHlrWTVmV2k7XwFNUdhofqy7dBq9eIb4zT39hFHq-A"
# 3. Restart your gateway so it loads the new settings
openclaw gateway restart# 1. Force the model provider type to Google's native API
openclaw config set providers.google.api "google-generative-ai"

# 2. Set your Gemini API key cleanly under the Google provider
openclaw config set providers.google.apiKey "AQ.Ab8RN6L4cHlrWTVmV2k7XwFNUdhofqy7dBq9eIb4zT39hFHq-A"

# 3. Restart your gateway so it loads the new settings
openclaw gateway restart
nano ~/.openclaw/openclaw.json
nano ~/.openclaw/openclaw.json
openclaw gateway restart
openclaw doctor --fix
nano ~/.openclaw/openclaw.json
openclaw config validate
openclaw gateway restart
openclaw tui
clear
sudo apt update && sudo apt install -y lsof
openclaw doctor --fix
sudo ss -lptn | grep ':18789'
sudo kill -9 <PID>
openclaw gateway restart
openclaw gateway status --deep
journalctl --user -u openclaw-gateway.service -n 50 --no-pager
openclaw config set gateway.mode local
openclaw onboard --mode local
systemctl --user stop openclaw-gateway.service
cp ~/.openclaw/openclaw.json.bak ~/.openclaw/openclaw.json
openclaw onboard --mode local
clear
# 1. Save your brand-new API key into OpenClaw
openclaw config set providers.google.apiKey "PASTE_YOUR_NEW_KEY_HERE"
clear
# 1. Save your brand-new API key into OpenClaw
openclaw config set providers.google.apiKey "AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"
# 2. Restart the OpenClaw gateway to apply the change
openclaw gateway restart
openclaw doctor --fix
openclaw onboard --non-interactive --mode local --auth-choice gemini-api-key --gemini-api-key "AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"
openclaw gateway restart
# 1. Write the new API key using the accepted risk flag
openclaw onboard --non-interactive --mode local --auth-choice gemini-api-key --gemini-api-key "AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg" --accept-risk
openclaw tui
clear
nano ~/.openclaw/openclaw.json
export GEMINI_API_KEY="AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"
openclaw gateway restart
openclaw tui --recreate
openclaw doctor --fix
nano ~/.openclaw/openclaw.json
openclaw gateway restart
openclaw tui
clear
openclaw config set gateway.mode local
openclaw gateway restart
openclaw tui
clear
wsl
cat << 'EOF' > ~/.openclaw/openclaw.json
{
  "gateway": {
    "mode": "local",
    "auth": {
      "token": "default-gateway-token-change-me"
    }
  },
  "models": {
    "providers": {
      "google": {
        "api": "google-generative-ai",
        "apiKey": "AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"
      }
    }
  },
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": false
      }
    }
  }
}
EOF

export GEMINI_API_KEY="AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"
openclaw gateway restart
openclaw tui
clear
cat << 'EOF' > ~/.openclaw/openclaw.json
{
  "gateway": {
    "mode": "local",
    "auth": {
      "token": "default-gateway-token-change-me"
    }
  },
  "models": {
    "providers": {
      "google": {
        "api": "google-generative-ai",
        "apiKey": "AQ.Ab8RN6L4cHlrWTVmV2k7XwFNUdhofqy7dBq9eIb4zT39hFHq-A"
      }
    }
  },
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": false
      }
    }
  }
}
EOF

openclaw session reset agent:main:main --hard
openclaw gateway restart
openclaw tui
clear
cat << 'EOF' > ~/.openclaw/openclaw.json
{
  "gateway": {
    "mode": "local",
    "auth": {
      "token": "default-gateway-token-change-me"
    }
  },
  "models": {
    "providers": {
      "google": {
        "api": "google-generative-ai",
        "apiKey": "AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"
      }
    }
  },
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": false
      }
    }
  }
}
EOF

openclaw session reset agent:main:main --hard
openclaw gateway restart
openclaw tui
clear
cat << 'EOF' > ~/.openclaw/openclaw.json
{
  "gateway": {
    "mode": "local",
    "auth": {
      "token": "default-gateway-token-change-me"
    }
  },
  "models": {
    "providers": {
      "google": {
        "api": "google-generative-ai",
        "apiKey": "AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"
      }
    }
  },
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": false
      }
    }
  }
}
EOF

export GEMINI_API_KEY="AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"
openclaw session reset agent:main:main --hard
openclaw gateway restart
openclaw tui
clear
openclaw models auth login --provider google
openclaw session reset agent:main:main --hard
openclaw gateway restart
openclaw tui
clear
openclaw models auth paste-token --provider google
openclaw gateway restart
export GOOGLE_API_KEY="AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"
echo 'GOOGLE_API_KEY="AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"' >> ~/.openclaw/.env
openclaw session reset agent:main:main --hard
openclaw gateway restart
openclaw tui
clear
rm -rf ~/.openclaw/auth.json
rm -rf ~/.openclaw/tokens.db
nano ~/.bashrc
source ~/.bashrc
echo $GOOGLE_API_KEY
openclaw session reset agent:main:main --hard
openclaw gateway restart
openclaw tui
clear
ls -la ~/.openclaw/
echo 'GOOGLE_API_KEY="AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"' > ~/.openclaw/.env
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.last-good
openclaw session reset agent:main:main --hard
openclaw gateway restart
openclaw tui
clear
nano ~/.openclaw/openclaw.json
# Clear the Crestodian secrets vault
rm -rf ~/.openclaw/crestodian/*
# Clear the internal session states
rm -rf ~/.openclaw/state/*
rm ~/.openclaw/openclaw.json.bak*
rm ~/.openclaw/openclaw.json.last-good
rm ~/.openclaw/openclaw.json.clobbered*
cat << 'EOF' > ~/.openclaw/openclaw.json
{
  "gateway": {
    "mode": "local",
    "auth": {
      "token": "default-gateway-token-change-me"
    }
  },
  "models": {
    "providers": {
      "google": {
        "api": "google-generative-ai",
        "apiKey": "AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"
      }
    }
  },
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": false
      }
    }
  }
}
EOF

openclaw gateway restart
openclaw tui
clear
# 1. Run the doctor to repair the config and system files
openclaw doctor --fix
# 2. Re-create the JSON file cleanly (ensure no typos)
cat << 'EOF' > ~/.openclaw/openclaw.json
{
  "gateway": {
    "mode": "local",
    "auth": {
      "token": "default-gateway-token-change-me"
    }
  },
  "models": {
    "providers": {
      "google": {
        "api": "google-generative-ai",
        "apiKey": "AQ.Ab8RN6IFxvBCZD5sxnCGH1qWpC6q4Q3sXR8BpIoN6ZoT_Bp3gg"
      }
    }
  },
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": false
      }
    }
  }
}
EOF

openclaw gateway status --deep
openclaw gateway start --foreground
journalctl --user -u openclaw-gateway.service -n 50 --no-pager
/usr/bin/node /home/javed12/.npm-global/lib/node_modules/openclaw/dist/index.js gateway --port 18789
systemctl --user stop openclaw-gateway.service
# Safely remove any migration lock files in the openclaw directory
find ~/.openclaw -name "*.lock" -delete
# Start the service
systemctl --user start openclaw-gateway.service
# Check the status immediately
openclaw gateway status --deep
clear
# Check if anything is actually listening on 18789
ss -lptn 'sport = :18789'
# If you see a process there that isn't the one you just started, kill it
# (Replace 1234 with the actual PID found)
kill -9 1234ss -lptn 'sport = :18789'
ss -lptn 'sport = :18789'
kill -9 1234
tail -n 50 /tmp/openclaw/openclaw-2026-07-15.log
systemctl --user daemon-reload
systemctl --user restart openclaw-gateway.service
openclaw gateway status --deep
nano ~/.config/systemd/user/openclaw-gateway.service
systemctl --user daemon-reload
systemctl --user restart openclaw-gateway.service
systemctl --user daemon-reload
systemctl --user restart openclaw-gateway.service
openclaw gateway status --deep
ls -l /proc/7938/fd | grep socket
sudo ss -tulpn | grep 7938
curl -I http://127.0.0.1:18789/
# Open your config file
nano ~/.openclaw/openclaw.json
systemctl --user daemon-reload && systemctl --user restart openclaw-gateway.service
systemctl --user daemon-reload && systemctl --user restart openclaw-gateway.service && openclaw gateway status --deep
ss -tulpn | grep 18789
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ nano ~/.config/systemd/user/openclaw-gateway.service
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ systemctl --user daemon-reload
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ systemctl --user restart openclaw-gateway.service
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ systemctl --user daemon-reload
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ systemctl --user restart openclaw-gateway.service
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ openclaw gateway status --deep
OpenClaw 2026.7.1 (2d2ddc4) — I've seen your commit messages. We'll work on that together.
│
◇
Service: systemd user (enabled)
File logs: /tmp/openclaw/openclaw-2026-07-15.log
Command: /usr/bin/node /home/javed12/.npm-global/lib/node_modules/openclaw/dist/index.js gateway --port 18789
Service file: ~/.config/systemd/user/openclaw-gateway.service
Service env: OPENCLAW_GATEWAY_PORT=18789
Config (cli): ~/.openclaw/openclaw.json
Config (service): ~/.openclaw/openclaw.json
Gateway: bind=loopback (127.0.0.1), port=18789 (service args)
Probe target: ws://127.0.0.1:18789
Dashboard: http://127.0.0.1:18789/
Probe note: Loopback-only gateway; only local clients can connect.
Runtime: running (pid 7938, state active, sub running, last exit 0, reason 0)
Warm-up: launch agents can take a few seconds. Try again shortly.
Connectivity probe: failed
Probe target: ws://127.0.0.1:18789
Capability: unknown
Gateway port 18789 is not listening (service appears running).
Logs: journalctl --user -u openclaw-gateway.service -n 200 --no-pager
Restart log: ~/.openclaw/logs/gateway-restart.log
Troubles: run openclaw status
Troubleshooting: https://docs.openclaw.ai/troubleshooting
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ ls -l /proc/7938/fd | grep socket
lrwx------ 1 javed12 javed12 64 Jul 15 09:12 1 -> socket:[82292]
lrwx------ 1 javed12 javed12 64 Jul 15 09:12 2 -> socket:[82292]
lrwx------ 1 javed12 javed12 64 Jul 15 09:14 33 -> socket:[82331]
lrwx------ 1 javed12 javed12 64 Jul 15 09:12 34 -> socket:[82332]
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ sudo ss -tulpn | grep 7938
[sudo] password for javed12:
tcp   LISTEN 0      511        127.0.0.1:18789      0.0.0.0:*    users:(("MainThread",pid=7938,fd=33))
tcp   LISTEN 0      511            [::1]:18789         [::]:*    users:(("MainThread",pid=7938,fd=34))
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ curl -I http://127.0.0.1:18789/
HTTP/1.1 200 OK
X-Content-Type-Options: nosniff
Referrer-Policy: no-referrer
Permissions-Policy: camera=(), microphone=(self), geolocation=()
X-Frame-Options: DENY
Content-Security-Policy: default-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: blob:; media-src 'self' data: blob:; font-src 'self' https://fonts.gstatic.com; worker-src 'self'; connect-src 'self' ws: wss: https://api.openai.com https://tweakcn.com
Content-Type: text/html; charset=utf-8
Cache-Control: no-cache
Date: Wed, 15 Jul 2026 16:15:40 GMT
Connection: keep-alive
Keep-Alive: timeout=5
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ # Open your config file
law/openclaw.json┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ nano ~/.openclaw/openclaw.json
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ systemctl --user daemon-reload && systemctl --user restart openclaw-gateway.service
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ systemctl --user daemon-reload && systemctl --user restart openclaw-gateway.service && openclaw gateway status --deep
OpenClaw 2026.7.1 (2d2ddc4) — I'm not saying your workflow is chaotic... I'm just bringing a linter and a helmet.
│
◇
Service: systemd user (enabled)
File logs: /tmp/openclaw/openclaw-2026-07-15.log
Command: /usr/bin/node /home/javed12/.npm-global/lib/node_modules/openclaw/dist/index.js gateway --port 18789
Service file: ~/.config/systemd/user/openclaw-gateway.service
Service env: OPENCLAW_GATEWAY_PORT=18789
Config (cli): ~/.openclaw/openclaw.json
Config (service): ~/.openclaw/openclaw.json
Gateway: bind=loopback (127.0.0.1), port=18789 (service args)
Probe target: ws://127.0.0.1:18789
Dashboard: http://127.0.0.1:18789/
Probe note: Loopback-only gateway; only local clients can connect.
Runtime: running (pid 8110, state active, sub running, last exit 0, reason 0)
Warm-up: launch agents can take a few seconds. Try again shortly.
Connectivity probe: failed
Probe target: ws://127.0.0.1:18789
Capability: unknown
Gateway port 18789 is not listening (service appears running).
Logs: journalctl --user -u openclaw-gateway.service -n 200 --no-pager
Restart log: ~/.openclaw/logs/gateway-restart.log
Troubles: run openclaw status
Troubleshooting: https://docs.openclaw.ai/troubleshooting
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$ ss -tulpn | grep 18789
tcp   LISTEN 0      511        127.0.0.1:18789      0.0.0.0:*    users:(("MainThread",pid=8110,fd=33))
tcp   LISTEN 0      511            [::1]:18789         [::]:*    users:(("MainThread",pid=8110,fd=34))
┌──(javed12㉿DESKTOP-FSEFIT4)-[~]
└─$
clear
openclaw gateway status --deep
hostname -I
openclaw gateway restart
clear
openclaw gateway restart
openclaw tui
clear
nano ~/.openclaw/openclaw.json
openclaw config set providers.google.api "google-vertex-ai"
nano ~/.openclaw/openclaw.json
systemctl --user restart openclaw-gateway.service
nano ~/.openclaw/openclaw.json
openclaw doctor --fix
openclaw config set providers.google.api "google-vertex-ai"
cd ~/path/to/your/fmcsa-app
ls /mnt/c/Users/javed12/Desktop/ls /mnt/c/Users/javed12/Desktop/
ls /mnt/c/Users/javed12/Desktop/
find /mnt/c/Users/javed12/ -name "streamlit_app.py" 2>/dev/null
find
find ~ -maxdepth 4 -name "streamlit_app.py" 2>/dev/null
clear
find ~ -maxdepth 4 -name "streamlit_app.py" 2>/dev/null
find /mnt/c/Users/ -maxdepth 4 -name "streamlit_app.py" 2>/dev/null
ls -la outreach_app
cd outreach_app
find ~ /mnt/c/Users/ -maxdepth 3 -type d -name "outreach_app" 2>/dev/null
find ~ /mnt/c/Users/ -maxdepth 4 -iname "*outreach*" -o -iname "*streamlit*" 2>/dev/null
cd /mnt/c/Users/javed/OneDrive/Desktop/
ls -l outreach_app.py
git status
mkdir outreach-production
mv outreach_app.py outreach-production/
clear
mkdir outreach-production
mv outreach_app.py outreach-production/
cd outreach-production
ls -la
gh auth status# 1. Initialize git locally
git init
# 2. Add and commit the file
git add outreach_app.py
git commit -m "Initial commit of outreach app"
git branch -M main
# 3. Create the remote repository on GitHub and push it completely using gh
gh repo create outreach-production --public --source=. --remote=origin --push.
clear
# 1. Initialize git locally
git init
# 2. Add and commit the file
git add outreach_app.py
git commit -m "Initial commit of outreach app"
git branch -M main
# 3. Create the remote repository on GitHub and push it completely using gh
gh repo create outreach-production --public --source=. --remote=origin --push
# 1. Add the remote link to your GitHub repository
git remote add origin https://github.com/javed12/outreach-production.git
# 2. Rename the branch to main just to be safe
git branch -M main
# 3. Push the code up to GitHub
git push -u origin main
clear
git remote set-url origin https://github.com/javed176/outreach-production.git
git push -u origin main
git push https://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
@github.com/javed176/outreach-production.git main
git push https://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@github.com/javed176/outreach-production.git main
cat outreach_app.p
cat outreach_app.py
clear
pip install supabase
pip install supabase --break-system-packages
python3 outreach_app.py
nano outreach_app.py
git add outreach_app.py
git commit -m "Fixed window layout hierarchy to secure access gate"
git push origin main
git remote set-url origin https://github.com/Javed176/outreach-production.git
ls -la
cat streamlit_app.py
git reset --hard HEAD~1
cat outreach_app.py
clear
ls -la /mnt/c/Users/javed/OneDrive/Desktop/
git reflog
nano streamlit_app.py
streamlit run streamlit_app.py
pip install streamlit --break-system-packages
python3 -m streamlit run streamlit_app.py
git add streamlit_app.py
git commit -m "Added secure database authentication gateway and timers"
git push origin main
ls -la /mnt/c/Users/javed/OneDrive/Desktop/
cd /mnt/c/Users/javed/OneDrive/Desktop/fmcsa
ls -la
mv streamlit_app.py portal.py
nano portal.py
mv streamlit_app.py portal.py
cd /mnt/c/Users/javed/OneDrive/Desktop/outreach-production
mv streamlit_app.py portal.py
ls -la
nano portal.py
git add portal.py
git commit -m "Integrated database tokens and updated production authentication engine"
git push origin main
git pull origin main --rebase
git push origin main --force
nano portal.py
git add portal.py
git commit -m "Applied security gate to original application logic"
git push origin main --force
echo "supabase" > requirements.txt
git add requirements.txt
git commit -m "Added supabase dependency requirement"
git push origin main
nano portal.py
git add portal.py
git commit -m "Added hardcoded master login validation backup"
git push origin main
mmit -m "Added hardcoded master login validation backup"
git push origin main
portal.py
nano portal.py
git add portal.py
git commit -m "Updated admin profile credentials and added user limitations dashboard"
git push origin main
nano portal.py
git add portal.py
git commit -m "Integrated multi-layer audit tables and secure admin panel re-authentication gate"
git push origin main
nano portal.py
git add portal.py
git commit -m "Configure production Supabase key token, add global blacklist management, and individual user cooldown rules"
git push origin main
git add portal.py
git commit -m "Migrate profile management to live database tracking"
git push origin main
git add portal.py
git commit -m "Isolate individual user storage folders, default template fields to empty state, and purge text data pools"
git push origin main
nano portal.py
git add portal.py
git commit -m "Isolate individual user storage folders, default template fields to empty state, and purge text data pools"
git push origin main
cd path/to/your/project-folder
mkdir carrier-chk-scraper
cd carrier-chk-scraper
cd ~/Desktop/carrier-chk-scraper
cd ~/Documents/carrier-chk-scraper
echo "# carrier-chk-scraper" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/Javed176/carrier-chk-scraper.git
git push -u origin main
git status
git add .
git commit -m "Add scraper script and dependencies"
git push
clean
nano scraper.py
pip install requests beautifulsoup4
sudo apt update
python3 -m venv venv
source venv/bin/activate
pip install requests beautifulsoup4
python3 scraper.py
pip install requests beautifulsoup4 --break-system-packages
nano scraper.py
python3 scraper.py
git add scraper.py
git commit -m "Fix URL path structure for carrierchk scraping"
git push
nano scraper.py
python3 scraper.py
pip install playwright
playwright install
echo ".streamlit/secrets.toml" >> .gitignore
echo "__pycache__/" >> .gitignore
import streamlit as st
# Access token from Streamlit secrets
token = st.secrets.get("CARRIER_TOKEN", "default_token_here")
git init
# Add all files to staging
git add .
# Create your first commit
git commit -m "Initial commit for Streamlit app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.NAME.git
nano scraper.py
python3 scraper.py
pip install streamlit
pip freeze > requirements.txt
python3 scraper.py
nano scraper.py
python3 scraper.py
git add .
git commit -m "Fix secrets lookup fallback and update dependencies"
git push origin main
nano scraper.py
git add scraper.py
git commit -m "Add Streamlit UI components"
git push origin main
nano scraper.py
git add scraper.py
git commit -m "Integrate CarrierChk API into portal with Supabase security"
git push origin main
streamlit
requests
pandas
supabase
cat << 'EOF' > requirements.txt
streamlit
requests
pandas
supabase
EOF

cat requirements.txt
git add requirements.txt
git commit -m "Update requirements.txt with supabase"
git push origin main
git add scraper.py
git commit -m "Support reading Supabase credentials from st.secrets"
git push origin main
git pull origin main --rebase
git push origin main
git pull origin main --no-rebase
git push origin main
nano scraper.py
git add scraper.py
git commit -m "Hardcode target Supabase URL and key"
git push origin main
git add scraper.py
git commit -m "Hardcode target Supabase URL and key"
git push origin main
nano scraper.py
git add scraper.py
git commit -m "Hardcode target Supabase URL and key"
git push origin main
nano scraper.py
git add scraper.py
git commit -m "Hardcode target Supabase URL and key"
git push origin main
git add scraper.py
git commit -m "Hardcode target Supabase URL and key"
git push origin main
