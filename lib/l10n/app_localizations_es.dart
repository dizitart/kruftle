// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LEs extends L {
  LEs([String locale = 'es']) : super(locale);

  @override
  String get appTagline => 'Recupera tu disco';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionShow => 'Mostrar';

  @override
  String get actionClear => 'Vaciar';

  @override
  String get actionAll => 'Todos';

  @override
  String get actionAllMatching => 'Todos los coincidentes';

  @override
  String get actionNone => 'Ninguno';

  @override
  String get actionBack => 'Atrás';

  @override
  String get actionNext => 'Siguiente';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionSkip => 'Omitir';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionAdd => 'Añadir';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionNotNow => 'Ahora no';

  @override
  String get alreadyRunningTitle => 'Kruftle ya está abierto';

  @override
  String get alreadyRunningBody =>
      'Ya hay otra ventana de Kruftle en ejecución. Si dos limpian a la vez, un directorio de compilación puede quedar a medio borrar, así que esta ventana no se abrirá.';

  @override
  String get titleBarGlobalCaches => 'Cachés globales de SDK';

  @override
  String get titleBarSettings => 'Ajustes';

  @override
  String get titleBarDiskUsage => 'Uso del disco';

  @override
  String get titleBarSchedule => 'Limpiezas programadas';

  @override
  String get titleBarProfiles => 'Perfiles de limpieza';

  @override
  String get titleBarChangelog => 'Novedades';

  @override
  String get titleBarAbout => 'Acerca de Kruftle';

  @override
  String get railFolder => 'Carpeta';

  @override
  String get railScan => 'Explorar';

  @override
  String get railReview => 'Revisar';

  @override
  String get railClean => 'Limpiar';

  @override
  String get railReport => 'Informe';

  @override
  String get sourceHeading => '¿Qué directorio debe revisar Kruftle?';

  @override
  String get sourceSubheading =>
      'Se examina todo lo que hay debajo. No se toca nada hasta que tú lo digas.';

  @override
  String get sourceChooseFolder => 'Elige una carpeta';

  @override
  String get sourceChooseFolderHelp =>
      'La raíz de tu código, o cualquier carpeta con proyectos';

  @override
  String get sourceConfirmButton => 'Explorar esta carpeta';

  @override
  String get sourceRecent => 'Recientes';

  @override
  String get sourceForget => 'Quitar de recientes';

  @override
  String get sourceShallowTitle => '¿Analizar esta ruta de todos modos?';

  @override
  String get sourceShallowReason =>
      'Está cerca de la raíz de su unidad. Kruftle lo rechaza por omisión, porque una ruta tan corta suele ser un desliz, pero en una unidad de red asignada o un volumen montado es justo donde vive un código. Tú decides.';

  @override
  String get sourceShallowReadOnly =>
      'El análisis solo lee. No borra, mueve ni cambia nada.';

  @override
  String get sourceShallowChoice =>
      'Después sigues eligiendo qué limpiar, proyecto por proyecto, y lo confirmas de nuevo antes de que se elimine nada.';

  @override
  String get sourceShallowStillRefused =>
      'Los directorios del sistema y el personal seguirán rechazándose elijas lo que elijas aquí, y esta respuesta no se recuerda.';

  @override
  String get sourceShallowAccept => 'Analizarla igualmente';

  @override
  String get scanningLooking => 'Buscando proyectos';

  @override
  String get scanningMeasuring => 'Midiendo lo que contienen';

  @override
  String get scanningProjectsFound => 'proyectos encontrados';

  @override
  String get scanningDirectoriesWalked => 'directorios recorridos';

  @override
  String get scanningMeasured => 'medido';

  @override
  String get scanningNothingYet => 'Aún no se ha encontrado nada.';

  @override
  String get scanningStop => 'Detener la exploración';

  @override
  String get reviewScanAgain => 'Explorar de nuevo';

  @override
  String get reviewChangeFolder => 'Cambiar de carpeta';

  @override
  String reviewProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count proyectos',
      one: '1 proyecto',
    );
    return '$_temp0';
  }

  @override
  String get reviewFilterHint =>
      'Filtrar por nombre, ruta o tecnología   ( / )';

  @override
  String get reviewSortedBySize => 'Ordenado por tamaño';

  @override
  String get reviewSortedByPath => 'Ordenado por ruta';

  @override
  String get reviewNoProjects =>
      'No hay proyectos con archivos de compilación en esta carpeta.';

  @override
  String reviewNoMatches(String query) {
    return 'Nada coincide con «$query».';
  }

  @override
  String reviewInSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count proyectos seleccionados',
      one: 'en 1 proyecto seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get reviewMeasuredByDryRun => 'medido por la simulación';

  @override
  String reviewStillMeasuring(int percent) {
    return 'midiendo todavía — $percent %';
  }

  @override
  String reviewFoundInTotal(String size, int count) {
    return '$size en total en $count proyectos.';
  }

  @override
  String reviewPlanSummary(int steps, int projects) {
    return '$steps pasos en $projects proyectos.';
  }

  @override
  String get reviewAlsoDelete => 'Eliminar también directamente';

  @override
  String get reviewAlsoDeleteHelp =>
      'Kruftle prefiere el propio comando de limpieza de cada herramienta. Estas categorías se eliminan borrando el directorio, así que están desactivadas salvo que indiques lo contrario.';

  @override
  String get reviewRiskBuildOutput =>
      'Resultado de compilación cuando falta el SDK';

  @override
  String get reviewRiskBuildOutputHelp =>
      'Para proyectos cuya herramienta no está instalada, se elimina el directorio de salida conocido. Recompilar lo restaura.';

  @override
  String get reviewRiskDependencies => 'Dependencias descargadas';

  @override
  String get reviewRiskDependenciesHelp =>
      'node_modules, .venv, deps. Se restauran desde el archivo de bloqueo, pero eso cuesta una descarga.';

  @override
  String get reviewRiskCache => 'Cachés de herramientas';

  @override
  String get reviewRiskCacheHelp =>
      '.gradle, .turbo, .mypy_cache y similares. Lo único que cuesta es una compilación más lenta.';

  @override
  String get reviewMissingToolchains =>
      'Algunos proyectos seleccionados no tienen el SDK instalado. Sin la primera opción de arriba se omitirán.';

  @override
  String reviewGitTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count directorios de artefactos están',
      one: '1 directorio de artefactos está',
    );
    return '$_temp0 bajo control de git y se dejarán intactos. Borrar contenido ya confirmado no es algo que una recompilación pueda deshacer.';
  }

  @override
  String get reviewDryRun => 'Simulación';

  @override
  String get reviewRemeasure => 'Volver a medir';

  @override
  String get reviewCleanNow => 'Limpiar ahora';

  @override
  String get reviewDryRunNote =>
      'Una simulación no cambia nada. Puedes omitirla.';

  @override
  String get reviewLargestDirectories => 'Dónde está el espacio';

  @override
  String get reviewLargestDirectoriesHelp =>
      'Los directorios de artefactos más grandes de esta carpeta. Pasa el cursor por un bloque para ver su ruta.';

  @override
  String get confirmDeleteTitle => '¿Eliminar estos directorios?';

  @override
  String get confirmDeleteIntro =>
      'Además de ejecutar el comando de limpieza de cada herramienta, Kruftle eliminará:';

  @override
  String get confirmCategoryBuildOutput =>
      'directorios de compilación donde falta el SDK';

  @override
  String get confirmCategoryDependencies =>
      'directorios de dependencias descargadas';

  @override
  String get confirmCategoryCache => 'directorios de caché de herramientas';

  @override
  String confirmDeleteScope(int count, String folder) {
    return 'En $count proyectos seleccionados dentro de $folder. Todo esto se puede regenerar, y se omite cualquier cosa que git controle.';
  }

  @override
  String get confirmDeleteAccept => 'Eliminar y limpiar';

  @override
  String get runningHeading => 'Limpiando';

  @override
  String runningProgress(int done, int total) {
    return '$done de $total pasos';
  }

  @override
  String get runningStop => 'Detener';

  @override
  String get reportStopped => 'Detenido';

  @override
  String get reportDone => 'Terminado';

  @override
  String reportRanFor(String duration, int projects) {
    return 'Duró $duration en $projects proyectos.';
  }

  @override
  String get reportReclaimed => 'recuperados';

  @override
  String get reportStepsCompleted => 'pasos completados';

  @override
  String get reportFailed => 'fallidos';

  @override
  String get reportNothingToDo => 'sin nada que hacer';

  @override
  String get reportRefused => 'rechazados';

  @override
  String reportUnderEstimate(String estimate) {
    return 'La simulación estimó $estimate. Los comandos de limpieza deciden por sí mismos qué eliminar: algunos conservan cachés que una recompilación puede reutilizar, que suele ser lo que quieres.';
  }

  @override
  String reportRefusedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objetivos fueron rechazados',
      one: '1 objetivo fue rechazado',
    );
    return '$_temp0 por una comprobación de seguridad y se dejaron intactos.';
  }

  @override
  String get reportWhatWentWrong => 'Qué salió mal';

  @override
  String get reportNoDetail => 'No se informó de ningún detalle.';

  @override
  String get reportScanAgain => 'Explorar de nuevo';

  @override
  String get reportAnotherFolder => 'Otra carpeta';

  @override
  String get reportExportLog => 'Exportar registro';

  @override
  String reportLogExported(String name) {
    return 'Registro exportado a $name';
  }

  @override
  String get reportDiskBefore => 'antes';

  @override
  String get reportDiskAfter => 'después';

  @override
  String reportDiskHeading(String volume, String free, String total) {
    return '$volume — $free libres de $total';
  }

  @override
  String get reportDiskUnavailable =>
      'Este volumen no informa de su espacio libre.';

  @override
  String toolAvailable(String binary, String stack) {
    return '$binary está instalado: los proyectos $stack se limpiarán con su propio comando.';
  }

  @override
  String toolMissing(String binary) {
    return '$binary no está en el PATH. Kruftle solo puede limpiarlo eliminando el directorio de compilación, lo que requiere tu permiso explícito.';
  }

  @override
  String toolNotApplicable(String stack) {
    return '$stack no tiene un comando de limpieza oficial.';
  }

  @override
  String get cachesTitle => 'Cachés globales';

  @override
  String get cachesRemeasure => 'Volver a medir';

  @override
  String get cachesSortTooltip => 'Ordenar por tamaño';

  @override
  String get cachesSortLargest => 'Mayores primero';

  @override
  String get cachesSortSmallest => 'Menores primero';

  @override
  String get cachesIntro =>
      'Estas cachés las comparten todos los proyectos de esta máquina. Vaciar una libera espacio ahora y cuesta una descarga más adelante; nunca pierde trabajo.';

  @override
  String cachesFreed(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cachés',
      one: '1 caché',
    );
    return 'Se liberaron $size de $_temp0.';
  }

  @override
  String get cachesNoneFound =>
      'No se encontraron cachés globales en tu carpeta personal.';

  @override
  String get cachesSelected => 'seleccionados';

  @override
  String get cachesEmptySelected => 'Vaciar lo seleccionado';

  @override
  String get cachesEmptying => 'Vaciando…';

  @override
  String get cachesConfirmTitle => '¿Vaciar estas cachés?';

  @override
  String cachesConfirmBody(String size) {
    return 'Las comparten todos los proyectos de esta máquina, no solo el último que exploraste. Vaciarlas libera $size ahora y cuesta una descarga la próxima vez que algún proyecto las necesite.';
  }

  @override
  String get cachesConfirmAccept => 'Vaciarlas';

  @override
  String get cachesUsesCommand =>
      'Se vacía con el propio comando de la herramienta en lugar de borrando archivos.';

  @override
  String get cachesUsesDelete =>
      'No hay comando oficial para esta caché, así que se elimina el directorio.';

  @override
  String get cachesDeleteTag => 'eliminar';

  @override
  String updateAvailable(String version, String size) {
    return 'Kruftle $version está disponible ($size).';
  }

  @override
  String updateDownloading(String version, int percent) {
    return 'Descargando $version… $percent %';
  }

  @override
  String updateReady(String version) {
    return 'Kruftle $version está listo. Reinicia para terminar.';
  }

  @override
  String get updateFailed => 'La actualización falló.';

  @override
  String get updateAction => 'Actualizar';

  @override
  String get updateRestart => 'Reiniciar ahora';

  @override
  String get updateChecking => 'Buscando actualizaciones…';

  @override
  String get updateUpToDate => 'Kruftle está actualizado.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Seguir al sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Seguir al sistema';

  @override
  String get settingsReduceMotion => 'Reducir el movimiento';

  @override
  String get settingsReduceMotionHelp =>
      'Sustituye las animaciones de barrido y pulso por un progreso simple. También se respeta automáticamente cuando el sistema operativo pide movimiento reducido.';

  @override
  String get settingsSectionScanning => 'Exploración';

  @override
  String get settingsMaxDepth => 'Profundidad máxima';

  @override
  String get settingsMaxDepthHelp =>
      'Cuánto se baja por debajo de la carpeta elegida. Más profundo encuentra más proyectos anidados y tarda más.';

  @override
  String settingsLevels(int count) {
    return '$count niveles';
  }

  @override
  String get settingsHiddenDirectories => 'Incluir directorios ocultos';

  @override
  String get settingsHiddenDirectoriesHelp =>
      'Carpetas que empiezan por un punto. Normalmente estado del editor y cachés, no proyectos.';

  @override
  String get settingsSectionCleaning => 'Limpieza';

  @override
  String get settingsConcurrency => 'Proyectos a la vez';

  @override
  String settingsConcurrencyHelp(int cores) {
    return 'Comandos de limpieza que se ejecutan en paralelo. Más es más rápido hasta que el disco se convierte en el cuello de botella. $cores núcleos disponibles.';
  }

  @override
  String get settingsTimeout => 'Tiempo límite por paso';

  @override
  String get settingsTimeoutHelp =>
      'Un comando de limpieza que dure más se cancela y se informa, para que una herramienta atascada no bloquee toda la ejecución.';

  @override
  String settingsSeconds(int count) {
    return '$count segundos';
  }

  @override
  String settingsMinutes(int count) {
    return '$count minutos';
  }

  @override
  String get settingsConfirmBeforeDelete => 'Confirmar antes de eliminar';

  @override
  String get settingsConfirmBeforeDeleteHelp =>
      'Muestra un diálogo de resumen siempre que una ejecución vaya a eliminar directorios directamente en lugar de solo ejecutar comandos de limpieza.';

  @override
  String get settingsSectionPreselect =>
      'Preseleccionar estas categorías de eliminación';

  @override
  String get settingsPreselectHelp =>
      'Solo por comodidad. Cada ejecución sigue mostrándolas marcadas y sigue preguntando antes de eliminar nada.';

  @override
  String get settingsSectionLogging => 'Registro';

  @override
  String get settingsLogDetail => 'Detalle';

  @override
  String get settingsLogDebug => 'Depuración';

  @override
  String get settingsLogInfo => 'Información';

  @override
  String get settingsLogWarning => 'Advertencia';

  @override
  String get settingsLogError => 'Error';

  @override
  String get settingsLogRetention => 'Archivos de registro conservados';

  @override
  String get settingsLogRetentionHelp =>
      'Los archivos antiguos se eliminan cuando se rota el registro activo.';

  @override
  String get settingsNone => 'ninguno';

  @override
  String get settingsSectionUpdates => 'Actualizaciones';

  @override
  String get settingsCheckUpdates => 'Buscar actualizaciones automáticamente';

  @override
  String get settingsCheckUpdatesHelp =>
      'Kruftle consulta GitHub Releases al arrancar y ofrece una descarga verificada. Nunca instala sin preguntar.';

  @override
  String get settingsCheckNow => 'Buscar actualizaciones ahora';

  @override
  String get settingsSectionSizes => 'Tamaños';

  @override
  String get settingsSizeMode => 'Cómo se cuentan los tamaños';

  @override
  String get settingsSizeModeOnDisk => 'Espacio realmente ocupado en el disco';

  @override
  String get settingsSizeModeApparent => 'Longitud total de los archivos';

  @override
  String get settingsSizeModeHelp =>
      '«En el disco» coincide con lo que informa el sistema operativo y con lo que recuperas, incluyendo el redondeo por bloques y la compresión del sistema de archivos. Necesita una llamada nativa que no existe en Windows, que usa la longitud de los archivos.';

  @override
  String get settingsSectionAbout => 'Acerca de';

  @override
  String get settingsShowTour => 'Volver a ver la guía de funciones';

  @override
  String get settingsChangelog => 'Novedades de esta versión';

  @override
  String get settingsPrivacyPolicy => 'Política de Privacidad';

  @override
  String get settingsTermsOfService => 'Términos del Servicio';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get settingsLicence =>
      'Software libre bajo la Licencia Pública General GNU v3.0 o posterior.';

  @override
  String get settingsMadeWith => 'Hecho con ❤️ en Calcuta, India';

  @override
  String get settingsSourceCode => 'Código fuente';

  @override
  String get settingsWebsite => 'Sitio web de Kruftle';

  @override
  String get tourWelcomeTitle => 'Te damos la bienvenida a Kruftle';

  @override
  String get tourWelcomeBody =>
      'Los archivos de compilación se acumulan en silencio. Kruftle encuentra cada proyecto de tu disco, averigua qué lo compiló y le pide a esa herramienta que recoja lo suyo.';

  @override
  String get tourWelcomeStart => 'Enséñame';

  @override
  String get tourWelcomeSkip => 'Omitir la guía';

  @override
  String get tourScanTitle => 'Apúntalo a una carpeta';

  @override
  String get tourScanBody =>
      'Elige la raíz de tu código. Kruftle recorre todo lo que hay debajo y reconoce más de cuarenta lenguajes y herramientas de compilación por los archivos que dejan, incluidos proyectos anidados dentro de otros.';

  @override
  String get tourReviewTitle => 'Mira lo que encontró antes de que pase nada';

  @override
  String get tourReviewBody =>
      'Cada proyecto, cada directorio de artefactos y lo que cuesta cada uno, medido y no estimado. Marca lo que quieras limpiar. No se toca nada hasta que tú lo digas.';

  @override
  String get tourSafetyTitle => 'La seguridad no es opcional';

  @override
  String get tourSafetyBody =>
      'Kruftle prefiere el propio comando de limpieza de cada herramienta antes que borrar archivos. La eliminación directa se limita a una lista de nombres de directorio permitidos, nunca sigue un enlace simbólico, se niega a salir de la carpeta que elegiste y siempre pregunta primero. Lo que git controla se deja intacto.';

  @override
  String get tourCachesTitle => 'También las cachés de tu carpeta personal';

  @override
  String get tourCachesBody =>
      'El registro de Cargo, las cachés de Gradle, las de npm y pub: las comparten todos los proyectos y suelen ser lo que más espacio libera. Tienen su propia pantalla y su propia confirmación.';

  @override
  String get tourScheduleTitle => 'Configúralo y olvídate';

  @override
  String get tourScheduleBody =>
      'Haz que Kruftle limpie a diario, cada semana o cada mes. Puede avisarte mientras está abierto, o registrarse en el programador de tu propio sistema operativo y hacer la limpieza con Kruftle cerrado.';

  @override
  String get tourFinishTitle => 'Esa es toda la aplicación';

  @override
  String get tourFinishBody =>
      'Todo se ejecuta en tu máquina. No se sube nada y no hay ninguna cuenta que crear.';

  @override
  String get tourFinishAction => 'Empezar';

  @override
  String get scheduleTitle => 'Limpiezas programadas';

  @override
  String get scheduleEnable => 'Recuérdame limpiar';

  @override
  String get scheduleEnableHelp =>
      'Kruftle comprueba si toca una limpieza mientras está en ejecución, y te avisa al arrancar si se saltó alguna. Activa abajo las ejecuciones en segundo plano para que ocurra sin Kruftle abierto.';

  @override
  String get scheduleBackground => 'Ejecutar aunque Kruftle esté cerrado';

  @override
  String get scheduleBackgroundHelp =>
      'Registra una tarea en el programador del propio sistema operativo, de modo que la limpieza se ejecute a la hora elegida esté o no abierto Kruftle. Ejecuta el comando de limpieza de cada cadena de herramientas y solo borra las categorías que hayas preseleccionado en Ajustes.';

  @override
  String get scheduleBackgroundActive =>
      'Registrado en el programador del sistema.';

  @override
  String get scheduleBackgroundFailed =>
      'Tu sistema se negó a registrar la tarea en segundo plano. El recordatorio sigue funcionando mientras Kruftle esté abierto.';

  @override
  String get scheduleFrequency => 'Con qué frecuencia';

  @override
  String get scheduleDaily => 'A diario';

  @override
  String get scheduleWeekly => 'Cada semana';

  @override
  String get scheduleMonthly => 'Cada mes';

  @override
  String get scheduleTimeOfDay => 'A las';

  @override
  String get scheduleDayOfWeek => 'El';

  @override
  String get scheduleDayOfMonth => 'El día';

  @override
  String get scheduleFolder => 'Carpeta a explorar';

  @override
  String get scheduleChooseFolder => 'Elige una carpeta…';

  @override
  String scheduleNextRun(String when) {
    return 'Próximo aviso $when.';
  }

  @override
  String get scheduleNeverRun => 'Todavía no se ha ejecutado ninguna limpieza.';

  @override
  String scheduleLastRun(String when) {
    return 'Última limpieza $when.';
  }

  @override
  String get scheduleDueTitle => 'Toca una limpieza';

  @override
  String scheduleDueBody(int days, String folder) {
    return 'Han pasado $days días desde la última en $folder.';
  }

  @override
  String get scheduleDueAction => 'Explorar ahora';

  @override
  String get scheduleDueDismiss => 'Más tarde';

  @override
  String get scheduleNotifyOnFinish => 'Avisarme cuando termine una limpieza';

  @override
  String get scheduleNotificationDueTitle => 'Kruftle — toca limpiar';

  @override
  String scheduleNotificationDueBody(String folder) {
    return 'Es hora de sacar los archivos de compilación de $folder.';
  }

  @override
  String scheduleNotificationDoneTitle(String size) {
    return 'Kruftle — $size recuperados';
  }

  @override
  String scheduleNotificationDoneBody(int projects, String duration) {
    return 'Se limpiaron $projects proyectos en $duration.';
  }

  @override
  String get profilesTitle => 'Perfiles de limpieza';

  @override
  String get profilesIntro =>
      'Un perfil le enseña a Kruftle un tipo de proyecto que aún no conoce: qué archivo lo identifica, qué comando lo limpia y qué directorios puede eliminar. Los perfiles conviven con las tecnologías integradas y obedecen exactamente las mismas reglas de seguridad.';

  @override
  String get profilesNone => 'Todavía no hay perfiles personalizados.';

  @override
  String get profilesNew => 'Perfil nuevo';

  @override
  String get profilesImport => 'Importar…';

  @override
  String get profilesExport => 'Exportar…';

  @override
  String get profilesName => 'Nombre';

  @override
  String get profilesNameHint => 'Unreal Engine';

  @override
  String get profilesMarkers => 'Archivos identificadores';

  @override
  String get profilesMarkersHint => '*.uproject';

  @override
  String get profilesMarkersHelp =>
      'Un directorio que contenga cualquiera de estos se trata como este tipo de proyecto. Uno por línea. Un asterisco tras el punto inicial busca por extensión.';

  @override
  String get profilesCommand => 'Comando de limpieza';

  @override
  String get profilesCommandHint => 'make clean';

  @override
  String get profilesCommandHelp =>
      'Se ejecuta con el directorio del proyecto como directorio de trabajo. Déjalo vacío para solo eliminar los directorios de abajo.';

  @override
  String get profilesArtifacts => 'Directorios que puede eliminar';

  @override
  String get profilesArtifactsHint => 'Binaries\nIntermediate';

  @override
  String get profilesArtifactsHelp =>
      'Uno por línea, relativos a la raíz del proyecto. Es una lista de permitidos: nunca se elimina nada fuera de ella, y la eliminación sigue necesitando tu confirmación en cada ejecución.';

  @override
  String get profilesExcludes => 'Nunca explorar estas rutas';

  @override
  String get profilesExcludesHint => '**/vendor/**';

  @override
  String get profilesExcludesHelp =>
      'Patrones glob. Los directorios coincidentes se omiten por completo, por todos los perfiles y todas las tecnologías integradas.';

  @override
  String get profilesEnabled => 'Activado';

  @override
  String profilesDeleteConfirm(String name) {
    return '¿Eliminar el perfil «$name»?';
  }

  @override
  String get profilesErrorName => 'Ponle un nombre al perfil.';

  @override
  String get profilesErrorMarkers =>
      'Un perfil necesita al menos un archivo identificador, o coincidiría con todas las carpetas.';

  @override
  String get profilesErrorNothingToDo =>
      'Dale al perfil un comando de limpieza, algunos directorios que eliminar, o ambos.';

  @override
  String profilesErrorAbsolutePath(String path) {
    return 'Los directorios deben ser relativos a la raíz del proyecto: «$path» no lo es.';
  }

  @override
  String profilesErrorEscapes(String path) {
    return '«$path» apunta fuera del proyecto. Eso nunca está permitido.';
  }

  @override
  String profilesErrorDuplicate(String name) {
    return 'Ya existe un perfil llamado «$name».';
  }

  @override
  String get profilesImportFailed =>
      'Ese archivo no es una exportación de perfiles de Kruftle.';

  @override
  String profilesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se importaron $count perfiles.',
      one: 'Se importó 1 perfil.',
    );
    return '$_temp0';
  }

  @override
  String get diskTitle => 'Uso del disco';

  @override
  String get diskVolume => 'Volumen';

  @override
  String get diskUsed => 'usado';

  @override
  String get diskFree => 'libre';

  @override
  String get diskReclaimable => 'recuperable';

  @override
  String diskOfTotal(String used, String total) {
    return '$used de $total usados';
  }

  @override
  String diskFreedThisRun(String size) {
    return '$size liberados';
  }

  @override
  String get diskTreemapEmpty => 'Todavía no se ha medido nada.';

  @override
  String get changelogTitle => 'Novedades';

  @override
  String changelogVersionHeading(String version) {
    return 'Versión $version';
  }

  @override
  String get changelogUnavailable => 'No se pudo leer el registro de cambios.';

  @override
  String get changelogAdded => 'Añadido';

  @override
  String get changelogChanged => 'Cambiado';

  @override
  String get changelogFixed => 'Corregido';

  @override
  String changelogWhatsNewBanner(String version) {
    return 'Kruftle se ha actualizado a $version.';
  }

  @override
  String get changelogWhatsNewAction => 'Ver qué ha cambiado';

  @override
  String get legalPrivacyTitle => 'Política de Privacidad';

  @override
  String get legalTermsTitle => 'Términos del Servicio';

  @override
  String get legalUnavailable => 'No se pudo cargar este documento.';

  @override
  String get legalOpenInBrowser => 'Abrir en el navegador';

  @override
  String get consentTitle => 'Términos y privacidad';

  @override
  String get consentBody =>
      'Kruftle ejecuta el comando de limpieza propio de cada cadena de herramientas, y eso borra la salida de compilación de este equipo. Lee los Términos del servicio y la Política de privacidad antes de empezar: continuar significa que aceptas ambos.';

  @override
  String get consentAccept => 'Aceptar y continuar';

  @override
  String get consentDecline => 'Rechazar y salir';
}
