# Proxy Setup Guide for Git Bash (Windows)

---

## Prerequisites

- **Git for Windows** installed (includes Git Bash)
- A proxy client such as **Nekoray, V2Ray, Xray, or Clash**
- Knowing your HTTP proxy port (usually `2080` or `2081`)

---

## Step 1 - Find Your Proxy Port

In your proxy client (e.g. Nekoray), find the **HTTP** port:
- There is usually a separate port for **SOCKS5** and **HTTP**
- Note the HTTP port (e.g. `2081`)

---

## Step 2 - Open `.bashrc`

In Git Bash run:

```bash
nano ~/.bashrc
```

---

## Step 3 - Add Proxy Functions

Go to the end of the file and paste this code (replace port with yours):

```bash
function proxy-on {
    export HTTP_PROXY="http://127.0.0.1:2081"
    export HTTPS_PROXY="http://127.0.0.1:2081"
    echo "Proxy ON ✅"
}

function proxy-off {
    unset HTTP_PROXY
    unset HTTPS_PROXY
    echo "Proxy OFF ❌"
}
```

**Save:** `Ctrl+O` → `Enter` → `Ctrl+X`

---

## Step 4 - Setup `.bash_profile`

Run this command (only **once**):

```bash
echo 'source ~/.bashrc' >> ~/.bash_profile
```

> This makes Git Bash **automatically** load the functions every time it opens.

---

## Step 5 - Test

**Close the terminal completely** and reopen it, then:

```bash
proxy-on
curl https://api.ipify.org
```

If a **foreign IP** is shown, everything is working ✅

---

## Daily Usage

```bash
proxy-on          # Enable proxy
git push          # or any other command
wrangler deploy   # Cloudflare deploy
proxy-off         # Disable proxy
```

---

## Important Notes

- `proxy-on` only applies to **that terminal window**
- `ping` never goes through a proxy — use `curl` for testing
- If your proxy client is off, `proxy-on` won't work

---
---

# راهنمای تنظیم پراکسی در Git Bash (ویندوز)

---

## پیش‌نیاز

- نصب بودن **Git for Windows** (که Git Bash رو شامل می‌شه)
- داشتن یه کلاینت پراکسی مثل **Nekoray، V2Ray، Xray یا Clash**
- دونستن پورت HTTP پراکسی (معمولاً 2080 یا 2081)

---

## مرحله ۱ - پیدا کردن پورت پراکسی

در کلاینتت (مثلاً Nekoray) پورت **HTTP** رو پیدا کن:
- معمولاً یه پورت برای **SOCKS5** و یه پورت برای **HTTP** جداست
- پورت HTTP رو یادداشت کن (مثلاً `2081`)

---

## مرحله ۲ - باز کردن فایل `.bashrc`

در Git Bash بزن:

```bash
nano ~/.bashrc
```

---

## مرحله ۳ - اضافه کردن توابع پراکسی

با کیبورد به آخر فایل برو و این کد رو **دقیقاً** کپی کن (پورت رو با پورت خودت عوض کن):

```bash
function proxy-on {
    export HTTP_PROXY="http://127.0.0.1:2081"
    export HTTPS_PROXY="http://127.0.0.1:2081"
    echo "Proxy ON ✅"
}

function proxy-off {
    unset HTTP_PROXY
    unset HTTPS_PROXY
    echo "Proxy OFF ❌"
}
```

**ذخیره کن:** `Ctrl+O` → `Enter` → `Ctrl+X`

---

## مرحله ۴ - تنظیم `.bash_profile`

این دستور رو بزن (فقط **یک بار**):

```bash
echo 'source ~/.bashrc' >> ~/.bash_profile
```

> این کار باعث می‌شه Git Bash هر بار که باز می‌شه، توابع رو **خودکار** لود کنه.

---

## مرحله ۵ - تست

ترمینال رو **کامل ببند** و دوباره باز کن، بعد:

```bash
proxy-on
curl https://api.ipify.org
```

اگه یه **IP خارجی** نمایش داد، همه‌چیز درسته ✅

---

## استفاده روزانه

```bash
proxy-on          # روشن کردن پراکسی
git push          # یا هر دستور دیگه
wrangler deploy   # دیپلوی Cloudflare
proxy-off         # خاموش کردن پراکسی
```

---

## نکات مهم

- `proxy-on` فقط برای **همون پنجره ترمینال** اعمال می‌شه
- `ping` هیچ‌وقت از پراکسی رد نمی‌شه — برای تست از `curl` استفاده کن
- اگه کلاینت پراکسیت خاموش باشه، `proxy-on` کار نمی‌کنه
