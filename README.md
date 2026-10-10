# Mission Jiu Jitsu Tournament Calendar

The jiu jitsu version of the tournament calendar. It runs in the same Supabase project as the wrestling calendar but has its own tables, its own coach list and its own address: https://bjjtournaments.missionathletics.com

- Families open the page and see the schedule. No login needed.
- Jiu jitsu coaches click **Coach sign in**, enter their email, and open the emailed link. Only emails in the `bjj_coaches` table can make changes.
- Changes save automatically.

## Files

| File | What it is |
| --- | --- |
| `index.html` | The calendar page |
| `config.js` | Already filled in with your Supabase project (same as wrestling) |
| `setup.sql` | One-time setup for the jiu jitsu tables and coach list |
| `webflow-embed.html` | Code for a hidden Webflow page, once you have Designer access |

## Setup (about 20 minutes)

1. **Supabase, run the script.** In your existing Supabase project, open **SQL Editor → New query**, paste all of `setup.sql`, click **Run**. In **Table Editor** you should now also see `bjj_coaches`, `bjj_tournaments` and `bjj_athletes`. The wrestling tables are untouched.
2. **Supabase, add jiu jitsu coaches.** In **Table Editor → bjj_coaches**, click **Insert → Insert row** for each coach email. This list is separate from the wrestling coach list.
3. **GitHub.** Create a new repository named `mission-jiu-jitsu-calendar` and upload all four files (**Add file → Upload files → Commit changes**).
4. **Render.** **New → Static Site**, pick `mission-jiu-jitsu-calendar`, leave Build Command empty, set Publish Directory to `.`, and click **Create Static Site**. Open the onrender.com address it gives you; you should see an empty jiu jitsu calendar.
5. **Supabase, allow sign-in links.** In **Authentication → URL Configuration**, leave **Site URL** as the wrestling address and add two more **Redirect URLs**:
   - `https://bjjtournaments.missionathletics.com/**`
   - your new Render address with `/**` on the end (for example `https://mission-jiu-jitsu-calendar.onrender.com/**`)
6. **Test sign-in** on the Render address: **Coach sign in**, enter your email, open the emailed link, and confirm you see the Admin bar.
7. **Render, add the address.** **Settings → Custom Domains → Add Custom Domain** → `bjjtournaments.missionathletics.com`.
8. **GoDaddy.** **My Products → missionathletics.com → DNS → Add New Record**: Type `CNAME`, Name `bjjtournaments`, Value = your Render address without https:// (for example `mission-jiu-jitsu-calendar.onrender.com`), then **Save**.
9. **Render, verify.** Click **Verify** on the custom domain. Once it's live, open https://bjjtournaments.missionathletics.com
10. **Webflow (later).** When you have Designer access, create a hidden page with slug `bjj-tournament-schedule` and paste `webflow-embed.html` into a Code Embed, the same way as the wrestling page.

## How it differs from wrestling

- **Style:** Gi and No-Gi instead of Folkstyle, Freestyle and Greco.
- **Divisions:** age group (Kids, Teen, Juvenile, Adult, Master 1 to 7) plus belt.
- **Roster:** belt rank with a colored belt marker, and an IBJJF membership checkbox instead of AAU and USA.
- **Family note:** reminds athletes to get tournament tracking from their coach so they know when they're up.

The sign-in emails share the wrestling calendar's email setup, so the custom email sender (Google App Password) covers both calendars.
