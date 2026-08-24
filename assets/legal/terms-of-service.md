# Terms of Service

**Last updated:** 2026-08-24

These Terms of Service ("Terms") govern your use of the Kruftle desktop
application ("Kruftle", "the App"), provided by **Dizitart**, a sole
proprietorship registered in Kolkata, West Bengal, India ("Dizitart", "we",
"us", "our"). By downloading, installing, or using the App you agree to
these Terms. If you do not agree, do not use the App.

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
fact, and you should read Sections 3 and 8 before you use it in anger.

It runs entirely on your computer. There are no accounts, no subscriptions,
no purchases and no server.

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

**Kruftle takes real precautions, and they are not a guarantee.** The App
refuses to scan or clean the filesystem root, your home directory, or
system directories; it never follows a symbolic link; it never removes
anything outside the folder you chose; raw deletion is limited to an
allow-list of directory names belonging to a positively identified project
type; and anything git is tracking is excluded from the plan, because
deleting committed content is not something a rebuild undoes. Each of these
rules has a test that fails closed. They exist because we take this
seriously.

They are still not a promise that nothing you value will be removed. A
build directory can contain something irreplaceable that you put there. A
clean command belonging to somebody else's build tool can do more than you
expected. A cleanup profile you write yourself points Kruftle at whatever
you tell it to point at.

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
- You are responsible for having the right to delete what you point the App
  at, including on shared or work machines.

## 4. Cost

Kruftle is free. There is no paid tier, no subscription, no trial that
lapses, no in-app purchase and no advertising. There is nothing to cancel
and no payment method to give us. If you ever encounter a copy of Kruftle
that asks you to pay, it did not come from us.

## 5. Updates

When update checks are enabled, Kruftle asks GitHub whether a newer release
exists, and offers it. It verifies any download against the SHA-256
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

Do not use Kruftle to delete data you do not have the right to delete. Do
not use it to interfere with computer systems that are not yours. Do not
redistribute modified copies in a way that breaches the GPL, and do not
represent a modified copy as an official Dizitart build.

## 8. No Warranty

**Kruftle is provided "as is", without warranty of any kind.** This
restates Sections 15 and 16 of the GNU General Public License v3.0, which
govern, and adds nothing to your detriment.

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

Because the App is supplied free of charge, our aggregate liability to you
for all claims relating to it is limited to **zero**, save that nothing in
these Terms excludes or limits liability that cannot lawfully be excluded
or limited — including liability for death or personal injury caused by
negligence, or for fraud.

**If you are a consumer**, you have statutory rights that these Terms do
not affect, and nothing here is intended to reduce them.

## 10. Third-Party Tools

Kruftle invokes build tools already installed on your computer — Cargo,
Gradle, npm, and the rest. Those tools are not ours, are governed by their
own licences and terms, and are the property of their respective owners.
Kruftle only asks them to run their own documented clean command, in their
own project directory, and reports what they printed. We are not
responsible for their behaviour.

Names such as Cargo, Gradle, Flutter, Xcode and Unity are used only to
describe compatibility, and imply no affiliation with or endorsement by
their owners.

## 11. Changes to These Terms

We may update these Terms; the "Last updated" date above reflects the most
recent revision. Material changes will be noted in the App's changelog. The
current version always ships inside the App, under Settings → About → Terms
of Service, and is in the repository. Continuing to use the App after a
change means you accept the revised Terms.

## 12. Termination

You may stop using Kruftle at any time by uninstalling it. Your rights
under the GPL survive that and survive anything we do. We may discontinue
publishing the App; if we do, your installed copy keeps working, and the
source remains available under the GPL for anyone who wants to continue it.

## 13. Governing Law and Contact

These Terms are governed by the laws of India, and the courts at Kolkata,
West Bengal shall have jurisdiction — save that if you are a consumer
resident elsewhere, you retain the benefit of any mandatory protections and
any right to bring proceedings in the courts of your own country.

Dizitart (sole proprietorship), Kolkata, West Bengal, India
Email: **support@dizitart.com**
