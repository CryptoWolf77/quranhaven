// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get quranTextTab => 'Texto del Corán';

  @override
  String get localSaveFailed =>
      'No se pudo guardar el cambio en este dispositivo. Se conserva el último estado guardado. Revisa el espacio disponible y vuelve a intentarlo.';

  @override
  String get localLoadFailed =>
      'No se pudo leer el progreso local. No se reemplazó ningún dato guardado. Activa el almacenamiento del sitio y vuelve a intentarlo.';

  @override
  String get retry => 'Volver a intentar';

  @override
  String get planOptions => 'Opciones del plan';

  @override
  String get tenRecitationsTab => 'Diez lecturas';

  @override
  String get readerModeDefault => 'Mushaf';

  @override
  String get readerModeScrollable => 'Página desplazable';

  @override
  String get readerModeDual => 'Doble página';

  @override
  String get readerModeTafsir => 'Corán y Tafsir';

  @override
  String get readerModeAyahTafsir => 'Ayah con Tafsir';

  @override
  String get appName => 'Corán';

  @override
  String get home => 'Inicio';

  @override
  String get quran => 'Corán';

  @override
  String get library => 'Biblioteca';

  @override
  String get plans => 'Planes';

  @override
  String get settings => 'Ajustes';

  @override
  String get greeting => 'La paz sea contigo';

  @override
  String get heroTitle => 'Un espacio sereno para el Corán';

  @override
  String get heroBody =>
      'Lee, escucha, reflexiona y crea un hábito diario duradero — totalmente gratis.';

  @override
  String get startReading => 'Abrir el Mushaf';

  @override
  String lastReadPage(int page) {
    return 'Última lectura · Página $page';
  }

  @override
  String get quickAccess => 'Acceso rápido';

  @override
  String get browseSurahs => 'Explorar suras';

  @override
  String get searchQuran => 'Buscar en el Corán';

  @override
  String get bookmarks => 'Marcadores';

  @override
  String get downloads => 'Descargas';

  @override
  String get dailyJourney => 'Tu camino diario';

  @override
  String get dailyJourneyBody =>
      'Crea un plan de Khatmah y avanza con tus objetivos de memorización.';

  @override
  String get comingSoon => 'Disponible en una fase posterior';

  @override
  String get charityMessage =>
      'Gratis para todos como Sadakah Jariyah (caridad continua).';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Apariencia';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String get about => 'Sobre este proyecto';

  @override
  String get aboutBody =>
      'Una plataforma benéfica del Corán sin anuncios, suscripciones ni funciones bloqueadas.';

  @override
  String get index => 'Índice';

  @override
  String get search => 'Buscar';

  @override
  String get surahs => 'Suras';

  @override
  String get juz => 'Yuz';

  @override
  String get hizb => 'Hizb';

  @override
  String get sajda => 'Postración';

  @override
  String get searchHint => 'Buscar en el Corán o una sura';

  @override
  String get noBookmarks =>
      'Todavía no hay marcadores. Mantén pulsada una aleya para guardarla.';

  @override
  String get yellowBookmarks => 'Marcadores amarillos';

  @override
  String get redBookmarks => 'Marcadores rojos';

  @override
  String get greenBookmarks => 'Marcadores verdes';

  @override
  String get ayahCopied => 'Aleya copiada';

  @override
  String get quickNavigate => 'Navegación rápida';

  @override
  String get page => 'Página';

  @override
  String get goToPage => 'Ir a la página';

  @override
  String get pageRangeHint => 'Introduce una página del 1 al 604';

  @override
  String get invalidPage => 'Introduce un número de página del 1 al 604';

  @override
  String get readerMenuHint =>
      'El menú del lector incluye el índice de suras y Yuz, búsqueda y marcadores guardados.';

  @override
  String juzNumber(int number) {
    return 'Yuz $number';
  }

  @override
  String get contentLibrary => 'Biblioteca del Corán';

  @override
  String get contentLibraryBody =>
      'Elige Tafsir y traducciones, escucha recitaciones y prepara contenido sin conexión.';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get translations => 'Traducciones';

  @override
  String get recitations => 'Recitaciones';

  @override
  String get selected => 'Seleccionado';

  @override
  String get available => 'Disponible';

  @override
  String get download => 'Descargar';

  @override
  String get downloading => 'Descargando…';

  @override
  String get select => 'Seleccionar';

  @override
  String get resourceReady =>
      'El recurso seleccionado está listo en el lector.';

  @override
  String get resourceFailed =>
      'No se pudo preparar el recurso. Comprueba la conexión e inténtalo de nuevo.';

  @override
  String get resourceHint =>
      'Los recursos descargados permanecen disponibles sin conexión en el móvil.';

  @override
  String get chooseSurah => 'Elige una sura';

  @override
  String get play => 'Reproducir';

  @override
  String get resumeListening => 'Continuar escuchando';

  @override
  String get downloadForOffline => 'Descargar sin conexión';

  @override
  String get cancelDownload => 'Cancelar descarga';

  @override
  String get downloadComplete =>
      'La sura está lista para escuchar sin conexión.';

  @override
  String get downloadFailed =>
      'Falló la descarga de audio. Comprueba la conexión y el almacenamiento.';

  @override
  String get openReaderControls => 'Abrir controles de audio';

  @override
  String get readerAudioHint =>
      'Usa los controles del lector para elegir recitador y administrar las suras descargadas.';

  @override
  String get webOfflineNote =>
      'En la web puedes guardar el Tafsir y las traducciones seleccionados en este navegador (hasta 160 MiB); el navegador puede eliminarlos si queda poco espacio. El audio necesita internet. Prepara la aplicación y las páginas del Corán por separado en Ajustes.';

  @override
  String get webResourceStorageUnavailable =>
      'Este navegador no puede guardar recursos de lectura. Usa un navegador compatible con el almacenamiento de sitios habilitado.';

  @override
  String get readers => 'Recitadores';

  @override
  String get downloadedSurahs => 'Suras descargadas';

  @override
  String get chooseReader => 'Elige un recitador';

  @override
  String get noInternet => 'Sin conexión a internet';

  @override
  String get ayahSingular => 'Aleya';

  @override
  String get ayahPlural => 'Aleyas';

  @override
  String get lastListen => 'Última escucha';

  @override
  String get translation => 'Traducción';

  @override
  String get footnotes => 'Notas';

  @override
  String get tafsirEmpty =>
      'Descarga o selecciona un Tafsir o una traducción para verlo aquí.';

  @override
  String get plansTitle => 'Tu camino con el Corán';

  @override
  String get plansBody =>
      'Planifica una Jatma, practica la memorización y avanza con constancia a tu propio ritmo.';

  @override
  String get khatmah => 'Jatma';

  @override
  String get memorization => 'Memorización';

  @override
  String get noKhatmah => 'Comienza un plan de Jatma';

  @override
  String get noKhatmahBody =>
      'Elige un período y la aplicación calculará una meta diaria de lectura manejable.';

  @override
  String get createKhatmah => 'Crear plan de Jatma';

  @override
  String get createKhatmahBody =>
      'Fija una meta cómoda. Puedes pausar el plan o cambiar la fecha en cualquier momento.';

  @override
  String get completionPeriod => 'Período para completar';

  @override
  String daysCount(int days) {
    return '$days días';
  }

  @override
  String get ramadanPlan => 'Plan de Ramadán';

  @override
  String get ramadanPlanBody => 'Un plan de 30 días para completar el Corán.';

  @override
  String get continueFromLastRead => 'Continuar desde mi última página';

  @override
  String startAtPage(int page) {
    return 'Contar el progreso desde la página $page';
  }

  @override
  String get startPlan => 'Iniciar plan';

  @override
  String get activeKhatmah => 'Jatma activa';

  @override
  String get ramadanKhatmah => 'Jatma de Ramadán';

  @override
  String get paused => 'En pausa';

  @override
  String targetDate(String date) {
    return 'Meta: $date';
  }

  @override
  String get adjustDate => 'Cambiar fecha objetivo';

  @override
  String get deletePlan => 'Eliminar plan';

  @override
  String get deletePlanBody =>
      'El progreso de esta Jatma se eliminará de este dispositivo.';

  @override
  String pagesOfTotal(int completed, int total) {
    return '$completed de $total páginas';
  }

  @override
  String get pagesToday => 'Páginas de hoy';

  @override
  String get pagesRemaining => 'Páginas restantes';

  @override
  String get daysRemaining => 'Días restantes';

  @override
  String get completeToday => 'Completar la meta de hoy';

  @override
  String get khatmahComplete => 'Jatma completada';

  @override
  String get updateProgress => 'Actualizar progreso';

  @override
  String get pagesCompleted => 'Páginas completadas';

  @override
  String get pausePlan => 'Pausar plan';

  @override
  String get resumePlan => 'Reanudar plan';

  @override
  String get progressSavedLocally =>
      'Tu progreso se guarda en el dispositivo y permanece disponible sin conexión.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get noMemorization => 'Crea un rango de memorización';

  @override
  String get noMemorizationBody =>
      'Elige una Sura y un rango de Ayas, y practica con repetición, texto oculto y marcas de repaso.';

  @override
  String get createMemorization => 'Crear plan de memorización';

  @override
  String get createMemorizationBody =>
      'Elige un rango de Ayas y el patrón de repetición que prefieras.';

  @override
  String get newRange => 'Nuevo rango';

  @override
  String get startAyah => 'Aya inicial';

  @override
  String get endAyah => 'Aya final';

  @override
  String get repetitionsPerAyah => 'Repeticiones por Aya';

  @override
  String get rangeRepetitions => 'Repeticiones del rango';

  @override
  String get delayBetween => 'Pausa entre repeticiones';

  @override
  String secondsCount(int seconds) {
    return '$seconds s';
  }

  @override
  String get startWithAyahHidden => 'Comenzar con el Aya oculta';

  @override
  String get startMemorizing => 'Comenzar a memorizar';

  @override
  String ayahRangeError(int maximum) {
    return 'Introduce un Aya del 1 al $maximum';
  }

  @override
  String get endBeforeStart =>
      'El Aya final debe ser posterior al Aya inicial.';

  @override
  String ayahRange(int start, int end) {
    return 'Ayas $start–$end';
  }

  @override
  String currentAyah(int ayah) {
    return 'Aya actual · $ayah';
  }

  @override
  String get ayahHidden =>
      'Recita de memoria y luego muestra el Aya para comprobar.';

  @override
  String get hideAyah => 'Ocultar Aya';

  @override
  String get revealAyah => 'Mostrar Aya';

  @override
  String repeatCount(int count) {
    return 'Repetir ×$count';
  }

  @override
  String delayCount(int seconds) {
    return 'Pausa de $seconds s';
  }

  @override
  String get repeatCurrent => 'Repetir Aya actual';

  @override
  String get repeatRange => 'Repetir rango completo';

  @override
  String get stop => 'Detener';

  @override
  String get openInMushaf => 'Abrir en el Mushaf';

  @override
  String get markForRevision => 'Marcar para repaso';

  @override
  String get markMemorized => 'Marcar memorizada';

  @override
  String get memorized => 'Memorizada';

  @override
  String get deleteMemorizationBody =>
      'Este rango y su progreso se eliminarán del dispositivo.';

  @override
  String get audioFailed =>
      'No se pudo reproducir el audio. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get previousAyah => 'Aya anterior';

  @override
  String get nextAyah => 'Aya siguiente';

  @override
  String get removeRevisionMarker => 'Quitar marca de repaso';

  @override
  String get dailyReminder => 'Recordatorio diario de lectura';

  @override
  String get remindMeDaily => 'Recordarme cada día';

  @override
  String get reminderBody =>
      'Recibe un recordatorio amable a la hora que elijas.';

  @override
  String get reminderMobileOnly =>
      'Los recordatorios programados están disponibles actualmente en Android e iOS.';

  @override
  String reminderTime(String time) {
    return 'Hora del recordatorio: $time';
  }

  @override
  String get dailyReminderTitle => 'Un momento con el Corán';

  @override
  String get dailyReminderBody =>
      'Dedica hoy un momento de paz a leer, escuchar o repasar.';

  @override
  String get reminderEnabled => 'Tu recordatorio diario del Corán está activo.';

  @override
  String get notificationDenied =>
      'No se concedió permiso para las notificaciones.';

  @override
  String get contentServerNotConfigured =>
      'El Corán, el Tafsir incluido y las descargas guardadas están disponibles. Los recursos de lectura adicionales estarán disponibles al conectar el servicio de contenido.';

  @override
  String get offlineTitle => 'Lectura sin conexión';

  @override
  String get offlineBody =>
      'Guarda la aplicación y las páginas del Corán en este navegador antes de desconectarte. El Tafsir y las traducciones se pueden guardar por separado en la Biblioteca. El audio no está incluido.';

  @override
  String get offlinePrepare => 'Preparar lectura sin conexión';

  @override
  String get offlinePreparing => 'Guardando el Corán para leer sin conexión…';

  @override
  String get offlineReady => 'Listo para leer sin conexión';

  @override
  String get offlineUpdateReady => 'Hay una actualización sin conexión lista';

  @override
  String get offlineActivate => 'Aplicar actualización y recargar';

  @override
  String get offlineCancel => 'Cancelar descarga';

  @override
  String get offlineRemove => 'Eliminar archivos de la aplicación sin conexión';

  @override
  String get offlineRemoveWarning =>
      '¿Eliminar solo los archivos de la aplicación y las páginas del Corán guardados en este navegador? Se conservarán tu progreso de lectura y el Tafsir guardado. Necesitarás internet para volver a abrir la aplicación.';

  @override
  String get offlineRemoved =>
      'Archivos de la aplicación sin conexión eliminados';

  @override
  String get offlineUnavailable =>
      'La preparación sin conexión no está disponible en este navegador. Prueba un navegador compatible mediante HTTPS.';

  @override
  String get offlineError =>
      'No se pudo completar la preparación sin conexión. Comprueba tu conexión y el espacio disponible e inténtalo de nuevo.';

  @override
  String get offlineOtherTabs =>
      'Cierra las otras pestañas de Quran Haven y vuelve a aplicar la actualización.';

  @override
  String get offlineActivationTimeout =>
      'La actualización aún no pudo activarse. Recarga esta pestaña e inténtalo de nuevo.';

  @override
  String get offlineStorageWarning =>
      'El navegador puede eliminar archivos guardados si queda poco espacio. Revisa esta pantalla antes de depender de la lectura sin conexión.';

  @override
  String offlineProgress(String completed, String total) {
    return '$completed / $total MB guardados';
  }

  @override
  String get offlineNotReady => 'No está preparado para leer sin conexión';

  @override
  String get offlineCancelled =>
      'Descarga cancelada. Se conserva la versión preparada anteriormente, si existe.';

  @override
  String get localStorageTitle => 'Almacenamiento en el dispositivo';

  @override
  String get localStorageBody =>
      'Tus marcadores, última lectura, planes, ajustes y descargas se guardan solo en este dispositivo o navegador. No hay cuentas, copias en la nube ni sincronización entre dispositivos. Desinstalar la aplicación o borrar sus datos o los del sitio puede eliminar estos elementos guardados.';

  @override
  String get guideTitle => 'Guía de Quran Haven';

  @override
  String get guideOpen => 'Abrir la guía';

  @override
  String get guideEntryBody =>
      'Demostraciones visuales breves y pasos prácticos para leer, escuchar y crear una rutina diaria.';

  @override
  String get guideIntroTitle => 'Tu recorrido, paso a paso';

  @override
  String get guideIntro =>
      'Empieza con el Mushaf y descubre las herramientas que acompañan tu lectura. Esta guía describe las funciones disponibles actualmente e indica las diferencias entre el sitio web y la aplicación móvil.';

  @override
  String get guideMediaHint =>
      'Las demostraciones permanecen inmóviles hasta que pulses Reproducir. Debajo de cada una encontrarás los pasos por escrito.';

  @override
  String get guideGoodToKnow => 'Conviene saber';

  @override
  String get guidePlayDemo => 'Reproducir demostración';

  @override
  String get guideStopDemo => 'Detener demostración';

  @override
  String get guideMediaUnavailable =>
      'Demostración no disponible. Sigue los pasos escritos abajo.';

  @override
  String get guideReducedMotion =>
      'La animación está desactivada porque tu dispositivo tiene activada la reducción de movimiento.';

  @override
  String guideDemoDescription(String topic) {
    return 'Demostración en pantalla: $topic';
  }

  @override
  String get guideReadingTitle => 'Lee y encuentra tu lugar';

  @override
  String get guideReadingStep1 =>
      'En Inicio, elige Abrir el Mushaf para continuar en la última página leída.';

  @override
  String get guideReadingStep2 =>
      'Abre Navegación rápida en el lector. Elige una sura o un juz, o escribe un número de página entre 1 y 604 y pulsa Ir a la página.';

  @override
  String get guideReadingStep3 =>
      'Desliza para cambiar de página. Tu última posición de lectura se guarda automáticamente en este dispositivo.';

  @override
  String get guideReadingTip =>
      'El texto del Corán permanece en árabe al cambiar el idioma de la interfaz. No necesitas una cuenta para leer.';

  @override
  String get guideSearchTitle => 'Busca y guarda marcadores';

  @override
  String get guideSearchStep1 =>
      'Elige Buscar en el Corán en Inicio o abre Buscar en el lector. Escribe una palabra o frase del texto árabe del Corán.';

  @override
  String get guideSearchStep2 =>
      'Selecciona un resultado y pulsa Cerrar arriba del panel para volver al Mushaf en esa aleya. Mantén pulsada una aleya para abrir sus opciones.';

  @override
  String get guideSearchStep3 =>
      'Elige un color de marcador en las opciones de la aleya. Abre Marcadores para volver a las aleyas guardadas.';

  @override
  String get guideSearchTip =>
      'La búsqueda cubre actualmente el Corán en árabe, no el tafsir ni las traducciones. Los marcadores se organizan en los grupos amarillo, rojo y verde.';

  @override
  String get guideLibraryTitle => 'Elige tafsir y traducciones';

  @override
  String get guideLibraryStep1 =>
      'Abre Biblioteca y elige Tafsir o Traducciones.';

  @override
  String get guideLibraryStep2 =>
      'Pulsa Descargar para un recurso adicional, o Seleccionar para uno ya disponible. Espera la confirmación de que está listo.';

  @override
  String get guideLibraryStep3 =>
      'Vuelve al Mushaf, mantén pulsada una aleya y abre la opción Tafsir para leer el recurso seleccionado.';

  @override
  String get guideLibraryTip =>
      'El idioma de la interfaz y el recurso de lectura son independientes. Los recursos guardados funcionan sin conexión si el navegador permite el almacenamiento.';

  @override
  String get guideAudioTitle => 'Escucha recitaciones';

  @override
  String get guideAudioStep1 =>
      'Abre los controles de audio del lector para elegir un recitador. La lista puede variar según los controles de reproducción.';

  @override
  String get guideAudioStep2 =>
      'En Biblioteca, elige Recitaciones, selecciona una sura y pulsa Reproducir. También puedes reproducir una aleya desde sus opciones en el Mushaf.';

  @override
  String get guideAudioStep3 =>
      'Usa el reproductor para pausar o continuar. Reanudar la escucha vuelve a la posición de audio guardada cuando está disponible.';

  @override
  String get guideAudioTip =>
      'El audio en línea necesita conexión y puede proceder de proveedores externos de recitaciones. No hay descargas de audio sin conexión en el navegador.';

  @override
  String get guideOfflineTitle => 'Prepárate antes de desconectarte';

  @override
  String get guideOfflineStep1 =>
      'En el sitio web, abre Ajustes y pulsa Preparar lectura sin conexión. Mantén la pestaña abierta hasta que aparezca Listo para leer sin conexión. La aplicación móvil incluye el Mushaf.';

  @override
  String get guideOfflineStep2 =>
      'Descarga en Biblioteca los tafsires y las traducciones que necesites mientras tienes conexión. Preparar el sitio sin conexión no descarga estos recursos adicionales ni el audio.';

  @override
  String get guideOfflineStep3 =>
      'En la aplicación móvil, elige una sura en Biblioteca → Recitaciones y pulsa Descargar sin conexión. Prueba el contenido guardado sin internet antes de depender de él.';

  @override
  String get guideOfflineTip =>
      'El navegador puede borrar archivos cuando queda poco espacio. La navegación privada no es adecuada para conservar datos. El audio sin conexión está disponible en la aplicación móvil, no en el sitio web.';

  @override
  String get guidePlansTitle => 'Crea una rutina de lectura y memorización';

  @override
  String get guidePlansStep1 =>
      'Abre Planes → Khatmah. Crea un plan, elige el plazo y comienza. Marca la lectura diaria solo después de terminarla.';

  @override
  String get guidePlansStep2 =>
      'Abre Memorización y crea un plan con una sura, un intervalo de aleyas, las repeticiones y la pausa entre ellas.';

  @override
  String get guidePlansStep3 =>
      'Reproduce el intervalo, oculta o muestra el texto y marca las aleyas memorizadas o pendientes de repaso. Usa los controles anterior y siguiente para moverte dentro del intervalo.';

  @override
  String get guidePlansTip =>
      'El progreso de los planes se guarda en este dispositivo. La repetición de audio necesita una fuente reproducible o una descarga guardada compatible.';

  @override
  String get guideSettingsTitle => 'Ajusta la experiencia a tu gusto';

  @override
  String get guideSettingsStep1 =>
      'En Ajustes → Idioma, elige العربية, English o Español. La interfaz y esta guía siguen tu elección.';

  @override
  String get guideSettingsStep2 =>
      'En Ajustes → Apariencia, elige el modo claro, oscuro o el ajuste del sistema.';

  @override
  String get guideSettingsStep3 =>
      'En la aplicación móvil, puedes activar un recordatorio diario, elegir la hora y conceder permiso para las notificaciones.';

  @override
  String get guideSettingsTip =>
      'Los recordatorios diarios están disponibles en teléfonos compatibles, no en el sitio web. Puedes desactivarlos en Ajustes.';

  @override
  String get guideStorageTitle => 'Entiende tus datos locales';

  @override
  String get guideStorageStep1 =>
      'Los marcadores, la posición de lectura, los planes, los ajustes y las descargas se guardan en este dispositivo o navegador. No hay cuenta ni sincronización entre dispositivos.';

  @override
  String get guideStorageStep2 =>
      'Utiliza el mismo perfil del navegador para conservar los datos del sitio. Cada dispositivo, navegador o perfil tiene sus propios datos.';

  @override
  String get guideStorageTip =>
      'Desinstalar la aplicación, borrar sus datos o los del sitio, o perder el dispositivo puede eliminar lo guardado. Actualmente no hay una herramienta de exportación e importación local.';

  @override
  String get playAyah => 'Reproducir aleya';

  @override
  String get playFromAyah => 'Reproducir desde esta aleya';

  @override
  String get copyAyah => 'Copiar aleya';

  @override
  String get saveYellowBookmark => 'Guardar marcador amarillo';

  @override
  String get saveRedBookmark => 'Guardar marcador rojo';

  @override
  String get saveGreenBookmark => 'Guardar marcador verde';

  @override
  String get guideViewLarger => 'Ver más grande';

  @override
  String get guideZoomHint =>
      'Pellizca o desplázate para ampliar y arrastra para recorrer la pantalla. Usa Restablecer zoom para volver a ver la demostración completa.';

  @override
  String get guideResetZoom => 'Restablecer zoom';
}
