# Privacy Policy

**Last updated:** 2026-08-24

This Privacy Policy explains how **Dizitart** (a sole proprietorship
registered in Kolkata, West Bengal, India — "Dizitart", "we", "us", "our")
handles information in connection with the Kruftle desktop application
("Kruftle", "the App").

**The short version: Kruftle collects nothing.** There are no accounts, no
analytics, no telemetry, no crash reporting, and no background reporting of
any kind. There is exactly one thing the App does over the network, and you
can switch it off: it asks GitHub whether a newer version has been
published. That request tells GitHub nothing about you beyond what any web
request necessarily reveals, and it tells Dizitart nothing at all, because
it does not reach us — we operate no server.

Everything Kruftle knows about your machine — which projects you have, what
they are called, where they live, how big they are — stays on your machine.
There is nowhere for it to go.

## 1. What We Don't Collect

Dizitart does not collect, receive, transmit, or have access to any of the
following:

- The names, paths, or contents of any file or folder on your computer
- Which projects Kruftle found, or which you cleaned
- How much space you reclaimed
- The activity log Kruftle writes (Section 3)
- Your cleanup profiles, schedules, or settings
- Your name, email, or any other contact detail — the App has no field for
  any of them, so there is nothing to send
- Any account identifier — there are no accounts
- Any device identifier, machine fingerprint, or advertising identifier —
  the App does not generate or transmit one at all
- Location data
- Analytics, usage statistics, or behavioural data
- Automatic crash reports or background diagnostics

There is no sign-up, login, or account of any kind. Nothing about your use
of the App is sent to us in the background, ever, under any circumstances.

**We do not sell, rent, or license your data, and we do not share it with
any third party for compensation** — for advertising, profiling, or any
other purpose. We could not: we do not have it. This applies regardless of
where you live, including under India's Digital Personal Data Protection
Act, 2023 (DPDP), the EU's General Data Protection Regulation (GDPR), and
the California Consumer Privacy Act (CCPA).

## 2. What Happens On Your Device

Scanning, detection, measurement, planning, cleaning and reporting all run
entirely locally. Kruftle reads directory listings under the folder you
choose, works out which build tools produced what it finds, and runs those
tools' own clean commands or deletes their allow-listed output directories.
No part of this involves a network.

The following are stored on your computer only, in the App's own settings
and support directories:

- **Your settings** — scan depth, concurrency, theme, language, and the
  rest.
- **Recently scanned folders** — the paths shown on the first screen, so
  you do not have to browse to them again. Remove any of them with the ×
  beside it.
- **Cleanup profiles** — the project types you have taught Kruftle about.
- **Your schedule**, if you set one.
- **The activity log** — see Section 3.

Uninstalling Kruftle, or clearing these from within the App, removes them.
Dizitart has no copy to delete, because we never had one.

## 3. The Activity Log

Kruftle writes a local log of what it did: which folder was scanned, how
many projects were found, which commands were run, what they printed when
they failed, and how many bytes were freed. It exists so that when
something goes wrong you can see exactly what happened, and so you can send
us that account yourself if you choose to.

The log is a plain text file in Kruftle's application-support directory —
Settings shows you its exact path, opens the folder, and clears it. It is
**never transmitted anywhere.** Kruftle has no code that uploads it. If you
want to attach it to a bug report on GitHub, Settings has an "Export log"
button that writes a copy wherever you choose; what happens to that copy is
then entirely up to you. **Read it before you share it** — it contains the
paths of folders on your machine, which you may not want to publish.

You control how much it records and how many old files are kept, in
Settings. Setting the retention to none stops old logs being kept at all.

## 4. Network Activity

Kruftle makes network connections in exactly one situation, and only if you
leave it enabled:

**Checking for updates.** When "Check for updates automatically" is on (it
is on by default), Kruftle asks GitHub's public releases API —
`api.github.com` — whether a version newer than yours has been published.
If one has, and only if you then click Update, Kruftle downloads the
installer from GitHub's own download host and verifies it against the
SHA-256 published in that release before opening it. A file whose checksum
does not match is refused and deleted.

Both requests go directly from your computer to GitHub. **Dizitart is not
a party to them.** We operate no server of our own, and we receive no
notification, log entry or count from them — we do not know that you have
Kruftle installed, let alone that you checked for an update. As with any
request to any website, GitHub necessarily sees your IP address and the
request itself; GitHub's handling of that is governed by their own privacy
statement, linked in Section 8.

**You can turn this off.** Settings → Updates → "Check for updates
automatically". With it off, Kruftle makes no network connection at all,
ever, and you update by downloading a release yourself.

Two things that are *not* network activity, despite appearing to be:

- **Install links.** When a project's build tool is missing, Kruftle shows
  a link to that tool's own website. Nothing is fetched; the link opens in
  your browser only if you click it, and then it is your browser talking to
  that site, not Kruftle.
- **Clean commands.** Kruftle runs your build tools' own clean commands
  (`cargo clean`, `flutter clean`, and so on). Those are your tools, run on
  your machine under your account, and whatever they do — including any
  network access of their own — is between you and them. Kruftle only asks
  them to clean up.

No analytics SDK, no advertising SDK, no crash-reporting SDK, and no A/B
testing framework is included in Kruftle. You do not have to take our word
for it: Kruftle is free software under the GPL-3.0-or-later, and the entire
source is at https://github.com/dizitart/kruftle. Anything in this section
can be checked by reading it.

## 5. Data Storage & Backup

Everything described in Section 2 lives in the ordinary per-user
configuration and application-support locations for your operating system.
It is therefore included in whatever backup arrangements you have for your
own machine — Time Machine, File History, or anything else. That is your
backup, under your control; nothing is backed up to us.

Nothing Kruftle stores leaves your machine except when you deliberately
export it: the log export in Settings, and the profile export on the
Cleanup profiles screen. Both write a file where you tell them to.

## 6. Children's Privacy

Kruftle is a developer tool and is not directed at children. It collects
nothing from any user, of any age, so there is no circumstance in which we
could hold a child's personal data.

## 7. Your Rights

**We hold no personal data about you.** Not a reduced amount — none. There
is no account, no identifier, no telemetry stream and no server. Rights of
access, correction, portability, deletion, restriction and objection all
operate on data a controller holds, and in Kruftle's case there is nothing
for them to operate on.

Everything the App knows is on your computer, under your control, at all
times. You can inspect it, edit it, or delete it yourself: Settings shows
the log's location and clears it, the recent-folders list has a × beside
each entry, and uninstalling removes the lot.

If you believe we hold data about you and want it dealt with, or you have a
privacy question or complaint, email **support@dizitart.com**. We aim to
respond within 30 days. If you are not satisfied, you have the right to
complain to your data-protection authority: the Data Protection Board of
India under the DPDP Act, or your local supervisory authority under the
GDPR.

**CCPA specifically.** We do not sell or share personal information as
those terms are defined by the CCPA, and we never have. There is no account
or service tier that could discriminate against you for exercising any
right.

**Breach notification.** A breach of Dizitart's systems could not expose
your Kruftle data, because your Kruftle data is not in Dizitart's systems.
If anything ever occurred that we believed affected users of the App, we
would announce it publicly — in the release notes, in the App's changelog,
and on the repository — because we hold no contact details with which to
tell anyone individually.

## 8. Third-Party Services

Kruftle's only third-party touchpoint is:

- **GitHub (Microsoft)** — hosts the source repository and the releases the
  update check reads. Your computer talks to GitHub directly.
  https://docs.github.com/site-policy/privacy-policies/github-general-privacy-statement

GitHub is not processing data on our behalf here; it is a public service
your computer contacts directly, in the same way it would if you visited
the repository in a browser.

Kruftle is not distributed through the Apple App Store, the Microsoft
Store, or Google Play, and no billing or in-app-purchase infrastructure of
any kind is involved, because the App is free.

## 9. Grievance Officer / Contact

In accordance with applicable Indian IT rules and the DPDP Act, the
following is our designated contact for privacy-related queries,
data-rights requests, or complaints:

Dizitart (sole proprietorship), Kolkata, West Bengal, India
Email: **support@dizitart.com**

We aim to acknowledge privacy-related queries promptly, and to resolve any
data-rights request within the 30 days described in Section 7.

## 10. Changes to This Policy

We may update this Privacy Policy from time to time; the "Last updated"
date above will reflect the most recent revision. Material changes will be
noted in the App's changelog. The current version always ships inside the
App, under Settings → About → Privacy Policy, and is in the repository.
