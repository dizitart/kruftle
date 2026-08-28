// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class LFr extends L {
  LFr([String locale = 'fr']) : super(locale);

  @override
  String get appTagline => 'Récupérez votre disque';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionShow => 'Afficher';

  @override
  String get actionClear => 'Vider';

  @override
  String get actionAll => 'Tout';

  @override
  String get actionAllMatching => 'Tous les résultats';

  @override
  String get actionNone => 'Aucun';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionNext => 'Suivant';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionSkip => 'Passer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionNotNow => 'Pas maintenant';

  @override
  String get alreadyRunningTitle => 'Kruftle est déjà ouvert';

  @override
  String get alreadyRunningBody =>
      'Une autre fenêtre de Kruftle est en cours d’exécution. Si deux nettoient en même temps, un répertoire de compilation peut rester à moitié supprimé : cette fenêtre ne s’ouvrira donc pas.';

  @override
  String get titleBarGlobalCaches => 'Caches SDK globaux';

  @override
  String get titleBarSettings => 'Réglages';

  @override
  String get titleBarDiskUsage => 'Utilisation du disque';

  @override
  String get titleBarSchedule => 'Nettoyages planifiés';

  @override
  String get titleBarProfiles => 'Profils de nettoyage';

  @override
  String get titleBarChangelog => 'Nouveautés';

  @override
  String get titleBarAbout => 'À propos de Kruftle';

  @override
  String get railFolder => 'Dossier';

  @override
  String get railScan => 'Analyse';

  @override
  String get railReview => 'Vérification';

  @override
  String get railClean => 'Nettoyage';

  @override
  String get railReport => 'Rapport';

  @override
  String get sourceHeading => 'Quel répertoire Kruftle doit-il parcourir ?';

  @override
  String get sourceSubheading =>
      'Tout ce qui se trouve en dessous est examiné. Rien n’est touché tant que vous ne l’avez pas dit.';

  @override
  String get sourceChooseFolder => 'Choisissez un dossier';

  @override
  String get sourceChooseFolderHelp =>
      'La racine de votre code, ou n’importe quel dossier contenant des projets';

  @override
  String get sourceConfirmButton => 'Analyser ce dossier';

  @override
  String get sourceRecent => 'Récents';

  @override
  String get sourceForget => 'Retirer des récents';

  @override
  String get sourceShallowTitle => 'Analyser ce chemin malgré tout ?';

  @override
  String get sourceShallowReason =>
      'Il se trouve près de la racine de son disque. Kruftle le refuse par défaut, car un chemin aussi court est généralement une erreur — mais sur un lecteur réseau connecté ou un volume monté, c\'est justement là que vit une base de code. À vous de voir.';

  @override
  String get sourceShallowReadOnly =>
      'L\'analyse ne fait que lire. Elle ne supprime, ne déplace et ne modifie rien.';

  @override
  String get sourceShallowChoice =>
      'Vous choisissez ensuite ce qu\'il faut nettoyer, projet par projet, et vous confirmez à nouveau avant toute suppression.';

  @override
  String get sourceShallowStillRefused =>
      'Les répertoires système et personnels restent refusés quoi que vous choisissiez ici, et cette réponse n\'est pas mémorisée.';

  @override
  String get sourceShallowAccept => 'Analyser quand même';

  @override
  String get scanningLooking => 'Recherche des projets';

  @override
  String get scanningMeasuring => 'Mesure de leur contenu';

  @override
  String get scanningProjectsFound => 'projets trouvés';

  @override
  String get scanningDirectoriesWalked => 'répertoires parcourus';

  @override
  String get scanningMeasured => 'mesuré';

  @override
  String get scanningNothingYet => 'Rien trouvé pour l’instant.';

  @override
  String get scanningStop => 'Arrêter l’analyse';

  @override
  String get reviewScanAgain => 'Analyser à nouveau';

  @override
  String get reviewChangeFolder => 'Changer de dossier';

  @override
  String reviewProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projets',
      one: '1 projet',
    );
    return '$_temp0';
  }

  @override
  String get reviewFilterHint =>
      'Filtrer par nom, chemin ou technologie   ( / )';

  @override
  String get reviewSortedBySize => 'Trié par taille';

  @override
  String get reviewSortedByPath => 'Trié par chemin';

  @override
  String get reviewNoProjects =>
      'Aucun projet avec des fichiers de compilation dans ce dossier.';

  @override
  String reviewNoMatches(String query) {
    return 'Rien ne correspond à « $query ».';
  }

  @override
  String reviewInSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dans $count projets sélectionnés',
      one: 'dans 1 projet sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get reviewMeasuredByDryRun => 'mesuré par la simulation';

  @override
  String reviewStillMeasuring(int percent) {
    return 'mesure en cours — $percent %';
  }

  @override
  String reviewFoundInTotal(String size, int count) {
    return '$size au total dans $count projets.';
  }

  @override
  String reviewPlanSummary(int steps, int projects) {
    return '$steps étapes dans $projects projets.';
  }

  @override
  String get reviewAlsoDelete => 'Supprimer aussi directement';

  @override
  String get reviewAlsoDeleteHelp =>
      'Kruftle privilégie la commande de nettoyage propre à chaque outil. Ces catégories sont retirées en supprimant le répertoire, elles sont donc désactivées sauf indication contraire.';

  @override
  String get reviewRiskBuildOutput =>
      'Résultats de compilation quand le SDK est absent';

  @override
  String get reviewRiskBuildOutputHelp =>
      'Pour les projets dont l’outil n’est pas installé, le répertoire de sortie connu est supprimé à la place. Recompiler le restaure.';

  @override
  String get reviewRiskDependencies => 'Dépendances téléchargées';

  @override
  String get reviewRiskDependenciesHelp =>
      'node_modules, .venv, deps. Restaurées depuis le fichier de verrouillage, mais cela coûte un téléchargement.';

  @override
  String get reviewRiskCache => 'Caches d’outils';

  @override
  String get reviewRiskCacheHelp =>
      '.gradle, .turbo, .mypy_cache et compagnie. Le seul coût est une compilation suivante plus lente.';

  @override
  String get reviewMissingToolchains =>
      'Certains projets sélectionnés n’ont pas de SDK installé. Sans la première option ci-dessus, ils seront ignorés.';

  @override
  String reviewGitTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count répertoires d’artefacts sont suivis',
      one: '1 répertoire d’artefacts est suivi',
    );
    return '$_temp0 par git et sera laissé intact. Supprimer du contenu déjà validé n’est pas quelque chose qu’une recompilation peut annuler.';
  }

  @override
  String get reviewDryRun => 'Simulation';

  @override
  String get reviewRemeasure => 'Remesurer';

  @override
  String get reviewCleanNow => 'Nettoyer maintenant';

  @override
  String get reviewDryRunNote =>
      'Une simulation ne change rien. Vous pouvez la passer.';

  @override
  String get reviewLargestDirectories => 'Où se trouve l’espace';

  @override
  String get reviewLargestDirectoriesHelp =>
      'Les plus gros répertoires d’artefacts de ce dossier. Survolez un bloc pour voir son chemin.';

  @override
  String get confirmDeleteTitle => 'Supprimer ces répertoires ?';

  @override
  String get confirmDeleteIntro =>
      'En plus d’exécuter la commande de nettoyage de chaque outil, Kruftle va supprimer :';

  @override
  String get confirmCategoryBuildOutput =>
      'les répertoires de compilation là où le SDK est absent';

  @override
  String get confirmCategoryDependencies =>
      'les répertoires de dépendances téléchargées';

  @override
  String get confirmCategoryCache => 'les répertoires de cache d’outils';

  @override
  String confirmDeleteScope(int count, String folder) {
    return 'Dans $count projets sélectionnés sous $folder. Tout ceci est régénérable, et ce que git suit est ignoré.';
  }

  @override
  String get confirmDeleteAccept => 'Supprimer et nettoyer';

  @override
  String get runningHeading => 'Nettoyage';

  @override
  String runningProgress(int done, int total) {
    return '$done étapes sur $total';
  }

  @override
  String get runningStop => 'Arrêter';

  @override
  String get reportStopped => 'Interrompu';

  @override
  String get reportDone => 'Terminé';

  @override
  String reportRanFor(String duration, int projects) {
    return 'A duré $duration sur $projects projets.';
  }

  @override
  String get reportReclaimed => 'récupérés';

  @override
  String get reportStepsCompleted => 'étapes terminées';

  @override
  String get reportFailed => 'en échec';

  @override
  String get reportNothingToDo => 'rien à faire';

  @override
  String get reportRefused => 'refusées';

  @override
  String reportUnderEstimate(String estimate) {
    return 'La simulation avait estimé $estimate. Les commandes de nettoyage décident elles-mêmes de ce qu’elles retirent — certaines gardent des caches que la compilation suivante réutilise, ce qui est généralement souhaitable.';
  }

  @override
  String reportRefusedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cibles ont été refusées',
      one: '1 cible a été refusée',
    );
    return '$_temp0 par un contrôle de sécurité et laissées intactes.';
  }

  @override
  String get reportWhatWentWrong => 'Ce qui a échoué';

  @override
  String get reportNoDetail => 'Aucun détail signalé.';

  @override
  String get reportScanAgain => 'Analyser à nouveau';

  @override
  String get reportAnotherFolder => 'Un autre dossier';

  @override
  String get reportExportLog => 'Exporter le journal';

  @override
  String reportLogExported(String name) {
    return 'Journal exporté vers $name';
  }

  @override
  String get reportDiskBefore => 'avant';

  @override
  String get reportDiskAfter => 'après';

  @override
  String reportDiskHeading(String volume, String free, String total) {
    return '$volume — $free libres sur $total';
  }

  @override
  String get reportDiskUnavailable =>
      'Ce volume n’indique pas son espace libre.';

  @override
  String toolAvailable(String binary, String stack) {
    return '$binary est installé — les projets $stack seront nettoyés avec leur propre commande.';
  }

  @override
  String toolMissing(String binary) {
    return '$binary n’est pas dans le PATH. Kruftle ne peut nettoyer cela qu’en supprimant le répertoire de compilation, ce qui exige votre autorisation explicite.';
  }

  @override
  String toolNotApplicable(String stack) {
    return '$stack n’a pas de commande de nettoyage officielle.';
  }

  @override
  String get cachesTitle => 'Caches globaux';

  @override
  String get cachesRemeasure => 'Remesurer';

  @override
  String get cachesSortTooltip => 'Trier par taille';

  @override
  String get cachesSortLargest => 'Les plus gros d’abord';

  @override
  String get cachesSortSmallest => 'Les plus petits d’abord';

  @override
  String get cachesIntro =>
      'Ces caches sont partagés par tous les projets de cette machine. En vider un libère de l’espace maintenant et coûte un téléchargement plus tard — cela ne perd jamais de travail.';

  @override
  String cachesFreed(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caches',
      one: '1 cache',
    );
    return '$size libérés depuis $_temp0.';
  }

  @override
  String get cachesNoneFound =>
      'Aucun cache global trouvé dans votre dossier personnel.';

  @override
  String get cachesSelected => 'sélectionnés';

  @override
  String get cachesEmptySelected => 'Vider la sélection';

  @override
  String get cachesEmptying => 'Vidage…';

  @override
  String get cachesConfirmTitle => 'Vider ces caches ?';

  @override
  String cachesConfirmBody(String size) {
    return 'Ils sont partagés par tous les projets de cette machine, pas seulement celui que vous avez analysé en dernier. Les vider libère $size maintenant et coûte un téléchargement la prochaine fois qu’un projet en aura besoin.';
  }

  @override
  String get cachesConfirmAccept => 'Les vider';

  @override
  String get cachesUsesCommand =>
      'Vidé avec la commande propre à l’outil plutôt qu’en supprimant des fichiers.';

  @override
  String get cachesUsesDelete =>
      'Aucune commande officielle pour ce cache, le répertoire est donc retiré.';

  @override
  String get cachesDeleteTag => 'supprimer';

  @override
  String updateAvailable(String version, String size) {
    return 'Kruftle $version est disponible ($size).';
  }

  @override
  String updateDownloading(String version, int percent) {
    return 'Téléchargement de $version… $percent %';
  }

  @override
  String updateReady(String version) {
    return 'Kruftle $version est prêt. Redémarrez pour terminer.';
  }

  @override
  String get updateFailed => 'La mise à jour a échoué.';

  @override
  String get updateAction => 'Mettre à jour';

  @override
  String get updateRestart => 'Redémarrer maintenant';

  @override
  String get updateChecking => 'Recherche de mises à jour…';

  @override
  String get updateUpToDate => 'Kruftle est à jour.';

  @override
  String updateReadyInstall(String version) {
    return 'Kruftle $version est prêt à être installé.';
  }

  @override
  String updateNoBuild(String version) {
    return 'Kruftle $version est disponible, mais cette installation n\'a aucune version qu\'elle puisse utiliser. Voir le journal d\'activité.';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSectionAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeSystem => 'Suivre le système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Suivre le système';

  @override
  String get settingsReduceMotion => 'Réduire les animations';

  @override
  String get settingsReduceMotionHelp =>
      'Remplace les animations de balayage et de pulsation par une progression simple. Également respecté automatiquement quand le système demande des animations réduites.';

  @override
  String get settingsSectionScanning => 'Analyse';

  @override
  String get settingsMaxDepth => 'Profondeur maximale';

  @override
  String get settingsMaxDepthHelp =>
      'Jusqu’où descendre sous le dossier choisi. Plus profond trouve davantage de projets imbriqués et prend plus de temps.';

  @override
  String settingsLevels(int count) {
    return '$count niveaux';
  }

  @override
  String get settingsHiddenDirectories => 'Inclure les répertoires cachés';

  @override
  String get settingsHiddenDirectoriesHelp =>
      'Les dossiers commençant par un point. Le plus souvent l’état de l’éditeur et des caches d’outils, pas des projets.';

  @override
  String get settingsSectionCleaning => 'Nettoyage';

  @override
  String get settingsConcurrency => 'Projets simultanés';

  @override
  String settingsConcurrencyHelp(int cores) {
    return 'Commandes de nettoyage exécutées en parallèle. Plus il y en a, plus c’est rapide, jusqu’à ce que le disque devienne le goulot d’étranglement. $cores cœurs disponibles.';
  }

  @override
  String get settingsTimeout => 'Délai par étape';

  @override
  String get settingsTimeoutHelp =>
      'Une commande de nettoyage qui dépasse ce délai est arrêtée et signalée, pour qu’un outil bloqué ne retienne pas toute l’exécution.';

  @override
  String settingsSeconds(int count) {
    return '$count secondes';
  }

  @override
  String settingsMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get settingsConfirmBeforeDelete => 'Confirmer avant de supprimer';

  @override
  String get settingsConfirmBeforeDeleteHelp =>
      'Affiche une boîte de dialogue récapitulative dès qu’une exécution supprimera des répertoires directement au lieu de seulement lancer des commandes de nettoyage.';

  @override
  String get settingsSectionPreselect =>
      'Présélectionner ces catégories de suppression';

  @override
  String get settingsPreselectHelp =>
      'Une simple commodité. Chaque exécution les affiche toujours cochées et demande toujours avant de supprimer quoi que ce soit.';

  @override
  String get settingsSectionLogging => 'Journalisation';

  @override
  String get settingsLogDetail => 'Niveau de détail';

  @override
  String get settingsLogDebug => 'Débogage';

  @override
  String get settingsLogInfo => 'Information';

  @override
  String get settingsLogWarning => 'Avertissement';

  @override
  String get settingsLogError => 'Erreur';

  @override
  String get settingsLogRetention => 'Fichiers de journal conservés';

  @override
  String get settingsLogRetentionHelp =>
      'Les fichiers plus anciens sont supprimés dès que le journal actif est archivé.';

  @override
  String get settingsNone => 'aucun';

  @override
  String get settingsSectionUpdates => 'Mises à jour';

  @override
  String get settingsCheckUpdates =>
      'Vérifier les mises à jour automatiquement';

  @override
  String get settingsCheckUpdatesHelp =>
      'Kruftle interroge GitHub Releases au démarrage et propose un téléchargement vérifié. Il n’installe jamais sans demander.';

  @override
  String get settingsCheckNow => 'Rechercher des mises à jour maintenant';

  @override
  String get settingsSectionSizes => 'Tailles';

  @override
  String get settingsSizeMode => 'Comment les tailles sont comptées';

  @override
  String get settingsSizeModeOnDisk => 'Espace réellement occupé sur le disque';

  @override
  String get settingsSizeModeApparent => 'Longueur totale des fichiers';

  @override
  String get settingsSizeModeHelp =>
      'La valeur sur disque correspond à ce que rapporte le système et à ce que vous récupérez, arrondi par blocs et compression du système de fichiers compris. Elle nécessite un appel natif indisponible sous Windows, qui se rabat sur la longueur des fichiers.';

  @override
  String get settingsSectionAbout => 'À propos';

  @override
  String get settingsShowTour => 'Revoir la visite des fonctionnalités';

  @override
  String get settingsChangelog => 'Nouveautés de cette version';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsTermsOfService => 'Conditions d’utilisation';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsLicence =>
      'Logiciel libre sous licence publique générale GNU v3.0 ou ultérieure.';

  @override
  String get settingsMadeWith => 'Fait avec ❤️ à Calcutta, Inde';

  @override
  String get settingsSourceCode => 'Code source';

  @override
  String get settingsWebsite => 'Site web de Kruftle';

  @override
  String get tourWelcomeTitle => 'Bienvenue dans Kruftle';

  @override
  String get tourWelcomeBody =>
      'Les fichiers de compilation s’accumulent en silence. Kruftle trouve chaque projet de votre disque, détermine ce qui l’a compilé, et demande à cet outil de nettoyer derrière lui.';

  @override
  String get tourWelcomeStart => 'Faites-moi visiter';

  @override
  String get tourWelcomeSkip => 'Passer la visite';

  @override
  String get tourScanTitle => 'Pointez-le vers un dossier';

  @override
  String get tourScanBody =>
      'Choisissez la racine de votre code. Kruftle parcourt tout ce qui se trouve en dessous et reconnaît plus de quarante langages et outils de compilation aux fichiers qu’ils laissent — y compris les projets imbriqués dans d’autres projets.';

  @override
  String get tourReviewTitle =>
      'Voyez ce qu’il a trouvé avant que quoi que ce soit n’arrive';

  @override
  String get tourReviewBody =>
      'Chaque projet, chaque répertoire d’artefacts, et ce que chacun vous coûte — mesuré, pas deviné. Cochez ce que vous voulez nettoyer. Rien n’est touché tant que vous ne l’avez pas dit.';

  @override
  String get tourSafetyTitle => 'La sécurité n’est pas facultative';

  @override
  String get tourSafetyBody =>
      'Kruftle préfère la commande de nettoyage de chaque outil à la suppression de fichiers. La suppression directe se limite à une liste blanche de noms de répertoires, ne suit jamais un lien symbolique, refuse de quitter le dossier que vous avez choisi, et demande toujours d’abord. Ce que git suit reste intact.';

  @override
  String get tourCachesTitle =>
      'Et les caches de votre dossier personnel aussi';

  @override
  String get tourCachesBody =>
      'Le registre de Cargo, les caches de Gradle, ceux de npm et de pub — partagés par tous les projets et souvent le plus gros gain sur le disque. Ils ont leur propre écran et leur propre confirmation.';

  @override
  String get tourScheduleTitle => 'Réglez-le et oubliez-le';

  @override
  String get tourScheduleBody =>
      'Faites nettoyer Kruftle chaque jour, chaque semaine ou chaque mois. Il peut vous le rappeler quand il est ouvert, ou s’enregistrer auprès du planificateur de votre système d’exploitation et faire le ménage Kruftle fermé.';

  @override
  String get tourFinishTitle => 'Voilà toute l’application';

  @override
  String get tourFinishBody =>
      'Tout s’exécute sur votre machine. Rien n’est envoyé, et il n’y a aucun compte à créer.';

  @override
  String get tourFinishAction => 'Commencer';

  @override
  String get scheduleTitle => 'Nettoyages planifiés';

  @override
  String get scheduleEnable => 'Me rappeler de nettoyer';

  @override
  String get scheduleEnableHelp =>
      'Kruftle vérifie si un nettoyage est dû pendant qu’il fonctionne, et vous prévient au lancement si l’un a été manqué. Activez ci-dessous les exécutions en arrière-plan pour que cela se produise sans Kruftle ouvert.';

  @override
  String get scheduleBackground => 'Exécuter même quand Kruftle est fermé';

  @override
  String get scheduleBackgroundHelp =>
      'Enregistre une tâche auprès du planificateur du système d’exploitation, de sorte que le nettoyage s’exécute à l’heure choisie, que Kruftle soit ouvert ou non. Il lance la commande de nettoyage de chaque chaîne d’outils et ne supprime que les catégories présélectionnées dans les Réglages.';

  @override
  String get scheduleBackgroundActive =>
      'Enregistré auprès du planificateur du système.';

  @override
  String get scheduleBackgroundFailed =>
      'Votre système a refusé d’enregistrer la tâche en arrière-plan. Le rappel fonctionne toujours lorsque Kruftle est ouvert.';

  @override
  String get scheduleFrequency => 'À quelle fréquence';

  @override
  String get scheduleDaily => 'Chaque jour';

  @override
  String get scheduleWeekly => 'Chaque semaine';

  @override
  String get scheduleMonthly => 'Chaque mois';

  @override
  String get scheduleTimeOfDay => 'À';

  @override
  String get scheduleDayOfWeek => 'Le';

  @override
  String get scheduleDayOfMonth => 'Le jour';

  @override
  String get scheduleFolder => 'Dossier à analyser';

  @override
  String get scheduleChooseFolder => 'Choisir un dossier…';

  @override
  String scheduleNextRun(String when) {
    return 'Prochain rappel $when.';
  }

  @override
  String get scheduleNeverRun => 'Aucun nettoyage n’a encore eu lieu.';

  @override
  String scheduleLastRun(String when) {
    return 'Dernier nettoyage $when.';
  }

  @override
  String get scheduleDueTitle => 'Un nettoyage est dû';

  @override
  String scheduleDueBody(int days, String folder) {
    return 'Cela fait $days jours depuis le dernier sous $folder.';
  }

  @override
  String get scheduleDueAction => 'Analyser maintenant';

  @override
  String get scheduleDueDismiss => 'Plus tard';

  @override
  String get scheduleNotifyOnFinish =>
      'Me prévenir quand un nettoyage se termine';

  @override
  String get scheduleNotificationDueTitle => 'Kruftle — nettoyage dû';

  @override
  String scheduleNotificationDueBody(String folder) {
    return 'Il est temps de sortir les fichiers de compilation de $folder.';
  }

  @override
  String scheduleNotificationDoneTitle(String size) {
    return 'Kruftle — $size récupérés';
  }

  @override
  String scheduleNotificationDoneBody(int projects, String duration) {
    return '$projects projets nettoyés en $duration.';
  }

  @override
  String get profilesTitle => 'Profils de nettoyage';

  @override
  String get profilesIntro =>
      'Un profil apprend à Kruftle un type de projet qu’il ne connaît pas encore : quel fichier le signale, quelle commande le nettoie, et quels répertoires il peut retirer. Les profils côtoient les technologies intégrées et obéissent exactement aux mêmes règles de sécurité.';

  @override
  String get profilesNone => 'Aucun profil personnalisé pour l’instant.';

  @override
  String get profilesNew => 'Nouveau profil';

  @override
  String get profilesImport => 'Importer…';

  @override
  String get profilesExport => 'Exporter…';

  @override
  String get profilesName => 'Nom';

  @override
  String get profilesNameHint => 'Unreal Engine';

  @override
  String get profilesMarkers => 'Fichiers repères';

  @override
  String get profilesMarkersHint => '*.uproject';

  @override
  String get profilesMarkersHelp =>
      'Un répertoire contenant l’un d’eux est traité comme ce type de projet. Un par ligne. Un point suivi d’une étoile correspond par extension.';

  @override
  String get profilesCommand => 'Commande de nettoyage';

  @override
  String get profilesCommandHint => 'make clean';

  @override
  String get profilesCommandHelp =>
      'Exécutée avec le répertoire du projet comme répertoire de travail. Laissez vide pour seulement supprimer les répertoires ci-dessous.';

  @override
  String get profilesArtifacts => 'Répertoires qu’il peut retirer';

  @override
  String get profilesArtifactsHint => 'Binaries\nIntermediate';

  @override
  String get profilesArtifactsHelp =>
      'Un par ligne, relatifs à la racine du projet. C’est une liste blanche : rien en dehors n’est jamais supprimé, et la suppression exige toujours votre confirmation à chaque exécution.';

  @override
  String get profilesExcludes => 'Ne jamais analyser ces chemins';

  @override
  String get profilesExcludesHint => '**/vendor/**';

  @override
  String get profilesExcludesHelp =>
      'Motifs glob. Les répertoires correspondants sont entièrement ignorés, par tous les profils et toutes les technologies intégrées.';

  @override
  String get profilesEnabled => 'Activé';

  @override
  String profilesDeleteConfirm(String name) {
    return 'Supprimer le profil « $name » ?';
  }

  @override
  String get profilesErrorName => 'Donnez un nom au profil.';

  @override
  String get profilesErrorMarkers =>
      'Un profil a besoin d’au moins un fichier repère, sinon il correspondrait à tous les dossiers.';

  @override
  String get profilesErrorNothingToDo =>
      'Donnez au profil une commande de nettoyage, des répertoires à retirer, ou les deux.';

  @override
  String profilesErrorAbsolutePath(String path) {
    return 'Les répertoires doivent être relatifs à la racine du projet : « $path » ne l’est pas.';
  }

  @override
  String profilesErrorEscapes(String path) {
    return '« $path » pointe hors du projet. Cela n’est jamais autorisé.';
  }

  @override
  String profilesErrorDuplicate(String name) {
    return 'Un profil nommé « $name » existe déjà.';
  }

  @override
  String get profilesImportFailed =>
      'Ce fichier n’est pas un export de profils Kruftle.';

  @override
  String profilesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count profils importés.',
      one: '1 profil importé.',
    );
    return '$_temp0';
  }

  @override
  String get diskTitle => 'Utilisation du disque';

  @override
  String get diskVolume => 'Volume';

  @override
  String get diskUsed => 'utilisé';

  @override
  String get diskFree => 'libre';

  @override
  String get diskReclaimable => 'récupérable';

  @override
  String diskOfTotal(String used, String total) {
    return '$used utilisés sur $total';
  }

  @override
  String diskFreedThisRun(String size) {
    return '$size libérés';
  }

  @override
  String get diskTreemapEmpty => 'Rien de mesuré pour l’instant.';

  @override
  String get changelogTitle => 'Nouveautés';

  @override
  String changelogVersionHeading(String version) {
    return 'Version $version';
  }

  @override
  String get changelogUnavailable =>
      'Le journal des modifications n’a pas pu être lu.';

  @override
  String get changelogAdded => 'Ajouté';

  @override
  String get changelogChanged => 'Modifié';

  @override
  String get changelogFixed => 'Corrigé';

  @override
  String changelogWhatsNewBanner(String version) {
    return 'Kruftle a été mis à jour vers $version.';
  }

  @override
  String get changelogWhatsNewAction => 'Voir ce qui a changé';

  @override
  String get legalPrivacyTitle => 'Politique de confidentialité';

  @override
  String get legalTermsTitle => 'Conditions d’utilisation';

  @override
  String get legalUnavailable => 'Ce document n’a pas pu être chargé.';

  @override
  String get legalOpenInBrowser => 'Ouvrir dans le navigateur';

  @override
  String get consentTitle => 'Conditions et confidentialité';

  @override
  String get consentBody =>
      'Kruftle exécute la commande de nettoyage propre à chaque chaîne d\'outils, ce qui supprime les fichiers de compilation de cette machine. Lisez les Conditions d\'utilisation et la Politique de confidentialité avant de commencer : continuer vaut acceptation des deux.';

  @override
  String get consentAccept => 'Accepter et continuer';

  @override
  String get consentDecline => 'Refuser et quitter';
}
