# Terms of Service

**Last updated:** 2026-08-26

These Terms of Service ("Terms") govern your use of the Kruftle desktop
application ("Kruftle", "the App"), provided by **Dizitart**, a sole
proprietorship registered in Kolkata, West Bengal, India ("Dizitart", "we",
"us", "our"). By downloading, installing, or using the App you agree to
these Terms. If you do not agree, do not use the App. When you first run
the App it asks you to accept these Terms and the Privacy Policy before it
will do anything else, and both remain readable at any time under
Settings → About.

Kruftle is **free software**, and these Terms sit alongside — and never
above — the GNU General Public License v3.0 or later, under which it is
distributed. Where anything here conflicts with the GPL, the GPL wins. A
copy of the licence ships with the App and is in the repository.

## 1. What Kruftle Is

Kruftle finds software projects under a folder you choose, works out which
language or build tool produced each one, and reclaims disk space by asking
that toolchain to clean up after itself — `cargo clean`, `flutter clean`,
`mvn clean`, and so on. Where a toolchain is not installed, and only if you
explicitly opt in for that run, it can instead delete that toolchain's
well-known output directory.

**Kruftle deletes files.** That is what it is for. Everything in these
Terms about care, responsibility and liability follows from that single
fact, and you should read Sections 3, 8 and 9 before you use it in anger.

It runs entirely on your computer. There are no accounts, no subscriptions,
no purchases, and no server of ours — the only thing Kruftle sends over the
network is an update check to GitHub, which you can switch off. Section 5
covers that and the Privacy Policy covers it in full.

## 2. Eligibility and Licence

You must be old enough to form a binding contract where you live. Kruftle
is a tool for software developers and is not directed at children.

Your rights to use, copy, modify and redistribute Kruftle are the rights
the **GNU General Public License v3.0 or later** grants you, in full. These
Terms do not add restrictions to that licence and are not intended to. They
govern the relationship between you and Dizitart as the publisher of the
official builds — nothing more.

## 3. Your Responsibility for What Gets Deleted

This is the part that matters.

**You choose the folder, and you confirm the run.** Kruftle shows you every
project it found and every directory it proposes to touch, with measured
sizes, before anything happens. Nothing is deleted until you have selected
it and confirmed. A dry run, which changes nothing, is offered every time.

**Two settings move that check, and both are off until you turn them on.**
You can switch off the final confirmation dialog in Settings. You can also
set a schedule and allow it to run in the background, in which case Kruftle
cleans the folder you nominated on its own, with nobody watching — there is
no selection screen and no dry run, because there is nobody there to show
them to. An unattended run does the toolchains' own clean commands and
deletes only the categories you pre-selected in Settings, which a fresh
install has none of; it cannot widen its own permission while you are away.
If you turn either of these on, you are choosing to move a check that
exists for your benefit. Please read the rest of this section first.

**Kruftle takes real precautions, and they are not a guarantee.** When it
cleans projects, the App refuses to scan or clean the filesystem root, your
home directory, or system directories; it never follows a symbolic link; it
never removes anything outside the folder you chose; and raw deletion is
limited to an allow-list of directory names belonging to a positively
identified project type. Each of those rules has a test that fails closed.
They exist because we take this seriously.

Directories that git is tracking are also left out of the deletion plan,
because deleting committed content is not something a rebuild undoes. That
particular check is weaker than the others and you should know how: it
depends on `git` being installed and on the project being a git working
tree, and where it is not, Kruftle simply has nothing to go on and carries
on without it. It also cannot restrain a toolchain's own clean command — if
you have committed a directory that `cargo clean` or `flutter clean`
considers its own, that command will still remove it.

The global caches described below are a deliberate exception to the
containment rule, and have their own gate instead.

They are still not a promise that nothing you value will be removed. A
build directory can contain something irreplaceable that you put there. A
clean command can do more than you expected — including a clean command
that came from the project being cleaned rather than from your machine, as
Section 10 explains. A cleanup profile points Kruftle at whatever it is
told to point at.

**Accordingly:**

- **Back up anything you cannot lose, before you clean.** This is the whole
  of the advice, and it is not a formality.
- Review what is selected. Use the dry run if you are unsure.
- Directories removed by Kruftle, or by the clean commands it invokes, are
  **deleted, not moved to a trash or recycle bin.** They are not
  recoverable through the App.
- You are responsible for the cleanup profiles you create and for any
  command you configure one to run. A profile runs the command you typed,
  in the project directory it matched, under your user account. Kruftle
  validates that a profile's deletable directories are relative to the
  project and free of `..` and wildcards, and it applies every safety rule
  above to them — but the command itself is yours.
- A cleanup profile you **import** from a file runs the command whoever
  wrote that file typed. Kruftle applies the same path checks to an imported
  profile as to one you wrote, but it cannot tell you whether the command is
  a good idea. Open a profile and read its command before you enable it.
- You are responsible for having the right to delete what you point the App
  at, including on shared or work machines.
- Kruftle keeps a local record of what it did, in its activity log. If a run
  does something you did not expect, that log is the first place to look;
  the Privacy Policy explains where it lives, what it contains and how to
  clear it.

### Global caches

Kruftle can also empty the shared caches your build tools keep in your home
directory — the Gradle caches, the Cargo registry, the local Maven
repository, the pub cache, the npm cache, the Go module cache and Xcode's
DerivedData. **These sit outside any folder you choose, and the containment
rule above does not apply to them.**

They have their own screen and their own confirmation, separate from a
project cleanup. Kruftle will only ever touch the specific cache paths it
knows about, never your home directory itself and never a symbolic link,
and where a toolchain has its own command for the job it uses that instead
of deleting anything.

Emptying one of these is not destructive in the ordinary case: the contents
are re-downloaded or rebuilt on demand, which costs time and bandwidth
rather than work. But it costs that for every project on the machine, and
if you have vendored, patched or hand-edited anything inside one of these
caches, it is gone.

## 4. Cost

Kruftle is free. There is no paid tier, no subscription, no trial that
lapses, no in-app purchase and no advertising. There is nothing to cancel
and no payment method to give us. If you ever encounter a copy of Kruftle
that asks you to pay, it did not come from us.

## 5. Updates

Update checking is on by default. While it is enabled, Kruftle asks GitHub
whether a newer release exists, and offers it. It verifies any download against the SHA-256
published with that release and refuses one that does not match. **Kruftle
never installs an update without asking you**, and you can switch the check
off entirely in Settings.

We are not obliged to publish updates, to keep publishing them, or to keep
the App available. Because Kruftle runs entirely on your machine with no
server behind it, an installed copy keeps working regardless.

## 6. Distribution and Signing

The official builds are published on GitHub Releases and are **unsigned**.
On macOS they carry only an ad-hoc signature; on Windows they are not
signed with a code-signing certificate. Your operating system will very
likely warn you about this, and it is right to. Verify a download against
the checksums published with the release, which is the assurance we can
actually offer, and which is stronger than a signature you have no way to
audit.

Builds obtained from anywhere other than
https://github.com/dizitart/kruftle are not our builds, and nothing in
these Terms applies to them.

## 7. Acceptable Use

Kruftle is free software and we place no restriction on running it. What
you do with it is nonetheless your responsibility: you are the one who must
have the right to delete what you point it at, and using it against
computer systems that are not yours may be a criminal offence where you
live. Do not redistribute modified copies in a way that breaches the GPL,
and do not represent a modified copy as an official Dizitart build.

## 8. No Warranty

**Kruftle is provided "as is", without warranty of any kind.** This
restates Sections 15, 16 and 17 of the GNU General Public License v3.0,
which govern, and adds nothing to your detriment.

To the fullest extent permitted by applicable law, Dizitart disclaims all
warranties, express or implied, including merchantability, fitness for a
particular purpose, and non-infringement. We do not warrant that the App
will be error-free, that it will correctly identify every project or build
tool, that its size estimates will match what is actually reclaimed, or
that it will never remove something you wanted to keep.

## 9. Limitation of Liability

To the fullest extent permitted by applicable law, Dizitart shall not be
liable for any indirect, incidental, special, consequential or punitive
damages, or for any **loss of data**, loss of work, loss of profits, or
cost of recovering or regenerating anything the App or a clean command it
invoked removed — however caused and on any theory of liability.

Because the App is supplied free of charge, there is no sum you have paid
us against which liability could be measured. Our total aggregate liability
to you for all claims relating to the App is therefore limited to **₹500**.

Nothing in these Terms excludes or limits any liability that cannot
lawfully be excluded or limited. That includes liability for death or
personal injury caused by negligence, for fraud or fraudulent
misrepresentation, for gross negligence or wilful misconduct, and any
liability under the consumer or product-liability law of your own country
that the law does not permit us to disclaim.

**If you are a consumer**, you have statutory rights that these Terms do
not affect, and nothing here is intended to reduce them. In particular,
where the law of your country gives you a remedy for damage caused to your
device or to your other data by software supplied to you free of charge,
this section does not take that remedy away.

## 10. Third-Party Tools

Kruftle runs your build tools' own clean commands — `cargo clean`,
`flutter clean`, `mvn clean` and the rest — in the project directory they
belong to, and reports what they printed. Those tools are not ours, are
governed by their own licences and terms, and are the property of their
respective owners. We are not responsible for their behaviour.

**Some of what runs comes from the project being cleaned, not from your
machine.** Where a project ships a build wrapper — `./gradlew` or
`./mvnw` — Kruftle runs that wrapper, because it is the version of the tool
the project expects. Where a Node project's `package.json` declares a
`clean` script, Kruftle runs that script. In both cases the code that
executes was written by whoever wrote that project, and it runs under your
user account with your permissions.

This matters if you scan a folder holding repositories you did not write.
Treat pointing Kruftle at somebody else's checkout the way you would treat
building it: do it only if you would have been willing to run its build in
the first place.

Names such as Cargo, Gradle, Flutter, Xcode and Unity are used only to
describe compatibility, and imply no affiliation with or endorsement by
their owners.

## 11. Changes to These Terms

We may update these Terms; the "Last updated" date above reflects the most
recent revision. Material changes will be noted in the App's changelog. The
current version always ships inside the App, under Settings → About → Terms
of Service, and is in the repository.

A revision applies to copies downloaded after it is published. The version
that shipped with your installed copy continues to govern that copy until
you update it — an offline copy with update checks switched off will never
see a revision, and is not bound by one it was never shown. Your rights
under the GPL are unaffected by any revision.

## 12. Termination

You may stop using Kruftle at any time by uninstalling it. Your rights
under the GPL survive that and survive anything we do. We may discontinue
publishing the App; if we do, your installed copy keeps working, and the
source remains available under the GPL for anyone who wants to continue it.

## 13. Export and Sanctions

Kruftle is distributed worldwide from GitHub. You are responsible for
complying with any export control or sanctions law that applies to you,
including any restriction on downloading or using software in an embargoed
territory. We do not restrict downloads ourselves; GitHub applies its own
controls.

## 14. If Something Goes Wrong

Before bringing any proceedings, please write to us at
**support@dizitart.com** with the details — what you were doing, what
happened, and the activity log if you still have it. We will acknowledge
and try to resolve the matter within 30 days. Most problems are faster to
fix than to litigate.

## 15. Governing Law

These Terms are governed by the laws of India, and the courts at Kolkata,
West Bengal shall have exclusive jurisdiction over any dispute arising out
of or in connection with them.

Nothing in this clause removes a protection that the law of your own
country gives you and does not permit you to give up. If you use the App as
a consumer rather than in the course of your trade or profession, and the
mandatory law of the country where you live gives you the right to bring
proceedings there or the benefit of that country's consumer protections,
that right is unaffected by this clause.

## 16. Severability and Entire Agreement

If any provision of these Terms is found to be unenforceable in a
particular jurisdiction, that provision applies to the fullest extent the
law there permits, and the remainder of these Terms continues in force.

These Terms, together with the Privacy Policy and the GNU General Public
License v3.0 or later, are the whole of the agreement between you and
Dizitart concerning the App.

## 17. Contact

Dizitart (sole proprietorship), Kolkata, West Bengal, India
Email: **support@dizitart.com**
