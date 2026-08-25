// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LDe extends L {
  LDe([String locale = 'de']) : super(locale);

  @override
  String get appTagline => 'Hol dir deinen Speicher zurück';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionShow => 'Anzeigen';

  @override
  String get actionClear => 'Leeren';

  @override
  String get actionAll => 'Alle';

  @override
  String get actionAllMatching => 'Alle Treffer';

  @override
  String get actionNone => 'Keine';

  @override
  String get actionBack => 'Zurück';

  @override
  String get actionNext => 'Weiter';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionSkip => 'Überspringen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get actionNotNow => 'Jetzt nicht';

  @override
  String get alreadyRunningTitle => 'Kruftle ist bereits geöffnet';

  @override
  String get alreadyRunningBody =>
      'Ein anderes Kruftle-Fenster läuft bereits. Wenn zwei gleichzeitig aufräumen, kann ein Build-Verzeichnis halb gelöscht zurückbleiben — dieses Fenster wird daher nicht geöffnet.';

  @override
  String get titleBarGlobalCaches => 'Globale SDK-Caches';

  @override
  String get titleBarSettings => 'Einstellungen';

  @override
  String get titleBarDiskUsage => 'Speicherbelegung';

  @override
  String get titleBarSchedule => 'Geplante Aufräumläufe';

  @override
  String get titleBarProfiles => 'Aufräumprofile';

  @override
  String get titleBarChangelog => 'Neuerungen';

  @override
  String get titleBarAbout => 'Über Kruftle';

  @override
  String get railFolder => 'Ordner';

  @override
  String get railScan => 'Suchen';

  @override
  String get railReview => 'Prüfen';

  @override
  String get railClean => 'Aufräumen';

  @override
  String get railReport => 'Bericht';

  @override
  String get sourceHeading => 'Welches Verzeichnis soll Kruftle durchsehen?';

  @override
  String get sourceSubheading =>
      'Alles darunter wird untersucht. Nichts wird angerührt, bis du es sagst.';

  @override
  String get sourceChooseFolder => 'Ordner auswählen';

  @override
  String get sourceChooseFolderHelp =>
      'Die Wurzel deines Codes oder jeder Ordner mit Projekten';

  @override
  String get sourceConfirmButton => 'Diesen Ordner durchsuchen';

  @override
  String get sourceRecent => 'Zuletzt verwendet';

  @override
  String get sourceForget => 'Aus der Liste entfernen';

  @override
  String get scanningLooking => 'Projekte werden gesucht';

  @override
  String get scanningMeasuring => 'Ihr Umfang wird gemessen';

  @override
  String get scanningProjectsFound => 'Projekte gefunden';

  @override
  String get scanningDirectoriesWalked => 'Verzeichnisse durchlaufen';

  @override
  String get scanningMeasured => 'gemessen';

  @override
  String get scanningNothingYet => 'Bisher nichts gefunden.';

  @override
  String get scanningStop => 'Suche anhalten';

  @override
  String get reviewScanAgain => 'Erneut suchen';

  @override
  String get reviewChangeFolder => 'Ordner wechseln';

  @override
  String reviewProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Projekte',
      one: '1 Projekt',
    );
    return '$_temp0';
  }

  @override
  String get reviewFilterHint =>
      'Nach Name, Pfad oder Technologie filtern   ( / )';

  @override
  String get reviewSortedBySize => 'Nach Größe sortiert';

  @override
  String get reviewSortedByPath => 'Nach Pfad sortiert';

  @override
  String get reviewNoProjects =>
      'In diesem Ordner gibt es keine Projekte mit Build-Ausgaben.';

  @override
  String reviewNoMatches(String query) {
    return 'Nichts passt zu „$query“.';
  }

  @override
  String reviewInSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count ausgewählten Projekten',
      one: 'in 1 ausgewählten Projekt',
    );
    return '$_temp0';
  }

  @override
  String get reviewMeasuredByDryRun => 'vom Probelauf gemessen';

  @override
  String reviewStillMeasuring(int percent) {
    return 'wird noch gemessen — $percent %';
  }

  @override
  String reviewFoundInTotal(String size, int count) {
    return '$size insgesamt in $count Projekten gefunden.';
  }

  @override
  String reviewPlanSummary(int steps, int projects) {
    return '$steps Schritte in $projects Projekten.';
  }

  @override
  String get reviewAlsoDelete => 'Auch direkt löschen';

  @override
  String get reviewAlsoDeleteHelp =>
      'Kruftle bevorzugt den eigenen Clean-Befehl jeder Toolchain. Diese Kategorien werden durch Löschen des Verzeichnisses entfernt und sind daher aus, sofern du nichts anderes sagst.';

  @override
  String get reviewRiskBuildOutput => 'Build-Ausgaben, wenn das SDK fehlt';

  @override
  String get reviewRiskBuildOutputHelp =>
      'Bei Projekten, deren Toolchain nicht installiert ist, wird stattdessen das bekannte Ausgabeverzeichnis gelöscht. Ein neuer Build stellt es wieder her.';

  @override
  String get reviewRiskDependencies => 'Heruntergeladene Abhängigkeiten';

  @override
  String get reviewRiskDependenciesHelp =>
      'node_modules, .venv, deps. Werden aus der Lockdatei wiederhergestellt, das kostet aber einen Download.';

  @override
  String get reviewRiskCache => 'Werkzeug-Caches';

  @override
  String get reviewRiskCacheHelp =>
      '.gradle, .turbo, .mypy_cache und Ähnliches. Kostet nur einen langsameren nächsten Build.';

  @override
  String get reviewMissingToolchains =>
      'Bei einigen ausgewählten Projekten ist kein SDK installiert. Ohne die erste Option oben werden sie übersprungen.';

  @override
  String reviewGitTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artefaktverzeichnisse werden',
      one: '1 Artefaktverzeichnis wird',
    );
    return '$_temp0 von git verfolgt und bleibt unangetastet. Bereits eingecheckte Inhalte zu löschen kann kein neuer Build rückgängig machen.';
  }

  @override
  String get reviewDryRun => 'Probelauf';

  @override
  String get reviewRemeasure => 'Neu messen';

  @override
  String get reviewCleanNow => 'Jetzt aufräumen';

  @override
  String get reviewDryRunNote =>
      'Ein Probelauf ändert nichts. Du kannst ihn überspringen.';

  @override
  String get reviewLargestDirectories => 'Wo der Speicher steckt';

  @override
  String get reviewLargestDirectoriesHelp =>
      'Die größten Artefaktverzeichnisse in diesem Ordner. Zeige auf einen Block, um seinen Pfad zu sehen.';

  @override
  String get confirmDeleteTitle => 'Diese Verzeichnisse löschen?';

  @override
  String get confirmDeleteIntro =>
      'Zusätzlich zum Clean-Befehl jeder Toolchain wird Kruftle löschen:';

  @override
  String get confirmCategoryBuildOutput =>
      'Build-Ausgabeverzeichnisse, wo das SDK fehlt';

  @override
  String get confirmCategoryDependencies =>
      'Verzeichnisse heruntergeladener Abhängigkeiten';

  @override
  String get confirmCategoryCache => 'Cache-Verzeichnisse von Werkzeugen';

  @override
  String confirmDeleteScope(int count, String folder) {
    return 'In $count ausgewählten Projekten unter $folder. Alles hiervon lässt sich neu erzeugen, und was git verfolgt, wird übersprungen.';
  }

  @override
  String get confirmDeleteAccept => 'Löschen und aufräumen';

  @override
  String get runningHeading => 'Wird aufgeräumt';

  @override
  String runningProgress(int done, int total) {
    return '$done von $total Schritten';
  }

  @override
  String get runningStop => 'Anhalten';

  @override
  String get reportStopped => 'Angehalten';

  @override
  String get reportDone => 'Fertig';

  @override
  String reportRanFor(String duration, int projects) {
    return 'Lief $duration über $projects Projekte.';
  }

  @override
  String get reportReclaimed => 'zurückgewonnen';

  @override
  String get reportStepsCompleted => 'Schritte erledigt';

  @override
  String get reportFailed => 'fehlgeschlagen';

  @override
  String get reportNothingToDo => 'nichts zu tun';

  @override
  String get reportRefused => 'abgelehnt';

  @override
  String reportUnderEstimate(String estimate) {
    return 'Der Probelauf schätzte $estimate. Clean-Befehle entscheiden selbst, was sie entfernen — manche behalten Caches, die der nächste Build wiederverwendet, und das ist meist genau richtig.';
  }

  @override
  String reportRefusedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ziele wurden',
      one: '1 Ziel wurde',
    );
    return '$_temp0 von einer Sicherheitsprüfung abgelehnt und unangetastet gelassen.';
  }

  @override
  String get reportWhatWentWrong => 'Was schiefging';

  @override
  String get reportNoDetail => 'Keine Einzelheiten gemeldet.';

  @override
  String get reportScanAgain => 'Erneut suchen';

  @override
  String get reportAnotherFolder => 'Anderer Ordner';

  @override
  String get reportExportLog => 'Protokoll exportieren';

  @override
  String reportLogExported(String name) {
    return 'Protokoll nach $name exportiert';
  }

  @override
  String get reportDiskBefore => 'vorher';

  @override
  String get reportDiskAfter => 'nachher';

  @override
  String reportDiskHeading(String volume, String free, String total) {
    return '$volume — $free frei von $total';
  }

  @override
  String get reportDiskUnavailable =>
      'Dieses Volume meldet seinen freien Speicher nicht.';

  @override
  String toolAvailable(String binary, String stack) {
    return '$binary ist installiert — $stack-Projekte werden mit ihrem eigenen Befehl aufgeräumt.';
  }

  @override
  String toolMissing(String binary) {
    return '$binary liegt nicht im PATH. Kruftle kann das nur durch Löschen des Build-Verzeichnisses aufräumen, und das braucht deine ausdrückliche Erlaubnis.';
  }

  @override
  String toolNotApplicable(String stack) {
    return '$stack hat keinen offiziellen Clean-Befehl.';
  }

  @override
  String get cachesTitle => 'Globale Caches';

  @override
  String get cachesRemeasure => 'Neu messen';

  @override
  String get cachesSortTooltip => 'Nach Größe sortieren';

  @override
  String get cachesSortLargest => 'Größte zuerst';

  @override
  String get cachesSortSmallest => 'Kleinste zuerst';

  @override
  String get cachesIntro =>
      'Diese Caches teilen sich alle Projekte auf diesem Rechner. Einen zu leeren schafft jetzt Platz und kostet später einen erneuten Download — verloren geht dabei nie etwas.';

  @override
  String cachesFreed(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Caches',
      one: '1 Cache',
    );
    return '$size aus $_temp0 freigegeben.';
  }

  @override
  String get cachesNoneFound =>
      'In deinem Benutzerordner wurden keine globalen Caches gefunden.';

  @override
  String get cachesSelected => 'ausgewählt';

  @override
  String get cachesEmptySelected => 'Auswahl leeren';

  @override
  String get cachesEmptying => 'Wird geleert…';

  @override
  String get cachesConfirmTitle => 'Diese Caches leeren?';

  @override
  String cachesConfirmBody(String size) {
    return 'Sie werden von allen Projekten auf diesem Rechner geteilt, nicht nur von dem zuletzt durchsuchten. Sie zu leeren gibt jetzt $size frei und kostet einen Download, sobald irgendein Projekt sie wieder braucht.';
  }

  @override
  String get cachesConfirmAccept => 'Leeren';

  @override
  String get cachesUsesCommand =>
      'Wird mit dem eigenen Befehl der Toolchain geleert statt durch Löschen von Dateien.';

  @override
  String get cachesUsesDelete =>
      'Für diesen Cache gibt es keinen offiziellen Befehl, also wird das Verzeichnis entfernt.';

  @override
  String get cachesDeleteTag => 'löschen';

  @override
  String updateAvailable(String version, String size) {
    return 'Kruftle $version ist verfügbar ($size).';
  }

  @override
  String updateDownloading(String version, int percent) {
    return '$version wird geladen… $percent %';
  }

  @override
  String updateReady(String version) {
    return 'Kruftle $version ist geprüft. Es wird jetzt installiert…';
  }

  @override
  String get updateFailed => 'Die Aktualisierung ist fehlgeschlagen.';

  @override
  String get updateAction => 'Aktualisieren';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionAppearance => 'Erscheinungsbild';

  @override
  String get settingsTheme => 'Erscheinungsbild';

  @override
  String get settingsThemeSystem => 'Wie das System';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Wie das System';

  @override
  String get settingsReduceMotion => 'Bewegung reduzieren';

  @override
  String get settingsReduceMotionHelp =>
      'Ersetzt die wischenden und pulsierenden Animationen durch einen einfachen Fortschritt. Wird auch automatisch beachtet, wenn das Betriebssystem weniger Bewegung verlangt.';

  @override
  String get settingsSectionScanning => 'Suche';

  @override
  String get settingsMaxDepth => 'Maximale Tiefe';

  @override
  String get settingsMaxDepthHelp =>
      'Wie weit unterhalb des gewählten Ordners gesucht wird. Tiefer findet mehr verschachtelte Projekte und dauert länger.';

  @override
  String settingsLevels(int count) {
    return '$count Ebenen';
  }

  @override
  String get settingsHiddenDirectories =>
      'Versteckte Verzeichnisse einbeziehen';

  @override
  String get settingsHiddenDirectoriesHelp =>
      'Ordner, die mit einem Punkt beginnen. Meist Editor-Zustand und Werkzeug-Caches statt Projekte.';

  @override
  String get settingsSectionCleaning => 'Aufräumen';

  @override
  String get settingsConcurrency => 'Projekte gleichzeitig';

  @override
  String settingsConcurrencyHelp(int cores) {
    return 'Clean-Befehle, die parallel laufen. Mehr ist schneller, bis die Festplatte zum Engpass wird. $cores Kerne verfügbar.';
  }

  @override
  String get settingsTimeout => 'Zeitlimit je Schritt';

  @override
  String get settingsTimeoutHelp =>
      'Ein Clean-Befehl, der länger läuft, wird beendet und gemeldet, damit ein hängendes Build-Werkzeug nicht den ganzen Lauf aufhält.';

  @override
  String settingsSeconds(int count) {
    return '$count Sekunden';
  }

  @override
  String settingsMinutes(int count) {
    return '$count Minuten';
  }

  @override
  String get settingsConfirmBeforeDelete => 'Vor dem Löschen bestätigen';

  @override
  String get settingsConfirmBeforeDeleteHelp =>
      'Zeigt einen Übersichtsdialog, sobald ein Lauf Verzeichnisse direkt löschen würde statt nur Clean-Befehle auszuführen.';

  @override
  String get settingsSectionPreselect => 'Diese Löschkategorien vorauswählen';

  @override
  String get settingsPreselectHelp =>
      'Nur eine Bequemlichkeit. Jeder Lauf zeigt sie weiterhin angehakt und fragt weiterhin, bevor irgendetwas gelöscht wird.';

  @override
  String get settingsSectionLogging => 'Protokollierung';

  @override
  String get settingsLogDetail => 'Ausführlichkeit';

  @override
  String get settingsLogDebug => 'Debug';

  @override
  String get settingsLogInfo => 'Info';

  @override
  String get settingsLogWarning => 'Warnung';

  @override
  String get settingsLogError => 'Fehler';

  @override
  String get settingsLogRetention => 'Aufbewahrte Protokolldateien';

  @override
  String get settingsLogRetentionHelp =>
      'Ältere Dateien werden entfernt, sobald das aktive Protokoll rotiert wird.';

  @override
  String get settingsNone => 'keine';

  @override
  String get settingsSectionUpdates => 'Aktualisierungen';

  @override
  String get settingsCheckUpdates => 'Automatisch nach Aktualisierungen suchen';

  @override
  String get settingsCheckUpdatesHelp =>
      'Kruftle fragt beim Start GitHub Releases und bietet einen geprüften Download an. Es installiert nie ungefragt.';

  @override
  String get settingsSectionSizes => 'Größen';

  @override
  String get settingsSizeMode => 'Wie Größen gezählt werden';

  @override
  String get settingsSizeModeOnDisk => 'Tatsächlich belegter Speicher';

  @override
  String get settingsSizeModeApparent => 'Gesamtlänge der Dateien';

  @override
  String get settingsSizeModeHelp =>
      'Der Wert auf der Platte entspricht dem, was das Betriebssystem meldet und was du zurückbekommst, samt Blockrundung und Dateisystemkomprimierung. Er braucht einen nativen Aufruf, den es unter Windows nicht gibt; dort werden Dateilängen verwendet.';

  @override
  String get settingsSectionAbout => 'Über';

  @override
  String get settingsShowTour => 'Funktionsübersicht erneut ansehen';

  @override
  String get settingsChangelog => 'Neuerungen in dieser Version';

  @override
  String get settingsPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get settingsTermsOfService => 'Nutzungsbedingungen';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsLicence =>
      'Freie Software unter der GNU General Public License v3.0 oder später.';

  @override
  String get settingsMadeWith => 'Mit ❤️ in Kalkutta, Indien gemacht';

  @override
  String get settingsSourceCode => 'Quellcode';

  @override
  String get tourWelcomeTitle => 'Willkommen bei Kruftle';

  @override
  String get tourWelcomeBody =>
      'Build-Artefakte sammeln sich still und leise an. Kruftle findet jedes Projekt auf deiner Platte, ermittelt, was es gebaut hat, und bittet diese Toolchain, hinter sich aufzuräumen.';

  @override
  String get tourWelcomeStart => 'Zeig es mir';

  @override
  String get tourWelcomeSkip => 'Übersicht überspringen';

  @override
  String get tourScanTitle => 'Richte es auf einen Ordner';

  @override
  String get tourScanBody =>
      'Wähle die Wurzel deines Codes. Kruftle durchläuft alles darunter und erkennt mehr als vierzig Sprachen und Build-Werkzeuge an den Dateien, die sie hinterlassen — auch Projekte, die in anderen Projekten stecken.';

  @override
  String get tourReviewTitle =>
      'Sieh, was gefunden wurde, bevor irgendetwas passiert';

  @override
  String get tourReviewBody =>
      'Jedes Projekt, jedes Artefaktverzeichnis und was es dich kostet — gemessen, nicht geraten. Hake ab, was aufgeräumt werden soll. Nichts wird angerührt, bis du es sagst.';

  @override
  String get tourSafetyTitle => 'Sicherheit ist nicht optional';

  @override
  String get tourSafetyBody =>
      'Kruftle bevorzugt den Clean-Befehl jeder Toolchain gegenüber dem Löschen von Dateien. Direktes Löschen ist auf eine Positivliste von Verzeichnisnamen beschränkt, folgt nie einem Symlink, verlässt den gewählten Ordner nicht und fragt immer zuerst. Was git verfolgt, bleibt unangetastet.';

  @override
  String get tourCachesTitle => 'Auch die Caches in deinem Benutzerordner';

  @override
  String get tourCachesBody =>
      'Cargos Registry, Gradles Caches, die von npm und pub — von allen Projekten geteilt und oft der größte Gewinn auf der Platte. Sie haben einen eigenen Bildschirm und eine eigene Bestätigung.';

  @override
  String get tourScheduleTitle => 'Einmal einstellen, dann vergessen';

  @override
  String get tourScheduleBody =>
      'Lass Kruftle täglich, wöchentlich oder monatlich aufräumen. Es kann dich erinnern, solange es offen ist, oder sich beim Planer deines Betriebssystems anmelden und den Lauf bei geschlossenem Kruftle erledigen.';

  @override
  String get tourFinishTitle => 'Das ist die ganze App';

  @override
  String get tourFinishBody =>
      'Alles läuft auf deinem Rechner. Nichts wird hochgeladen, und es gibt kein Konto anzulegen.';

  @override
  String get tourFinishAction => 'Los geht’s';

  @override
  String get scheduleTitle => 'Geplante Aufräumläufe';

  @override
  String get scheduleEnable => 'Ans Aufräumen erinnern';

  @override
  String get scheduleEnableHelp =>
      'Kruftle prüft während des Betriebs, ob ein Aufräumlauf fällig ist, und sagt beim Start Bescheid, wenn einer ausgefallen ist. Schalte unten Hintergrundläufe ein, damit es auch ohne geöffnetes Kruftle geschieht.';

  @override
  String get scheduleBackground => 'Auch bei geschlossenem Kruftle ausführen';

  @override
  String get scheduleBackgroundHelp =>
      'Legt einen Auftrag im Planer des Betriebssystems selbst an, sodass der Aufräumlauf zur gewählten Zeit läuft, egal ob Kruftle geöffnet ist. Er führt den Clean-Befehl jeder Toolchain aus und löscht nur die Kategorien, die du in den Einstellungen vorausgewählt hast.';

  @override
  String get scheduleBackgroundActive => 'Beim Systemplaner registriert.';

  @override
  String get scheduleBackgroundFailed =>
      'Dein System hat die Registrierung des Hintergrundauftrags abgelehnt. Die Erinnerung funktioniert weiterhin, solange Kruftle geöffnet ist.';

  @override
  String get scheduleFrequency => 'Wie oft';

  @override
  String get scheduleDaily => 'Täglich';

  @override
  String get scheduleWeekly => 'Wöchentlich';

  @override
  String get scheduleMonthly => 'Monatlich';

  @override
  String get scheduleTimeOfDay => 'Um';

  @override
  String get scheduleDayOfWeek => 'Am';

  @override
  String get scheduleDayOfMonth => 'Am Tag';

  @override
  String get scheduleFolder => 'Zu durchsuchender Ordner';

  @override
  String get scheduleChooseFolder => 'Ordner auswählen…';

  @override
  String scheduleNextRun(String when) {
    return 'Nächste Erinnerung $when.';
  }

  @override
  String get scheduleNeverRun => 'Es wurde noch nie aufgeräumt.';

  @override
  String scheduleLastRun(String when) {
    return 'Zuletzt aufgeräumt $when.';
  }

  @override
  String get scheduleDueTitle => 'Ein Aufräumlauf ist fällig';

  @override
  String scheduleDueBody(int days, String folder) {
    return 'Seit dem letzten unter $folder sind $days Tage vergangen.';
  }

  @override
  String get scheduleDueAction => 'Jetzt suchen';

  @override
  String get scheduleDueDismiss => 'Später';

  @override
  String get scheduleNotifyOnFinish =>
      'Benachrichtigen, wenn ein Aufräumlauf endet';

  @override
  String get scheduleNotificationDueTitle => 'Kruftle — Aufräumen fällig';

  @override
  String scheduleNotificationDueBody(String folder) {
    return 'Zeit, die Build-Artefakte aus $folder zu räumen.';
  }

  @override
  String scheduleNotificationDoneTitle(String size) {
    return 'Kruftle — $size zurückgewonnen';
  }

  @override
  String scheduleNotificationDoneBody(int projects, String duration) {
    return '$projects Projekte in $duration aufgeräumt.';
  }

  @override
  String get profilesTitle => 'Aufräumprofile';

  @override
  String get profilesIntro =>
      'Ein Profil bringt Kruftle eine Projektart bei, die es noch nicht kennt: welche Datei sie kennzeichnet, welcher Befehl sie aufräumt und welche Verzeichnisse es entfernen darf. Profile stehen gleichberechtigt neben den eingebauten Technologien und befolgen exakt dieselben Sicherheitsregeln.';

  @override
  String get profilesNone => 'Noch keine eigenen Profile.';

  @override
  String get profilesNew => 'Neues Profil';

  @override
  String get profilesImport => 'Importieren…';

  @override
  String get profilesExport => 'Exportieren…';

  @override
  String get profilesName => 'Name';

  @override
  String get profilesNameHint => 'Unreal Engine';

  @override
  String get profilesMarkers => 'Kennzeichnende Dateien';

  @override
  String get profilesMarkersHint => '*.uproject';

  @override
  String get profilesMarkersHelp =>
      'Ein Verzeichnis, das eine davon enthält, gilt als Projekt dieser Art. Eine pro Zeile. Punkt und Stern am Anfang treffen auf die Dateiendung zu.';

  @override
  String get profilesCommand => 'Clean-Befehl';

  @override
  String get profilesCommandHint => 'make clean';

  @override
  String get profilesCommandHelp =>
      'Wird mit dem Projektverzeichnis als Arbeitsverzeichnis ausgeführt. Leer lassen, um nur die Verzeichnisse unten zu löschen.';

  @override
  String get profilesArtifacts => 'Verzeichnisse, die entfernt werden dürfen';

  @override
  String get profilesArtifactsHint => 'Binaries\nIntermediate';

  @override
  String get profilesArtifactsHelp =>
      'Eines pro Zeile, relativ zur Projektwurzel. Das ist eine Positivliste: nichts außerhalb wird je gelöscht, und Löschen braucht weiterhin deine Bestätigung bei jedem Lauf.';

  @override
  String get profilesExcludes => 'Diese Pfade nie durchsuchen';

  @override
  String get profilesExcludesHint => '**/vendor/**';

  @override
  String get profilesExcludesHelp =>
      'Glob-Muster. Passende Verzeichnisse werden vollständig übersprungen, von jedem Profil und jeder eingebauten Technologie.';

  @override
  String get profilesEnabled => 'Aktiv';

  @override
  String profilesDeleteConfirm(String name) {
    return 'Profil „$name“ löschen?';
  }

  @override
  String get profilesErrorName => 'Gib dem Profil einen Namen.';

  @override
  String get profilesErrorMarkers =>
      'Ein Profil braucht mindestens eine kennzeichnende Datei, sonst würde es auf jeden Ordner passen.';

  @override
  String get profilesErrorNothingToDo =>
      'Gib dem Profil einen Clean-Befehl, ein paar zu entfernende Verzeichnisse, oder beides.';

  @override
  String profilesErrorAbsolutePath(String path) {
    return 'Verzeichnisse müssen relativ zur Projektwurzel sein: „$path“ ist es nicht.';
  }

  @override
  String profilesErrorEscapes(String path) {
    return '„$path“ zeigt aus dem Projekt heraus. Das ist nie zulässig.';
  }

  @override
  String profilesErrorDuplicate(String name) {
    return 'Ein Profil namens „$name“ existiert bereits.';
  }

  @override
  String get profilesImportFailed =>
      'Diese Datei ist kein Kruftle-Profilexport.';

  @override
  String profilesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Profile importiert.',
      one: '1 Profil importiert.',
    );
    return '$_temp0';
  }

  @override
  String get diskTitle => 'Speicherbelegung';

  @override
  String get diskVolume => 'Volume';

  @override
  String get diskUsed => 'belegt';

  @override
  String get diskFree => 'frei';

  @override
  String get diskReclaimable => 'zurückgewinnbar';

  @override
  String diskOfTotal(String used, String total) {
    return '$used von $total belegt';
  }

  @override
  String diskFreedThisRun(String size) {
    return '$size freigegeben';
  }

  @override
  String get diskTreemapEmpty => 'Noch nichts gemessen.';

  @override
  String get changelogTitle => 'Neuerungen';

  @override
  String changelogVersionHeading(String version) {
    return 'Version $version';
  }

  @override
  String get changelogUnavailable =>
      'Die Änderungsliste konnte nicht gelesen werden.';

  @override
  String get changelogAdded => 'Neu';

  @override
  String get changelogChanged => 'Geändert';

  @override
  String get changelogFixed => 'Behoben';

  @override
  String changelogWhatsNewBanner(String version) {
    return 'Kruftle wurde auf $version aktualisiert.';
  }

  @override
  String get changelogWhatsNewAction => 'Ansehen, was sich geändert hat';

  @override
  String get legalPrivacyTitle => 'Datenschutzerklärung';

  @override
  String get legalTermsTitle => 'Nutzungsbedingungen';

  @override
  String get legalUnavailable => 'Dieses Dokument konnte nicht geladen werden.';

  @override
  String get legalOpenInBrowser => 'Im Browser öffnen';

  @override
  String get consentTitle => 'Bedingungen & Datenschutz';

  @override
  String get consentBody =>
      'Kruftle führt den Clean-Befehl jeder Toolchain aus und löscht damit Build-Ausgaben von diesem Rechner. Lies vor dem Start die Nutzungsbedingungen und die Datenschutzerklärung — mit dem Fortfahren akzeptierst du beide.';

  @override
  String get consentAccept => 'Akzeptieren und fortfahren';

  @override
  String get consentDecline => 'Ablehnen und beenden';
}
