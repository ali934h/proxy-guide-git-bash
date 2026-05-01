# راهنمای تنظیم پراکسی (فقط برای شل فعلی)
### Git Bash · PowerShell · CMD · Termux

یه راهنمای ساده + چند اسکریپت کوچک که می‌ذاره **پراکسی HTTP/HTTPS رو فقط
برای پنجره ترمینال فعلی** روشن یا خاموش کنی. مناسب وقتی فقط می‌خوای
`git push`, `npm install`, `wrangler deploy`, `pip install` و ... از کلاینت
پراکسی محلیت (Nekoray, V2Ray, Xray, Clash, sing-box) رد بشه، **بدون** اینکه
کل سیستم رو تونل کنی.

> **چرا روش per-shell به جای TUN/Proxifier؟**
> چون با TUN کل ترافیک سیستم (LAN، بازی، تماس تصویری، آپدیت ویندوز و ...)
> از پراکسی رد می‌شه. این راهنما دقیقاً همین رو نمی‌خواد.

---

## فهرست

- [دستورات نهایی](#دستورات-نهایی)
- [این چطور کار می‌کنه؟](#این-چطور-کار-میکنه)
- [نصب — Git Bash](#نصب--git-bash)
- [نصب — PowerShell](#نصب--powershell)
- [نصب — CMD](#نصب--cmd)
- [نصب — Termux (اندروید)](#نصب--termux-اندروید)
- [تست](#تست)
- [نکات ابزارها](#نکات-ابزارها)
- [رفع اشکال](#رفع-اشکال)
- [لایسنس](#لایسنس)

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

در یه CMD معمولی (بدون ادمین):

```cmd
setx PATH "%PATH%;%USERPROFILE%\bin"
```

> `setx` PATH **کاربری** رو دائمی تغییر می‌ده. CMD رو ببند و باز کن
> تا اعمال بشه.

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

## نصب — Termux (اندروید)

[Termux](https://termux.dev) یه اِمولاتور ترمینال برای اندروید هست که بهت
یه محیط لینوکسی کامل با `bash` و پکیج‌منیجر `pkg` می‌ده. اسکریپت `proxyrc.sh`
همین ریپو دقیقاً روی Termux هم کار می‌کنه.

### پیش‌نیازها

- نصب Termux از [F-Droid](https://f-droid.org/packages/com.termux/) یا
  [GitHub Releases](https://github.com/termux/termux-app/releases)
  (نسخه Play Store قدیمی و دیگه به‌روز نمی‌شه).
- `curl` برای تست نیاز داری:

  ```bash
  pkg update && pkg install curl
  ```

### ۱. اسکریپت رو دانلود کن

می‌تونی مستقیم از GitHub بگیریش:

```bash
curl -fsSL https://raw.githubusercontent.com/ali934h/proxy-guide-git-bash/main/scripts/bash/proxyrc.sh -o ~/proxyrc.sh
```

یا اگه ریپو رو clone کردی:

```bash
pkg install git
git clone https://github.com/ali934h/proxy-guide-git-bash.git
cp proxy-guide-git-bash/scripts/bash/proxyrc.sh ~/proxyrc.sh
```

### ۲. به `.bashrc` اضافه کن

```bash
echo 'source ~/proxyrc.sh' >> ~/.bashrc
```

### ۳. Termux رو ببند و دوباره باز کن (یا دستی لود کن)

```bash
source ~/.bashrc
```

### ۴. استفاده

```bash
proxy-on            # پورت رو می‌پرسه (پیش‌فرض 2081)
proxy-on 2080       # بدون پرسش با پورت 2080
proxy-status
curl https://api.ipify.org
proxy-off
```

### نکات مخصوص Termux

- **آدرس پراکسی:** اگه کلاینت پراکسی (مثل v2rayNG, NekoBox, sing-box,
  Clash) روی **همون گوشی** اجرا می‌شه، آدرس `127.0.0.1` درسته. اگه پراکسی
  روی یه دستگاه دیگه در شبکه محلی هست، آی‌پی اون دستگاه رو بده
  (مثلاً `proxy-on` و بعد دستی متغیرها رو ست کن).

- **پورت رو از کلاینت پراکسیت بخون:** مثلاً در v2rayNG برو به
  Settings → Local proxy port. معمولاً `10809` (HTTP) یا `10808` (SOCKS) هست.

- **SOCKS5 به جای HTTP:** بعضی کلاینت‌های اندروید فقط SOCKS5 می‌دن.
  بعد از `proxy-on` دستی ست کن:

  ```bash
  export HTTP_PROXY=socks5h://127.0.0.1:10808
  export HTTPS_PROXY=socks5h://127.0.0.1:10808
  export http_proxy=$HTTP_PROXY
  export https_proxy=$HTTPS_PROXY
  export ALL_PROXY=$HTTP_PROXY
  export all_proxy=$ALL_PROXY
  ```

- **`git` در Termux:** اگه `git` نصب نیست:

  ```bash
  pkg install git
  ```

  بعد از `proxy-on` دستور `git clone`, `git push` و بقیه دستورات بدون مشکل
  از پراکسی رد می‌شن.

- **`pip` و `python` در Termux:**

  ```bash
  pkg install python
  proxy-on
  pip install <package>
  ```

- **`node` و `npm` در Termux:**

  ```bash
  pkg install nodejs
  proxy-on
  npm install <package>
  ```

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
| `curl`         | بله                           | —                                                                |
| `wget`         | بله                           | —                                                                |
| `npm`          | بله                           | `npm config set proxy http://127.0.0.1:2081`                     |
| `yarn`         | بله                           | `yarn config set httpProxy http://127.0.0.1:2081`                |
| `pnpm`         | بله                           | `pnpm config set proxy http://127.0.0.1:2081`                    |
| `pip`          | بله                           | `pip install --proxy http://127.0.0.1:2081 <pkg>`                |
| `gh`, `wrangler` | بله                         | —                                                                |
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

**در Termux `proxy-on` کار نمی‌کنه.**
مطمئن شو `source ~/proxyrc.sh` رو به `~/.bashrc` اضافه کردی و Termux رو
ریستارت کردی. همچنین چک کن `curl` نصب باشه: `pkg install curl`.

**در Termux آی‌پی عوض نمی‌شه.**
مطمئن شو کلاینت پراکسی (مثل v2rayNG) روی گوشی فعال و متصل هست و پورت
درستی رو استفاده می‌کنی. با `proxy-status` چک کن. اگه کلاینتت فقط SOCKS5
داره، بخش "SOCKS5 به جای HTTP" رو ببین.

---

## لایسنس

MIT — هر کاری دوست داری بکن، بدون گارانتی.
