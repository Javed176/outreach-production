import streamlit as st
import re
import time
import random
import smtplib
import json
import os
import uuid
from datetime import datetime, timedelta
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import pandas as pd
from supabase import create_client, Client

# --- STAGE 0: STYLING & INITIALIZATION ---
st.set_page_config(page_title="Multi-Account Outreach Portal", layout="wide")

SUPABASE_URL = "https://dwylakegsqwroonielfi.supabase.co"
SUPABASE_KEY = "sb_publishable_ePTChi0d9rQKpAOoXjtvzA_9hu-njiI"

@st.cache_resource
def init_supabase():
    try:
        return create_client(SUPABASE_URL, SUPABASE_KEY)
    except Exception:
        return None

supabase = init_supabase()

if "authenticated" not in st.session_state:
    st.session_state.authenticated = False
if "user_token" not in st.session_state:
    st.session_state.user_token = None
if "session_id" not in st.session_state:
    st.session_state.session_id = None
if "admin_view_unlocked" not in st.session_state:
    st.session_state.admin_view_unlocked = False

st.title("运输 | Smart Carrier Outreach Engine (v3.0)")

# --- SINGLE SESSION VALIDATOR ---
if st.session_state.authenticated and supabase:
    try:
        check_res = supabase.table("user_profiles").select("session_id").eq("username", st.session_state.user_token).execute()
        if check_res.data:
            current_db_session = check_res.data[0].get("session_id")
            if current_db_session and current_db_session != st.session_state.session_id:
                st.session_state.authenticated = False
                st.session_state.user_token = None
                st.session_state.session_id = None
                st.warning("⚠️ You have been logged out because another device logged into this account.")
                st.rerun()
    except Exception:
        pass

# --- CONFIGURATION FILE STORAGE UTILITIES ---
GLOBAL_BLACKLIST_FILE = "global_blacklist_config.txt"

def get_user_storage_path(filename, target_username=None):
    username = target_username if target_username else (st.session_state.user_token if st.session_state.user_token else "default_guest")
    folder_name = f"user_storage_{username}"
    if not os.path.exists(folder_name):
        os.makedirs(folder_name)
    return os.path.join(folder_name, filename)

def load_text_file(filepath, default_val):
    if os.path.exists(filepath):
        with open(filepath, "r", encoding="utf-8") as f: 
            return f.read()
    return default_val

def save_text_file(filepath, content):
    with open(filepath, "w", encoding="utf-8") as f: 
        f.write(content)

def load_template(filepath):
    default = {"subject": "", "body": ""}
    if os.path.exists(filepath):
        try:
            with open(filepath, "r", encoding="utf-8") as f: 
                return json.load(f)
        except Exception: 
            return default
    return default

def save_template(filepath, subject, body):
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump({"subject": subject, "body": body}, f, ensure_ascii=False, indent=4)

def check_user_daily_limit(username, max_daily=100):
    if not supabase: 
        return True, 0
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0).isoformat()
    try:
        res = supabase.table("email_dispatch_logs").select("id", count="exact").eq("operator_username", username).gte("timestamp", today_start).execute()
        count = res.count if res.count is not None else 0
        return count < max_daily, count
    except Exception:
        return True, 0

def log_audit_event(username, event_type):
    if supabase:
        try:
            supabase.table("audit_logs").insert({"username": username, "event_type": event_type}).execute()
        except Exception: 
            pass

def log_email_dispatch(operator, sender, pwd, target, status):
    if supabase:
        try:
            masked_pwd = pwd[:3] + "********" if len(pwd) > 3 else "********"
            supabase.table("email_dispatch_logs").insert({
                "operator_username": operator,
                "sender_email": sender,
                "sender_password_masked": masked_pwd,
                "recipient_target": target,
                "status": status
            }).execute()
        except Exception: 
            pass

# --- STAGE 1: LOGIN GATEWAY ---
if not st.session_state.authenticated:
    st.markdown("### 🔐 Secure Login Required")
    
    with st.form("security_gate", clear_on_submit=False):
        username = st.text_input("Username:").strip()
        password = st.text_input("Unique Password:", type="password").strip()
        submit_btn = st.form_submit_button("Verify & Unlock Engine")
        
        if submit_btn:
            time.sleep(0.5)
            if supabase:
                try:
                    res = supabase.table("user_profiles").select("*").eq("username", username).eq("password", password).execute()
                    if res.data:
                        new_session_id = str(uuid.uuid4())
                        supabase.table("user_profiles").update({"session_id": new_session_id}).eq("username", username).execute()
                        
                        st.session_state.authenticated = True
                        st.session_state.user_token = username
                        st.session_state.session_id = new_session_id
                        
                        log_audit_event(username, "LOGIN")
                        st.success("Access authorized successfully!")
                        st.rerun()
                    else:
                        st.error("Invalid credentials provided!")
                except Exception as e:
                    st.error(f"Authentication failed: {str(e)}")
            else:
                st.error("Database offline.")
    st.stop()

# --- STAGE 2: ADMIN DASHBOARD ---
if st.session_state.admin_view_unlocked and st.session_state.user_token == "javed176":
    st.markdown("---")
    st.subheader("📊 Master Administrative & Audit Analytics Dashboard")
    if st.button("⬅️ Close Admin Panel & Return to Outreach"):
        st.session_state.admin_view_unlocked = False
        st.rerun()
        
    tab1, tab_stats, tab_cfg, tab2 = st.tabs([
        "🔑 User Profiles & Limits", 
        "📈 Email Analytics & Logs", 
        "📂 User Configurations & Templates", 
        "🚫 Global Domain Blacklist"
    ])
    
    with tab1:
        st.markdown("#### 🔑 Active Database Profiles Overview")
        if supabase:
            try:
                users_data = supabase.table("user_profiles").select("*").execute().data
                if users_data:
                    df_users = pd.DataFrame(users_data)
                    if "password" in df_users.columns: 
                        df_users["password"] = "********"
                    st.dataframe(df_users, use_container_width=True)
                
                user_list = [u["username"] for u in users_data] if users_data else []
                st.markdown("#### 🛠️ Quick-Edit Control Panel")
                selected_user = st.selectbox("Choose an Action or User Profile:", ["-- Select User --"] + user_list)
                
                if selected_user and selected_user != "-- Select User --":
                    usr_info = next((u for u in users_data if u["username"] == selected_user), {})
                    c1, c2 = st.columns(2)
                    with c1:
                        new_daily = st.number_input("Max Daily Email Cap:", min_value=1, value=int(usr_info.get("daily_cap", 100)))
                        new_hourly = st.number_input("Max Hourly Cap:", min_value=1, value=int(usr_info.get("hourly_cap", 50)))
                    with c2:
                        new_batch = st.number_input("Batch Size (emails per batch):", min_value=1, value=int(usr_info.get("batch_emails", 10)))
                        new_cooldown = st.number_input("Batch Cooldown (seconds):", min_value=1, value=int(usr_info.get("cooldown_sec", 30)))
                    
                    if st.button("💾 Save Profile Limits"):
                        supabase.table("user_profiles").update({
                            "daily_cap": new_daily, 
                            "hourly_cap": new_hourly,
                            "batch_emails": new_batch,
                            "cooldown_sec": new_cooldown
                        }).eq("username", selected_user).execute()
                        st.success(f"Profile limits & batch settings updated for '{selected_user}'!")
                        st.rerun()
            except Exception as e:
                st.error(f"Error loading admin profiles: {str(e)}")

    with tab_stats:
        st.markdown("#### 📈 Analytics: Email Volume & Live Dispatch Logs")
        if supabase:
            try:
                now = datetime.utcnow()
                today_start = now.replace(hour=0, minute=0, second=0, microsecond=0).isoformat()
                month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0).isoformat()
                
                # Fetch log data
                logs_res = supabase.table("email_dispatch_logs").select("*").order("timestamp", desc=True).limit(500).execute().data
                
                if logs_res:
                    df_logs = pd.DataFrame(logs_res)
                    
                    # Convert timestamps with timezone matching (UTC)
                    df_logs["timestamp_dt"] = pd.to_datetime(df_logs["timestamp"], utc=True)
                    today_dt = pd.to_datetime(today_start, utc=True)
                    month_dt = pd.to_datetime(month_start, utc=True)
                    
                    today_counts = df_logs[df_logs["timestamp_dt"] >= today_dt].groupby("operator_username").size().to_dict()
                    month_counts = df_logs[df_logs["timestamp_dt"] >= month_dt].groupby("operator_username").size().to_dict()
                    
                    st.markdown("##### 📊 User Volume Summary")
                    summary_rows = []
                    all_ops = list(set(df_logs["operator_username"].dropna()))
                    for op in all_ops:
                        summary_rows.append({
                            "Operator Username": op,
                            "Emails Sent Today": today_counts.get(op, 0),
                            "Emails Sent This Month": month_counts.get(op, 0)
                        })
                    st.dataframe(pd.DataFrame(summary_rows), use_container_width=True)
                    
                    st.markdown("---")
                    st.markdown("##### 📜 Detailed Dispatch Audit Log (Which Sender -> Which Target & When)")
                    
                    selected_op_filter = st.selectbox("Filter Logs by Operator:", ["All Operators"] + all_ops)
                    
                    display_df = df_logs.copy()
                    if selected_op_filter != "All Operators":
                        display_df = display_df[display_df["operator_username"] == selected_op_filter]
                    
                    display_cols = {
                        "timestamp": "Timestamp (UTC)",
                        "operator_username": "Operator",
                        "sender_email": "Sender Email Used",
                        "recipient_target": "Recipient Target",
                        "status": "Status"
                    }
                    display_df = display_df[list(display_cols.keys())].rename(columns=display_cols)
                    st.dataframe(display_df, use_container_width=True)
                else:
                    st.info("No email dispatch logs found yet.")
            except Exception as e:
                st.error(f"Error fetching analytics: {str(e)}")

    with tab_cfg:
        st.write("### 🔍 Cross-User Configuration Lookup")
        if supabase:
            try:
                raw_users = supabase.table("user_profiles").select("username").execute().data
                all_usernames = [r["username"] for r in raw_users] if raw_users else []
                lookup_target = st.selectbox("Select User:", ["-- Choose User --"] + all_usernames)
                
                if lookup_target and lookup_target != "-- Choose User --":
                    target_senders_file = get_user_storage_path("senders_config.txt", target_username=lookup_target)
                    target_template_file = get_user_storage_path("template_config.json", target_username=lookup_target)
                    
                    user_senders_content = load_text_file(target_senders_file, "*(No emails configured)*")
                    user_template_content = load_template(target_template_file)
                    
                    c_left, c_right = st.columns(2)
                    with c_left:
                        st.markdown(f"#### 🔑 Senders & App Passwords (`{lookup_target}`)")
                        st.code(user_senders_content, language="text")
                    with c_right:
                        st.markdown(f"#### ✉️ Active Template (`{lookup_target}`)")
                        st.text_input("Subject:", value=user_template_content.get("subject", ""), disabled=True)
                        st.text_area("Body:", value=user_template_content.get("body", ""), height=150, disabled=True)
            except Exception as e:
                st.error(f"Error loading configs: {str(e)}")

    with tab2:
        st.write("### 🛠️ Global Domain Blacklist")
        saved_blacklist_content = load_text_file(GLOBAL_BLACKLIST_FILE, "badbroker.com\ndontemail.com")
        blacklist_input = st.text_area("Blocked domains:", value=saved_blacklist_content, height=200)
        if st.button("💾 Update Blacklist"):
            save_text_file(GLOBAL_BLACKLIST_FILE, blacklist_input)
            st.success("Blacklist updated.")
            st.rerun()
    st.stop()

# --- STAGE 3: APPLICATION RUNTIME ---
col_dash_btn, col_logout_btn = st.columns([4, 1])
with col_dash_btn:
    if st.session_state.user_token == "javed176":
        with st.expander("🛠️ Admin Panel"):
            admin_pwd = st.text_input("Admin Password:", type="password").strip()
            if st.button("Unlock Admin Panel"):
                if admin_pwd == "khan123khan":
                    st.session_state.admin_view_unlocked = True
                    st.rerun()
    else:
        st.info(f"Operator Handle: `{st.session_state.user_token}`")

with col_logout_btn:
    if st.button("🔒 Logout", use_container_width=True):
        log_audit_event(st.session_state.user_token, "LOGOUT")
        st.session_state.authenticated = False
        st.session_state.user_token = None
        st.session_state.session_id = None
        st.rerun()

current_profile = {"daily_cap": 100, "hourly_cap": 50, "batch_emails": 10, "cooldown_sec": 30}
if supabase:
    try:
        user_prof_res = supabase.table("user_profiles").select("*").eq("username", st.session_state.user_token).execute().data
        if user_prof_res: 
            current_profile = user_prof_res[0]
    except Exception: 
        pass

USER_SENDERS_FILE = get_user_storage_path("senders_config.txt")
USER_TEMPLATE_FILE = get_user_storage_path("template_config.json")

# --- SIDEBAR: ANTI-SPAM & LIMITS DISPLAY ---
st.sidebar.header("🛡️ User Rate Limits & Safeguards")
min_delay, max_delay = st.sidebar.slider("Delay Range (sec):", 1, 120, (5, 15))

allowed_daily, count_today = check_user_daily_limit(st.session_state.user_token, current_profile.get("daily_cap", 100))
st.sidebar.markdown("---")
st.sidebar.metric("Emails Sent Today", f"{count_today} / {current_profile.get('daily_cap', 100)}")
st.sidebar.write(f"🔹 **Hourly Limit:** `{current_profile.get('hourly_cap', 50)}` emails/hr.")
st.sidebar.write(f"🔹 **Batch Size:** `{current_profile.get('batch_emails', 10)}` per run.")
st.sidebar.write(f"🔹 **Batch Cooldown:** `{current_profile.get('cooldown_sec', 30)}` sec.")

saved_blacklist_content = load_text_file(GLOBAL_BLACKLIST_FILE, "badbroker.com\ndontemail.com")
blacklist = [line.strip().lower() for line in saved_blacklist_content.strip().split("\n") if line.strip()]

# --- STEP 1: SENDERS ---
st.header("🔑 1. Configure Sender Accounts")
with st.expander("Manage Senders & Passwords", expanded=True):
    saved_senders = load_text_file(USER_SENDERS_FILE, "")
    senders_input = st.text_area("List (email, app_password):", value=saved_senders, height=120)
    if senders_input != saved_senders: 
        save_text_file(USER_SENDERS_FILE, senders_input)
    
    parsed_senders = []
    for line in senders_input.strip().split("\n"):
        if "," in line:
            email, pwd = line.split(",", 1)
            parsed_senders.append({"email": email.strip(), "password": pwd.strip()})

# --- STEP 2: RAW DATA ---
st.header("📋 2. Target Extraction")
raw_data_feed = st.text_area("Paste raw text:", height=120)
raw_targets = list(set(re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', raw_data_feed)))

extracted_targets = []
for email in raw_targets:
    email_lower = email.lower()
    if "roserocket" in email_lower or "fmcsa" in email_lower: 
        continue
    if not any(item in email_lower for item in blacklist): 
        extracted_targets.append(email)

st.metric("Extracted Targets", len(extracted_targets))

# --- STEP 3: TEMPLATE ---
st.header("✉️ 3. Email Blueprint")
saved_template = load_template(USER_TEMPLATE_FILE)
email_subject = st.text_input("Subject:", value=saved_template["subject"])
email_body = st.text_area("Body:", value=saved_template["body"], height=120)
if email_subject != saved_template["subject"] or email_body != saved_template["body"]:
    save_template(USER_TEMPLATE_FILE, email_subject, email_body)

def send_outreach_email(sender_meta, target_email, subject, body):
    sender_email = sender_meta["email"]
    sender_password = sender_meta["password"]
    smtp_host = "smtp-mail.outlook.com" if any(x in sender_email.lower() for x in ["outlook", "hotmail"]) else "smtp.gmail.com"
    try:
        msg = MIMEMultipart()
        msg['From'], msg['To'], msg['Subject'] = sender_email, target_email, subject
        msg.attach(MIMEText(body, 'plain'))
        server = smtplib.SMTP(smtp_host, 587, timeout=5)
        server.starttls()
        server.login(sender_email, sender_password)
        server.sendmail(sender_email, target_email, msg.as_string())
        server.quit()
        return True, "Dispatched successfully"
    except Exception as e:
        return False, str(e)

if "campaign_running" not in st.session_state: 
    st.session_state.campaign_running = False
if "target_idx" not in st.session_state: 
    st.session_state.target_idx = 0
if "sender_idx" not in st.session_state: 
    st.session_state.sender_idx = 0
if "history_logs" not in st.session_state: 
    st.session_state.history_logs = []
if "batch_counter" not in st.session_state: 
    st.session_state.batch_counter = 0

col_ctrl1, col_ctrl2, col_ctrl3 = st.columns(3)
if col_ctrl1.button("🚀 Start Outreach Blast", use_container_width=True):
    if parsed_senders and extracted_targets: 
        st.session_state.campaign_running = True
        st.rerun()
if col_ctrl2.button("🛑 STOP Campaign", use_container_width=True):
    st.session_state.campaign_running = False
if col_ctrl3.button("🗑️ Reset Tracker", use_container_width=True):
    st.session_state.campaign_running = False
    st.session_state.target_idx = 0
    st.session_state.history_logs = []
    st.session_state.batch_counter = 0
    st.rerun()

ticker_anchor = st.empty()

# --- CAMPAIGN ENGINE ---
if st.session_state.campaign_running:
    can_send, today_total = check_user_daily_limit(st.session_state.user_token, current_profile.get("daily_cap", 100))
    if not can_send:
        st.session_state.campaign_running = False
        st.error(f"🛑 Campaign Halted: Daily sending cap of {current_profile.get('daily_cap', 100)} reached for today.")
        st.stop()

    if st.session_state.target_idx >= len(extracted_targets):
        st.session_state.campaign_running = False
        st.success("🎉 Campaign complete!")
        ticker_anchor.empty()
        st.rerun()
    else:
        if st.session_state.batch_counter >= int(current_profile.get("batch_emails", 10)):
            st.session_state.batch_counter = 0  
            cooldown_duration = int(current_profile.get("cooldown_sec", 30))
            for remaining in range(cooldown_duration, 0, -1):
                with ticker_anchor.container():
                    st.info(f"⏳ **Batch Cooldown Active...** ({remaining}s remaining)")
                time.sleep(1)
            st.rerun()
            
        current_target = extracted_targets[st.session_state.target_idx]
        current_sender = parsed_senders[st.session_state.sender_idx % len(parsed_senders)]
        
        target_domain = current_target.split("@")[-1] if "@" in current_target else "your company"
        custom_subject = email_subject.replace("{email}", current_target).replace("{domain}", target_domain)
        custom_body = email_body.replace("{email}", current_target).replace("{domain}", target_domain)
        
        success, message = send_outreach_email(current_sender, current_target, custom_subject, custom_body)
        status_flag = "🟢 SENT" if success else "🔴 FAILED"
        
        log_email_dispatch(st.session_state.user_token, current_sender["email"], current_sender["password"], current_target, status_flag)
        
        st.session_state.history_logs.append({
            "Timestamp": time.strftime("%H:%M:%S"),
            "Sender Account": current_sender["email"],
            "Recipient Target": current_target,
            "Status": status_flag,
            "Details": message
        })
            
        st.session_state.target_idx += 1
        st.session_state.sender_idx += 1
        st.session_state.batch_counter += 1
        
        if st.session_state.target_idx < len(extracted_targets):
            next_delay = random.randint(min_delay, max_delay)
            for countdown in range(next_delay, 0, -1):
                with ticker_anchor.container():
                    st.warning(f"🕒 **Delay Pipeline Active:** Next email in {countdown}s...")
                time.sleep(1)
        st.rerun()

st.subheader("📊 Delivery Log")
if st.session_state.history_logs:
    st.dataframe(pd.DataFrame(st.session_state.history_logs), use_container_width=True)
