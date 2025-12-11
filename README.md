# SecretSantaBot

# Secret Santa 🎅 Email Automator (R + gmailr)

This repository contains an R script that automatically generates Secret Santa assignments and emails each participant their gift recipient using the [`gmailr`](https://github.com/r-lib/gmailr) package. The script supports:

- 🎁 **Random Secret Santa pairings**
- ⛔ **Forbidden pairs** (e.g., spouses, siblings, or any pair who should not draw each other)
- 📧 **Automated email delivery** or draft creation in Gmail
- 🔐 **OAuth 2.0 authentication** using a Google Cloud OAuth client
- 🧪 **Example dataset with Lord of the Rings characters**
- 
This is a fun, reproducible way to manage group gift exchanges while keeping assignments secret—even from the organizer.

---

## 🚀 Features

- **Randomized assignments** using a robust cycle permutation algorithm  
- **Bidirectional forbidden-pair rules** to prevent certain participants from being matched  
- **Email automation** handled through the Gmail API  
- **Draft mode** for reviewing messages before sending  
- **Drop-in customization** for your own group and email account  

---

## 🔐 Google OAuth Setup

To send emails using the Gmail API, you must create an OAuth 2.0 client through Google Cloud:

1. Go to **Google Cloud Console** → https://console.cloud.google.com/  
2. Create a project (or use an existing one).  
3. Enable the **Gmail API** in “APIs & Services → Library”.  
4. Configure the **OAuth consent screen** (External is fine for personal use).  
5. Create OAuth credentials:  
   - Go to “APIs & Services → Credentials”  
   - Click **Create Credentials → OAuth client ID**  
   - Choose **Desktop App**  
   - Download the resulting JSON file  
6. Save the JSON file somewhere on your machine  
7. Point the script to this file using:

   ```r
   gm_auth_configure(path = "path/to/your/oauth_client.json")
8. Run the script once interactively to authorize your Gmail account:
   ```r
   gm_auth(email = "your-email@gmail.com")

   
## Everything else should be self explanatory! Merry Merry! 🎁
