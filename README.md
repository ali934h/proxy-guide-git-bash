# Per-Shell Proxy Toggle on Windows
### Git Bash · PowerShell · CMD

A tiny, no-app, no-system-tunnel guide and set of scripts that let you turn an
**HTTP/HTTPS proxy on or off for the current shell only** — perfect when you
just want `git push`, `npm install`, `wrangler deploy`, `pip install`, etc. to
go through a local proxy client (Nekoray, V2Ray, Xray, Clash, sing-box, …)
without forcing the entire OS through it.

> **Why per-shell instead of TUN / Proxifier?**
> System-wide tunnels work, but they route _everything_ through the proxy
> (LAN, games, video calls, Windows Update, …). This guide intentionally
> stays scoped to the shell you opened it in.

---

## Contents

- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Setup — Git Bash](#setup--git-bash)
- [Setup — PowerShell](#setup--powershell)
- [Setup — CMD](#setup--cmd)
- [Verify It Works](#verify-it-works)
- [Per-Tool Tips](#per-tool-tips)
- [Troubleshooting](#troubleshooting)
- [Persian / فارسی](#راهنمای-تنظیم-پراکسی-روی-ویندوز-فقط-برای-شل-فعلی)

---

## Quick Start

After completing the setup for your shell of choice you get three commands:

| Command         | What it does                                                       |
|-----------------|---------------------------------------------------------------------|
| `proxy-on`      | Asks for a port (default `2081`) and exports `HTTP(S)_PROXY` etc.   |
| `proxy-on 2080` | Same, but skips the prompt and uses the given port directly.        |
| `proxy-off`     | Unsets all proxy variables in the current shell.                    |
| `proxy-status`  | Prints the current proxy URL or `OFF`.                              |

These only affect **the shell window you ran them in**. Closing the window
or opening a new one starts with no proxy.

---

## How It Works

The scripts set / unset a small group of standard environment variables that
virtually every modern CLI tool respects:

```
HTTP_PROXY   HTTPS_PROXY   ALL_PROXY   NO_PROXY
http_proxy   https_proxy   all_proxy   no_proxy
```

`NO_PROXY=localhost,127.0.0.1,::1` is set so that local services
(`localhost:3000`, dev servers, etc.) are **not** sent through the proxy.

Find the **HTTP** port in your proxy client. In Nekoray it is shown next to
"HTTP" (often `2080` or `2081`); SOCKS5 is usually a different port. Use the
HTTP port everywhere in this guide.

---

## Setup — Git Bash

1. Copy `scripts/bash/proxyrc.sh` from this repo to your home folder, e.g.
   `~/proxyrc.sh` (`/c/Users/<you>/proxyrc.sh`).

2. Add a single line to `~/.bashrc`:

   ```bash
   echo 'source ~/proxyrc.sh' >> ~/.bashrc
   ```

3. Make sure `.bashrc` is loaded by Git Bash (only needed once):

   ```bash
   echo 'source ~/.bashrc' >> ~/.bash_profile
   ```

4. Close Git Bash completely and reopen it.

5. Use it:

   ```bash
   proxy-on            # prompts for port, default 2081
   proxy-on 2080       # use port 2080 without asking
   proxy-status
   curl https://api.ipify.org
   proxy-off
   ```

> Don't want to keep the file separate? You can paste the contents of
> `proxyrc.sh` directly at the end of `~/.bashrc` instead of sourcing it.

---

## Setup — PowerShell

Works on both **Windows PowerShell 5.1** (the blue one) and **PowerShell 7+**
(`pwsh`).

### 1. Allow profile scripts to run (Windows PowerShell 5.1 only)

Windows PowerShell 5.1 ships with `ExecutionPolicy = Restricted` by default,
which blocks **all** `.ps1` files including your profile. Run **once** in an
**admin-free** PowerShell window:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

`RemoteSigned` only requires a signature for files downloaded from the
internet; locally-written scripts (like your profile) run freely. You do not
need administrator rights for `-Scope CurrentUser`.

> PowerShell 7+ already defaults to `RemoteSigned` on Windows — you can skip
> this step if you only use `pwsh`.

### 2. Drop the script in your home folder

Copy `scripts/powershell/proxy.ps1` to `$HOME\proxy.ps1`
(typically `C:\Users\<you>\proxy.ps1`).

### 3. Make your profile load it

Open the profile (it will be created if it doesn't exist):

```powershell
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
notepad $PROFILE
```

Add this line at the bottom and save:

```powershell
. "$HOME\proxy.ps1"
```

### 4. Restart PowerShell and use it

```powershell
proxy-on            # prompts for port, default 2081
proxy-on 2080       # explicit port, no prompt
proxy-status
curl https://api.ipify.org
proxy-off
```

> **Heads-up about `curl` in Windows PowerShell 5.1:** there `curl` is an
> alias for `Invoke-WebRequest`, which uses Windows' system proxy, **not**
> `HTTP_PROXY`. Use `curl.exe` (shipped with Windows 10+) to test:
> `curl.exe https://api.ipify.org`. PowerShell 7 removes the alias.

---

## Setup — CMD

Classic `cmd.exe` has no functions, so we use small batch files placed
somewhere on your `PATH`.

### 1. Copy the scripts

Copy `scripts/cmd/proxy-on.cmd`, `proxy-off.cmd`, and `proxy-status.cmd`
to a folder of your choice, for example `C:\Users\<you>\bin`.

### 2. Add that folder to your user PATH

> ⚠️ **Don't use `setx PATH "%PATH%;..."`.** It looks tempting but it's
> dangerous: in CMD `%PATH%` expands to **system + user** PATH combined, so
> you'd duplicate every system entry into your user PATH. Worse, `setx`
> silently truncates values longer than 1024 characters, which permanently
> corrupts your PATH on most dev machines.

Use this PowerShell one-liner instead — it appends only to the **user**
PATH and leaves the system PATH untouched. Run it once in any PowerShell
window (no admin needed):

```powershell
[Environment]::SetEnvironmentVariable(
    'Path',
    [Environment]::GetEnvironmentVariable('Path','User') + ";$HOME\bin",
    'User'
)
```

Or do it through the GUI: **Win + R → `sysdm.cpl` → Advanced → Environment
Variables → User variables → `Path` → New →** `%USERPROFILE%\bin` → OK.

Close and reopen CMD for the change to take effect (you only do this once).

### 3. Use it

Open a new CMD window:

```cmd
proxy-on
Proxy port (default 2081): 2080
proxy-status
curl https://api.ipify.org
proxy-off
```

You can also pass the port directly: `proxy-on 2080`.

> **Why this works:** when you run `proxy-on.cmd` by typing its name in an
> interactive CMD session, the `set` commands inside it modify the current
> shell's environment (because the script does **not** use `setlocal`).
> The variables stay set until you run `proxy-off` or close the window.

---

## Verify It Works

With proxy **off**, note your real IP:

```bash
curl https://api.ipify.org
```

Turn it on and check again:

```bash
proxy-on
curl https://api.ipify.org
```

The IP should now be the one of your proxy's exit node. If it didn't change,
see [Troubleshooting](#troubleshooting).

---

## Per-Tool Tips

Most tools auto-pick `HTTP_PROXY` / `HTTPS_PROXY`. A few have their own knobs:

| Tool         | Respects `HTTP_PROXY`? | Per-tool config                                                                 |
|--------------|------------------------|---------------------------------------------------------------------------------|
| `git`        | Yes                    | `git config --global http.proxy http://127.0.0.1:2081` (persistent alternative) |
| `curl`       | Yes                    | —                                                                               |
| `wget`       | Yes                    | —                                                                               |
| `npm`        | Yes                    | `npm config set proxy http://127.0.0.1:2081`                                    |
| `yarn`       | Yes                    | `yarn config set httpProxy http://127.0.0.1:2081`                               |
| `pnpm`       | Yes                    | `pnpm config set proxy http://127.0.0.1:2081`                                   |
| `pip`        | Yes                    | `pip install --proxy http://127.0.0.1:2081 <pkg>`                               |
| `gh` (GitHub)| Yes                    | —                                                                               |
| `wrangler`   | Yes                    | —                                                                               |
| `docker pull`| **No** (daemon-level)  | Edit `%USERPROFILE%\.docker\config.json` `proxies` block, or set in Docker Desktop → Settings → Resources → Proxies |
| `ping`       | **No** (raw ICMP)      | Don't use `ping` to test a proxy; use `curl` instead.                           |

### SOCKS5 instead of HTTP

If your client only exposes SOCKS5, replace the URL with `socks5h://`:

```bash
proxy-on            # then manually:
export HTTPS_PROXY=socks5h://127.0.0.1:2080
export HTTP_PROXY=socks5h://127.0.0.1:2080
```

The `h` makes the proxy resolve DNS — important to avoid DNS leaks.

---

## Troubleshooting

**`proxy-on` doesn't change my IP.**
Make sure the proxy client itself is running and that you used the **HTTP**
port (not SOCKS5). Check with `proxy-status`.

**`ping google.com` still fails after `proxy-on`.**
Expected. `ping` uses raw ICMP and ignores proxy variables. Use `curl` to
test connectivity instead.

**Localhost requests are slow / fail with proxy on.**
The script already sets `NO_PROXY=localhost,127.0.0.1,::1`. If you also need
to bypass an internal domain, append it:
`export NO_PROXY="$NO_PROXY,.corp.example.com"`.

**PowerShell says "running scripts is disabled on this system".**
Run the `Set-ExecutionPolicy` command from the PowerShell setup section.

**`curl` in PowerShell 5.1 ignores the proxy.**
That `curl` is `Invoke-WebRequest`, not real curl. Use `curl.exe`.

**`git` still fails with proxy on.**
You probably set a persistent `http.proxy` previously that points to a
wrong port. Check with `git config --global --get http.proxy` and unset
with `git config --global --unset http.proxy` so git falls back to env vars.

**Docker pulls don't go through the proxy.**
The Docker daemon doesn't read your shell env. Configure Docker Desktop's
proxy settings (Settings → Resources → Proxies) or edit
`%USERPROFILE%\.docker\config.json`.

**My company uses an authenticated proxy.**
Embed credentials in the URL: `http://user:pass@host:port`. Note that
special characters in the password must be URL-encoded.

---

## License

MIT — do whatever you want, no warranty.

---
---

# راهنمای تنظیم پراکسی روی ویندوز (فقط برای شل فعلی)
### Git Bash · PowerShell · CMD

یه راهنمای ساده + چند اسکریپت کوچک که می‌ذاره **پراکسی HTTP/HTTPS رو فقط
برای پنجره ترمینال فعلی** روشن یا خاموش کنی. مناسب وقتی فقط می‌خوای
`git push`, `npm install`, `wrangler deploy`, `pip install` و ... از کلاینت
پراکسی محلیت (Nekoray, V2Ray, Xray, Clash, sing-box) رد بشه، **بدون** اینکه
کل سیستم رو تونل کنی.

> **چرا روش per-shell به جای TUN/Proxifier؟**
> چون با TUN کل ترافیک سیستم (LAN، بازی، تماس تصویری، آپدیت ویندوز و ...)
> از پراکسی رد می‌شه. این راهنما دقیقاً همین رو نمی‌خواد.

---

## دستورات نهایی

بعد از نصب در شل دلخواهت سه دستور داری:

| دستور            | کارش                                                                |
|------------------|----------------------------------------------------------------------|
| `proxy-on`       | پورت رو می‌پرسه (پیش‌فرض `2081`) و متغیرها رو ست می‌کنه.            |
| `proxy-on 2080`  | همون، ولی بدون پرسش با پورت داده‌شده.                                |
| `proxy-off`      | همه متغیرهای پراکسی رو پاک می‌کنه.                                   |
| `proxy-status`   | وضعیت فعلی رو نمایش می‌ده.                                          |

این‌ها فقط روی **همون پنجره‌ای** که توش اجراشون کردی اثر دارن.

---

## این چطور کار می‌کنه؟

اسکریپت‌ها این متغیرهای استاندارد رو ست/پاک می‌کنن که تقریباً هر CLI مدرن
ازشون پشتیبانی می‌کنه:

```
HTTP_PROXY   HTTPS_PROXY   ALL_PROXY   NO_PROXY
http_proxy   https_proxy   all_proxy   no_proxy
```

مقدار `NO_PROXY=localhost,127.0.0.1,::1` ست می‌شه تا ترافیک محلی
(مثلاً `localhost:3000`) از پراکسی رد **نشه**.

پورت **HTTP** رو از کلاینت پراکسیت پیدا کن. در Nekoray کنار "HTTP" می‌بینی
(معمولاً `2080` یا `2081`). پورت SOCKS5 معمولاً جداست؛ ما به HTTP کار داریم.

---

## نصب — Git Bash

1. فایل `scripts/bash/proxyrc.sh` این ریپو رو کپی کن به پوشه home،
   مثلاً `~/proxyrc.sh` (یعنی `/c/Users/<you>/proxyrc.sh`).

2. این خط رو به `~/.bashrc` اضافه کن:

   ```bash
   echo 'source ~/proxyrc.sh' >> ~/.bashrc
   ```

3. مطمئن شو Git Bash موقع باز شدن `.bashrc` رو لود می‌کنه (یک بار):

   ```bash
   echo 'source ~/.bashrc' >> ~/.bash_profile
   ```

4. ترمینال رو **کامل ببند** و دوباره باز کن.

5. استفاده:

   ```bash
   proxy-on            # پورت رو می‌پرسه (پیش‌فرض 2081)
   proxy-on 2080       # بدون پرسش با پورت 2080
   proxy-status
   curl https://api.ipify.org
   proxy-off
   ```

> اگه نمی‌خوای فایل جدا داشته باشی، می‌تونی محتوای `proxyrc.sh` رو مستقیم
> آخر `~/.bashrc` بچسبونی.

---

## نصب — PowerShell

روی **Windows PowerShell 5.1** (آبی‌رنگ) و **PowerShell 7+** هر دو کار می‌کنه.

### ۱. اجازه اجرای اسکریپت در پروفایل (فقط Windows PowerShell 5.1)

Windows PowerShell 5.1 پیش‌فرض `ExecutionPolicy = Restricted` داره و اجازه
نمی‌ده هیچ `.ps1` (حتی پروفایل خودت) اجرا بشه. این دستور رو **یک بار** در
PowerShell **بدون نیاز به ادمین** بزن:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

`RemoteSigned` فقط برای فایل‌هایی که از اینترنت دانلود شدن امضا می‌خواد؛
اسکریپت‌های محلی (مثل پروفایلت) آزادانه اجرا می‌شن. `-Scope CurrentUser`
باعث می‌شه نیاز به ادمین نداشته باشی.

> PowerShell 7+ روی ویندوز پیش‌فرض `RemoteSigned` هست — اگه فقط `pwsh`
> استفاده می‌کنی، این مرحله رو رد کن.

### ۲. اسکریپت رو در home بذار

`scripts/powershell/proxy.ps1` رو کپی کن به `$HOME\proxy.ps1`
(معمولاً `C:\Users\<you>\proxy.ps1`).

### ۳. پروفایل رو وادار کن لودش کنه

```powershell
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
notepad $PROFILE
```

این خط رو آخر فایل اضافه و ذخیره کن:

```powershell
. "$HOME\proxy.ps1"
```

### ۴. PowerShell رو ببند و باز کن

```powershell
proxy-on            # پورت رو می‌پرسه (پیش‌فرض 2081)
proxy-on 2080       # بدون پرسش
proxy-status
curl.exe https://api.ipify.org
proxy-off
```

> **یه نکته درباره `curl` در PowerShell 5.1:** اونجا `curl` در واقع
> `Invoke-WebRequest` هست که از پراکسی سیستم استفاده می‌کنه، نه از
> `HTTP_PROXY`. برای تست از `curl.exe` (که در Windows 10+ هست) استفاده کن.
> در PowerShell 7 این مشکل نیست.

---

## نصب — CMD

`cmd.exe` تابع نداره، پس از چند فایل bat در پوشه‌ای داخل `PATH` استفاده می‌کنیم.

### ۱. اسکریپت‌ها رو کپی کن

`scripts/cmd/proxy-on.cmd`, `proxy-off.cmd`, `proxy-status.cmd` رو ببر
به یه پوشه دلخواه، مثلاً `C:\Users\<you>\bin`.

### ۲. اون پوشه رو به PATH کاربری اضافه کن

> ⚠️ **از `setx PATH "%PATH%;..."` استفاده نکن.** دو مشکل جدی داره:
> ۱) در CMD، `%PATH%` ترکیبِ system+user رو برمی‌گردونه؛ نوشتنش روی PATH
> کاربری باعث می‌شه همه ورودی‌های system در user تکراری بشن. ۲) `setx`
> مقدارهای بزرگ‌تر از ۱۰۲۴ کاراکتر رو **بی‌سروصدا قطع می‌کنه** و در
> ماشین‌های توسعه که PATH شلوغ داره، PATH رو دائمی خراب می‌کنه.

به‌جاش این یه‌خطی PowerShell رو **یک بار** بزن. فقط به PATH **کاربری**
اضافه می‌کنه و سیستم رو دست نمی‌زنه (نیاز به ادمین هم نداره):

```powershell
[Environment]::SetEnvironmentVariable(
    'Path',
    [Environment]::GetEnvironmentVariable('Path','User') + ";$HOME\bin",
    'User'
)
```

یا از طریق GUI: **Win + R → `sysdm.cpl` → Advanced → Environment
Variables → User variables → `Path` → New →** `%USERPROFILE%\bin` → OK.

بعدش CMD رو ببند و باز کن تا اعمال بشه (یک بار کافیه).

### ۳. استفاده

در یه پنجره CMD جدید:

```cmd
proxy-on
Proxy port (default 2081): 2080
proxy-status
curl https://api.ipify.org
proxy-off
```

می‌تونی پورت رو مستقیم بدی: `proxy-on 2080`.

> **چرا کار می‌کنه:** وقتی `proxy-on.cmd` رو با تایپ کردن اسمش در یه
> CMD باز اجرا می‌کنی، چون اسکریپت `setlocal` نداره، دستورات `set` داخلش
> روی همون پنجره فعلی اثر می‌ذاره و تا وقتی `proxy-off` بزنی یا پنجره
> رو ببندی، پراکسی روشن می‌مونه.

---

## تست

با پراکسی **خاموش** آی‌پی واقعیت رو ببین:

```bash
curl https://api.ipify.org
```

روشنش کن و دوباره تست کن:

```bash
proxy-on
curl https://api.ipify.org
```

الان باید آی‌پی نود خروجی پراکسیت نمایش داده بشه. اگه عوض نشد، برو
سراغ بخش رفع اشکال.

---

## نکات ابزارها

اکثر ابزارها خودشون `HTTP_PROXY` رو می‌خونن. چندتا استثنا:

| ابزار          | از `HTTP_PROXY` پیروی می‌کنه؟ | تنظیم اختصاصی                                                    |
|----------------|-------------------------------|------------------------------------------------------------------|
| `git`          | بله                           | `git config --global http.proxy http://127.0.0.1:2081`           |
| `npm`          | بله                           | `npm config set proxy http://127.0.0.1:2081`                     |
| `yarn`         | بله                           | `yarn config set httpProxy http://127.0.0.1:2081`                |
| `pip`          | بله                           | `pip install --proxy http://127.0.0.1:2081 <pkg>`                |
| `gh`, `wrangler`, `curl`, `wget` | بله         | —                                                                |
| `docker pull`  | **نه** (در سطح daemon)        | تنظیمات Docker Desktop → Resources → Proxies                     |
| `ping`         | **نه** (ICMP خام)             | برای تست پراکسی از `ping` استفاده نکن، از `curl` استفاده کن.      |

### SOCKS5 به جای HTTP

اگه کلاینتت فقط SOCKS5 می‌ده، آدرس رو با `socks5h://` ست کن:

```bash
export HTTPS_PROXY=socks5h://127.0.0.1:2080
export HTTP_PROXY=socks5h://127.0.0.1:2080
```

اون `h` باعث می‌شه DNS هم از پراکسی رد بشه (جلوگیری از DNS leak).

---

## رفع اشکال

**`proxy-on` رو زدم ولی IP عوض نشد.**
مطمئن شو خود کلاینت پراکسی روشنه و پورت **HTTP** (نه SOCKS5) رو دادی.
با `proxy-status` چک کن.

**`ping google.com` بعد از `proxy-on` کار نمی‌کنه.**
طبیعیه. `ping` از ICMP خام استفاده می‌کنه و متغیرهای پراکسی رو نمی‌خونه.
با `curl` تست کن.

**درخواست به localhost کند یا fail می‌شه.**
اسکریپت `NO_PROXY=localhost,127.0.0.1,::1` رو ست می‌کنه. اگه دامنه داخلی
خاص هم داری، اضافه‌ش کن:
`export NO_PROXY="$NO_PROXY,.corp.example.com"`.

**PowerShell می‌گه "running scripts is disabled on this system".**
دستور `Set-ExecutionPolicy` رو از بخش نصب PowerShell بزن.

**`curl` در PowerShell 5.1 از پراکسی رد نمی‌شه.**
چون اونجا `curl` در واقع `Invoke-WebRequest` هست. از `curl.exe` استفاده کن.

**`git` با پراکسی روشن هنوز fail می‌شه.**
احتمالاً قبلاً `http.proxy` رو دائمی روی پورت اشتباه ست کردی. چک کن:
`git config --global --get http.proxy` و اگه چیزی هست:
`git config --global --unset http.proxy`.

**Docker pull از پراکسی رد نمی‌شه.**
Daemon داکر متغیرهای شل رو نمی‌خونه. از Docker Desktop → Settings →
Resources → Proxies یا فایل `%USERPROFILE%\.docker\config.json` استفاده کن.

**پراکسی شرکتی با یوزر/پسورد دارم.**
در آدرس بنویس: `http://user:pass@host:port`. کاراکترهای خاص رمز رو
URL-encode کن.

---

## لایسنس

MIT — هر کاری دوست داری بکن، بدون گارانتی.
