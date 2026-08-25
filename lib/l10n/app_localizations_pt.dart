// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class LPt extends L {
  LPt([String locale = 'pt']) : super(locale);

  @override
  String get appTagline => 'Recupere o seu disco';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionShow => 'Mostrar';

  @override
  String get actionClear => 'Limpar';

  @override
  String get actionAll => 'Todos';

  @override
  String get actionAllMatching => 'Todos os correspondentes';

  @override
  String get actionNone => 'Nenhum';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionNext => 'Avançar';

  @override
  String get actionDone => 'Concluído';

  @override
  String get actionSkip => 'Pular';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionNotNow => 'Agora não';

  @override
  String get alreadyRunningTitle => 'O Kruftle já está aberto';

  @override
  String get alreadyRunningBody =>
      'Outra janela do Kruftle está em execução. Se duas limparem ao mesmo tempo, um diretório de compilação pode ficar meio apagado, por isso esta janela não será aberta.';

  @override
  String get titleBarGlobalCaches => 'Caches globais de SDK';

  @override
  String get titleBarSettings => 'Configurações';

  @override
  String get titleBarDiskUsage => 'Uso do disco';

  @override
  String get titleBarSchedule => 'Limpezas agendadas';

  @override
  String get titleBarProfiles => 'Perfis de limpeza';

  @override
  String get titleBarChangelog => 'Novidades';

  @override
  String get titleBarAbout => 'Sobre o Kruftle';

  @override
  String get railFolder => 'Pasta';

  @override
  String get railScan => 'Varrer';

  @override
  String get railReview => 'Revisar';

  @override
  String get railClean => 'Limpar';

  @override
  String get railReport => 'Relatório';

  @override
  String get sourceHeading => 'Qual diretório o Kruftle deve examinar?';

  @override
  String get sourceSubheading =>
      'Tudo o que estiver abaixo dele é examinado. Nada é tocado até você autorizar.';

  @override
  String get sourceChooseFolder => 'Escolha uma pasta';

  @override
  String get sourceChooseFolderHelp =>
      'A raiz do seu código, ou qualquer pasta com projetos';

  @override
  String get sourceConfirmButton => 'Varrer esta pasta';

  @override
  String get sourceRecent => 'Recentes';

  @override
  String get sourceForget => 'Remover dos recentes';

  @override
  String get scanningLooking => 'Procurando projetos';

  @override
  String get scanningMeasuring => 'Medindo o que eles ocupam';

  @override
  String get scanningProjectsFound => 'projetos encontrados';

  @override
  String get scanningDirectoriesWalked => 'diretórios percorridos';

  @override
  String get scanningMeasured => 'medido';

  @override
  String get scanningNothingYet => 'Nada encontrado ainda.';

  @override
  String get scanningStop => 'Parar a varredura';

  @override
  String get reviewScanAgain => 'Varrer de novo';

  @override
  String get reviewChangeFolder => 'Trocar de pasta';

  @override
  String reviewProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projetos',
      one: '1 projeto',
    );
    return '$_temp0';
  }

  @override
  String get reviewFilterHint =>
      'Filtrar por nome, caminho ou tecnologia   ( / )';

  @override
  String get reviewSortedBySize => 'Ordenado por tamanho';

  @override
  String get reviewSortedByPath => 'Ordenado por caminho';

  @override
  String get reviewNoProjects =>
      'Nenhum projeto com saída de compilação nesta pasta.';

  @override
  String reviewNoMatches(String query) {
    return 'Nada corresponde a “$query”.';
  }

  @override
  String reviewInSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'em $count projetos selecionados',
      one: 'em 1 projeto selecionado',
    );
    return '$_temp0';
  }

  @override
  String get reviewMeasuredByDryRun => 'medido pela simulação';

  @override
  String reviewStillMeasuring(int percent) {
    return 'ainda medindo — $percent%';
  }

  @override
  String reviewFoundInTotal(String size, int count) {
    return '$size no total em $count projetos.';
  }

  @override
  String reviewPlanSummary(int steps, int projects) {
    return '$steps etapas em $projects projetos.';
  }

  @override
  String get reviewAlsoDelete => 'Excluir diretamente também';

  @override
  String get reviewAlsoDeleteHelp =>
      'O Kruftle prefere o comando de limpeza de cada ferramenta. Estas categorias são removidas apagando o diretório, então ficam desligadas a menos que você diga o contrário.';

  @override
  String get reviewRiskBuildOutput => 'Saída de compilação quando falta o SDK';

  @override
  String get reviewRiskBuildOutputHelp =>
      'Para projetos cuja ferramenta não está instalada, apaga-se o diretório de saída conhecido. Recompilar restaura tudo.';

  @override
  String get reviewRiskDependencies => 'Dependências baixadas';

  @override
  String get reviewRiskDependenciesHelp =>
      'node_modules, .venv, deps. Restauradas a partir do lockfile, mas isso custa um download.';

  @override
  String get reviewRiskCache => 'Caches de ferramentas';

  @override
  String get reviewRiskCacheHelp =>
      '.gradle, .turbo, .mypy_cache e afins. O único custo é a próxima compilação ser mais lenta.';

  @override
  String get reviewMissingToolchains =>
      'Alguns projetos selecionados não têm o SDK instalado. Sem a primeira opção acima, eles serão ignorados.';

  @override
  String reviewGitTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count diretórios de artefatos estão',
      one: '1 diretório de artefatos está',
    );
    return '$_temp0 sob controle do git e será deixado intacto. Apagar conteúdo já commitado não é algo que uma recompilação desfaça.';
  }

  @override
  String get reviewDryRun => 'Simulação';

  @override
  String get reviewRemeasure => 'Medir de novo';

  @override
  String get reviewCleanNow => 'Limpar agora';

  @override
  String get reviewDryRunNote =>
      'Uma simulação não muda nada. Você pode pulá-la.';

  @override
  String get reviewLargestDirectories => 'Onde está o espaço';

  @override
  String get reviewLargestDirectoriesHelp =>
      'Os maiores diretórios de artefatos desta pasta. Passe o cursor sobre um bloco para ver o caminho.';

  @override
  String get confirmDeleteTitle => 'Excluir estes diretórios?';

  @override
  String get confirmDeleteIntro =>
      'Além de rodar o comando de limpeza de cada ferramenta, o Kruftle vai excluir:';

  @override
  String get confirmCategoryBuildOutput =>
      'diretórios de compilação onde falta o SDK';

  @override
  String get confirmCategoryDependencies =>
      'diretórios de dependências baixadas';

  @override
  String get confirmCategoryCache => 'diretórios de cache de ferramentas';

  @override
  String confirmDeleteScope(int count, String folder) {
    return 'Em $count projetos selecionados dentro de $folder. Tudo aqui é regenerável, e o que o git rastreia é ignorado.';
  }

  @override
  String get confirmDeleteAccept => 'Excluir e limpar';

  @override
  String get runningHeading => 'Limpando';

  @override
  String runningProgress(int done, int total) {
    return '$done de $total etapas';
  }

  @override
  String get runningStop => 'Parar';

  @override
  String get reportStopped => 'Interrompido';

  @override
  String get reportDone => 'Concluído';

  @override
  String reportRanFor(String duration, int projects) {
    return 'Durou $duration em $projects projetos.';
  }

  @override
  String get reportReclaimed => 'recuperados';

  @override
  String get reportStepsCompleted => 'etapas concluídas';

  @override
  String get reportFailed => 'falharam';

  @override
  String get reportNothingToDo => 'sem nada a fazer';

  @override
  String get reportRefused => 'recusadas';

  @override
  String reportUnderEstimate(String estimate) {
    return 'A simulação estimou $estimate. Os comandos de limpeza decidem por si o que remover — alguns mantêm caches que a próxima compilação reaproveita, o que costuma ser o que você quer.';
  }

  @override
  String reportRefusedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alvos foram recusados',
      one: '1 alvo foi recusado',
    );
    return '$_temp0 por uma verificação de segurança e ficaram intactos.';
  }

  @override
  String get reportWhatWentWrong => 'O que deu errado';

  @override
  String get reportNoDetail => 'Nenhum detalhe informado.';

  @override
  String get reportScanAgain => 'Varrer de novo';

  @override
  String get reportAnotherFolder => 'Outra pasta';

  @override
  String get reportExportLog => 'Exportar log';

  @override
  String reportLogExported(String name) {
    return 'Log exportado para $name';
  }

  @override
  String get reportDiskBefore => 'antes';

  @override
  String get reportDiskAfter => 'depois';

  @override
  String reportDiskHeading(String volume, String free, String total) {
    return '$volume — $free livres de $total';
  }

  @override
  String get reportDiskUnavailable => 'Este volume não informa o espaço livre.';

  @override
  String toolAvailable(String binary, String stack) {
    return '$binary está instalado — projetos $stack serão limpos com o comando próprio deles.';
  }

  @override
  String toolMissing(String binary) {
    return '$binary não está no PATH. O Kruftle só consegue limpar isto apagando o diretório de compilação, o que exige sua permissão explícita.';
  }

  @override
  String toolNotApplicable(String stack) {
    return '$stack não tem um comando de limpeza oficial.';
  }

  @override
  String get cachesTitle => 'Caches globais';

  @override
  String get cachesRemeasure => 'Medir de novo';

  @override
  String get cachesSortTooltip => 'Ordenar por tamanho';

  @override
  String get cachesSortLargest => 'Maiores primeiro';

  @override
  String get cachesSortSmallest => 'Menores primeiro';

  @override
  String get cachesIntro =>
      'Estes caches são compartilhados por todos os projetos desta máquina. Esvaziar um libera espaço agora e custa um novo download depois — nunca se perde trabalho.';

  @override
  String cachesFreed(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caches',
      one: '1 cache',
    );
    return 'Liberados $size de $_temp0.';
  }

  @override
  String get cachesNoneFound =>
      'Nenhum cache global encontrado na sua pasta pessoal.';

  @override
  String get cachesSelected => 'selecionados';

  @override
  String get cachesEmptySelected => 'Esvaziar selecionados';

  @override
  String get cachesEmptying => 'Esvaziando…';

  @override
  String get cachesConfirmTitle => 'Esvaziar estes caches?';

  @override
  String cachesConfirmBody(String size) {
    return 'Eles são compartilhados por todos os projetos desta máquina, não só o último que você varreu. Esvaziá-los libera $size agora e custa um download na próxima vez que qualquer projeto precisar deles.';
  }

  @override
  String get cachesConfirmAccept => 'Esvaziar';

  @override
  String get cachesUsesCommand =>
      'Esvaziado com o comando da própria ferramenta em vez de apagar arquivos.';

  @override
  String get cachesUsesDelete =>
      'Não há comando oficial para este cache, então o diretório é removido.';

  @override
  String get cachesDeleteTag => 'excluir';

  @override
  String updateAvailable(String version, String size) {
    return 'Kruftle $version está disponível ($size).';
  }

  @override
  String updateDownloading(String version, int percent) {
    return 'Baixando $version… $percent%';
  }

  @override
  String updateReady(String version) {
    return 'Kruftle $version está verificado. A instalar agora…';
  }

  @override
  String get updateFailed => 'A atualização falhou.';

  @override
  String get updateAction => 'Atualizar';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSectionAppearance => 'Aparência';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Acompanhar o sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Acompanhar o sistema';

  @override
  String get settingsReduceMotion => 'Reduzir movimento';

  @override
  String get settingsReduceMotionHelp =>
      'Troca as animações de varredura e pulso por um progresso simples. Também é respeitado automaticamente quando o sistema operacional pede movimento reduzido.';

  @override
  String get settingsSectionScanning => 'Varredura';

  @override
  String get settingsMaxDepth => 'Profundidade máxima';

  @override
  String get settingsMaxDepthHelp =>
      'Quanto descer abaixo da pasta escolhida. Mais fundo encontra mais projetos aninhados e demora mais.';

  @override
  String settingsLevels(int count) {
    return '$count níveis';
  }

  @override
  String get settingsHiddenDirectories => 'Incluir diretórios ocultos';

  @override
  String get settingsHiddenDirectoriesHelp =>
      'Pastas que começam com ponto. Normalmente estado do editor e caches, não projetos.';

  @override
  String get settingsSectionCleaning => 'Limpeza';

  @override
  String get settingsConcurrency => 'Projetos ao mesmo tempo';

  @override
  String settingsConcurrencyHelp(int cores) {
    return 'Comandos de limpeza rodando em paralelo. Mais é mais rápido até o disco virar o gargalo. $cores núcleos disponíveis.';
  }

  @override
  String get settingsTimeout => 'Tempo limite por etapa';

  @override
  String get settingsTimeoutHelp =>
      'Um comando de limpeza que passe disso é encerrado e registrado, para que uma ferramenta travada não segure a execução inteira.';

  @override
  String settingsSeconds(int count) {
    return '$count segundos';
  }

  @override
  String settingsMinutes(int count) {
    return '$count minutos';
  }

  @override
  String get settingsConfirmBeforeDelete => 'Confirmar antes de excluir';

  @override
  String get settingsConfirmBeforeDeleteHelp =>
      'Mostra um diálogo de resumo sempre que uma execução for excluir diretórios diretamente em vez de apenas rodar comandos de limpeza.';

  @override
  String get settingsSectionPreselect =>
      'Pré-selecionar estas categorias de exclusão';

  @override
  String get settingsPreselectHelp =>
      'Apenas uma conveniência. Toda execução continua mostrando-as marcadas e continua perguntando antes de excluir qualquer coisa.';

  @override
  String get settingsSectionLogging => 'Registro';

  @override
  String get settingsLogDetail => 'Detalhe';

  @override
  String get settingsLogDebug => 'Depuração';

  @override
  String get settingsLogInfo => 'Informação';

  @override
  String get settingsLogWarning => 'Aviso';

  @override
  String get settingsLogError => 'Erro';

  @override
  String get settingsLogRetention => 'Arquivos de log mantidos';

  @override
  String get settingsLogRetentionHelp =>
      'Arquivos mais antigos são removidos quando o log ativo é rotacionado.';

  @override
  String get settingsNone => 'nenhum';

  @override
  String get settingsSectionUpdates => 'Atualizações';

  @override
  String get settingsCheckUpdates => 'Verificar atualizações automaticamente';

  @override
  String get settingsCheckUpdatesHelp =>
      'O Kruftle consulta o GitHub Releases ao iniciar e oferece um download verificado. Nunca instala sem perguntar.';

  @override
  String get settingsSectionSizes => 'Tamanhos';

  @override
  String get settingsSizeMode => 'Como os tamanhos são contados';

  @override
  String get settingsSizeModeOnDisk => 'Espaço realmente ocupado no disco';

  @override
  String get settingsSizeModeApparent => 'Soma do tamanho dos arquivos';

  @override
  String get settingsSizeModeHelp =>
      'O valor em disco coincide com o que o sistema operacional informa e com o que você recupera, incluindo arredondamento por blocos e compressão do sistema de arquivos. Exige uma chamada nativa que não existe no Windows, onde se usa o tamanho dos arquivos.';

  @override
  String get settingsSectionAbout => 'Sobre';

  @override
  String get settingsShowTour => 'Ver o tour de recursos de novo';

  @override
  String get settingsChangelog => 'Novidades desta versão';

  @override
  String get settingsPrivacyPolicy => 'Política de Privacidade';

  @override
  String get settingsTermsOfService => 'Termos de Serviço';

  @override
  String settingsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get settingsLicence =>
      'Software livre sob a Licença Pública Geral GNU v3.0 ou posterior.';

  @override
  String get settingsMadeWith => 'Feito com ❤️ em Calcutá, Índia';

  @override
  String get settingsSourceCode => 'Código-fonte';

  @override
  String get tourWelcomeTitle => 'Boas-vindas ao Kruftle';

  @override
  String get tourWelcomeBody =>
      'Artefatos de compilação se acumulam em silêncio. O Kruftle encontra cada projeto do seu disco, descobre o que o compilou e pede que essa ferramenta limpe a própria sujeira.';

  @override
  String get tourWelcomeStart => 'Me mostre';

  @override
  String get tourWelcomeSkip => 'Pular o tour';

  @override
  String get tourScanTitle => 'Aponte para uma pasta';

  @override
  String get tourScanBody =>
      'Escolha a raiz do seu código. O Kruftle percorre tudo abaixo dela e reconhece mais de quarenta linguagens e ferramentas de compilação pelos arquivos que deixam — inclusive projetos aninhados dentro de outros.';

  @override
  String get tourReviewTitle => 'Veja o que ele achou antes que algo aconteça';

  @override
  String get tourReviewBody =>
      'Cada projeto, cada diretório de artefatos e quanto cada um custa — medido, não chutado. Marque o que quiser limpar. Nada é tocado até você autorizar.';

  @override
  String get tourSafetyTitle => 'Segurança não é opcional';

  @override
  String get tourSafetyBody =>
      'O Kruftle prefere o comando de limpeza de cada ferramenta a apagar arquivos. A exclusão direta é limitada a uma lista de nomes de diretório permitidos, nunca segue um link simbólico, se recusa a sair da pasta que você escolheu e sempre pergunta antes. O que o git rastreia fica intacto.';

  @override
  String get tourCachesTitle => 'E os caches da sua pasta pessoal também';

  @override
  String get tourCachesBody =>
      'O registry do Cargo, os caches do Gradle, os do npm e do pub — compartilhados por todos os projetos e muitas vezes o maior ganho no disco. Eles têm tela e confirmação próprias.';

  @override
  String get tourScheduleTitle => 'Configure e esqueça';

  @override
  String get tourScheduleBody =>
      'Faça o Kruftle limpar diariamente, semanalmente ou mensalmente. Pode avisá-lo enquanto está aberto, ou registar-se no agendador do seu sistema operativo e fazer a limpeza com o Kruftle fechado.';

  @override
  String get tourFinishTitle => 'É esse o aplicativo inteiro';

  @override
  String get tourFinishBody =>
      'Tudo roda na sua máquina. Nada é enviado, e não há conta a criar.';

  @override
  String get tourFinishAction => 'Começar';

  @override
  String get scheduleTitle => 'Limpezas agendadas';

  @override
  String get scheduleEnable => 'Lembre-me de limpar';

  @override
  String get scheduleEnableHelp =>
      'O Kruftle verifica se há uma limpeza pendente enquanto está em execução e avisa-o no arranque se alguma foi falhada. Ative abaixo as execuções em segundo plano para que aconteça sem o Kruftle aberto.';

  @override
  String get scheduleBackground => 'Executar mesmo com o Kruftle fechado';

  @override
  String get scheduleBackgroundHelp =>
      'Regista uma tarefa no agendador do próprio sistema operativo, para que a limpeza corra à hora escolhida, esteja ou não o Kruftle aberto. Executa o comando de limpeza de cada cadeia de ferramentas e apaga apenas as categorias que pré-selecionou nas Definições.';

  @override
  String get scheduleBackgroundActive => 'Registado no agendador do sistema.';

  @override
  String get scheduleBackgroundFailed =>
      'O seu sistema recusou registar a tarefa em segundo plano. O lembrete continua a funcionar enquanto o Kruftle estiver aberto.';

  @override
  String get scheduleFrequency => 'Com que frequência';

  @override
  String get scheduleDaily => 'Diariamente';

  @override
  String get scheduleWeekly => 'Semanalmente';

  @override
  String get scheduleMonthly => 'Mensalmente';

  @override
  String get scheduleTimeOfDay => 'Às';

  @override
  String get scheduleDayOfWeek => 'Em';

  @override
  String get scheduleDayOfMonth => 'No dia';

  @override
  String get scheduleFolder => 'Pasta a varrer';

  @override
  String get scheduleChooseFolder => 'Escolha uma pasta…';

  @override
  String scheduleNextRun(String when) {
    return 'Próximo lembrete $when.';
  }

  @override
  String get scheduleNeverRun => 'Nenhuma limpeza foi feita ainda.';

  @override
  String scheduleLastRun(String when) {
    return 'Última limpeza $when.';
  }

  @override
  String get scheduleDueTitle => 'Uma limpeza está pendente';

  @override
  String scheduleDueBody(int days, String folder) {
    return 'Faz $days dias desde a última em $folder.';
  }

  @override
  String get scheduleDueAction => 'Varrer agora';

  @override
  String get scheduleDueDismiss => 'Depois';

  @override
  String get scheduleNotifyOnFinish => 'Avisar quando uma limpeza terminar';

  @override
  String get scheduleNotificationDueTitle => 'Kruftle — limpeza pendente';

  @override
  String scheduleNotificationDueBody(String folder) {
    return 'É hora de tirar os artefatos de compilação de $folder.';
  }

  @override
  String scheduleNotificationDoneTitle(String size) {
    return 'Kruftle — $size recuperados';
  }

  @override
  String scheduleNotificationDoneBody(int projects, String duration) {
    return 'Limpou $projects projetos em $duration.';
  }

  @override
  String get profilesTitle => 'Perfis de limpeza';

  @override
  String get profilesIntro =>
      'Um perfil ensina ao Kruftle um tipo de projeto que ele ainda não conhece: qual arquivo o identifica, qual comando o limpa e quais diretórios ele pode remover. Perfis convivem com as tecnologias embutidas e obedecem exatamente às mesmas regras de segurança.';

  @override
  String get profilesNone => 'Ainda não há perfis personalizados.';

  @override
  String get profilesNew => 'Novo perfil';

  @override
  String get profilesImport => 'Importar…';

  @override
  String get profilesExport => 'Exportar…';

  @override
  String get profilesName => 'Nome';

  @override
  String get profilesNameHint => 'Unreal Engine';

  @override
  String get profilesMarkers => 'Arquivos identificadores';

  @override
  String get profilesMarkersHint => '*.uproject';

  @override
  String get profilesMarkersHelp =>
      'Um diretório que contenha qualquer um destes é tratado como esse tipo de projeto. Um por linha. Ponto seguido de asterisco corresponde por extensão.';

  @override
  String get profilesCommand => 'Comando de limpeza';

  @override
  String get profilesCommandHint => 'make clean';

  @override
  String get profilesCommandHelp =>
      'Executado com o diretório do projeto como diretório de trabalho. Deixe vazio para apenas apagar os diretórios abaixo.';

  @override
  String get profilesArtifacts => 'Diretórios que ele pode remover';

  @override
  String get profilesArtifactsHint => 'Binaries\nIntermediate';

  @override
  String get profilesArtifactsHelp =>
      'Um por linha, relativos à raiz do projeto. Isto é uma lista de permissões: nada fora dela é apagado, e a exclusão continua exigindo sua confirmação a cada execução.';

  @override
  String get profilesExcludes => 'Nunca varrer estes caminhos';

  @override
  String get profilesExcludesHint => '**/vendor/**';

  @override
  String get profilesExcludesHelp =>
      'Padrões glob. Diretórios correspondentes são ignorados por completo, por todos os perfis e todas as tecnologias embutidas.';

  @override
  String get profilesEnabled => 'Ativado';

  @override
  String profilesDeleteConfirm(String name) {
    return 'Excluir o perfil “$name”?';
  }

  @override
  String get profilesErrorName => 'Dê um nome ao perfil.';

  @override
  String get profilesErrorMarkers =>
      'Um perfil precisa de pelo menos um arquivo identificador, senão ele corresponderia a todas as pastas.';

  @override
  String get profilesErrorNothingToDo =>
      'Dê ao perfil um comando de limpeza, alguns diretórios para remover, ou ambos.';

  @override
  String profilesErrorAbsolutePath(String path) {
    return 'Os diretórios devem ser relativos à raiz do projeto: “$path” não é.';
  }

  @override
  String profilesErrorEscapes(String path) {
    return '“$path” aponta para fora do projeto. Isso nunca é permitido.';
  }

  @override
  String profilesErrorDuplicate(String name) {
    return 'Já existe um perfil chamado “$name”.';
  }

  @override
  String get profilesImportFailed =>
      'Esse arquivo não é uma exportação de perfis do Kruftle.';

  @override
  String profilesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perfis importados.',
      one: '1 perfil importado.',
    );
    return '$_temp0';
  }

  @override
  String get diskTitle => 'Uso do disco';

  @override
  String get diskVolume => 'Volume';

  @override
  String get diskUsed => 'em uso';

  @override
  String get diskFree => 'livre';

  @override
  String get diskReclaimable => 'recuperável';

  @override
  String diskOfTotal(String used, String total) {
    return '$used de $total em uso';
  }

  @override
  String diskFreedThisRun(String size) {
    return '$size liberados';
  }

  @override
  String get diskTreemapEmpty => 'Nada medido ainda.';

  @override
  String get changelogTitle => 'Novidades';

  @override
  String changelogVersionHeading(String version) {
    return 'Versão $version';
  }

  @override
  String get changelogUnavailable =>
      'Não foi possível ler o registro de mudanças.';

  @override
  String get changelogAdded => 'Adicionado';

  @override
  String get changelogChanged => 'Alterado';

  @override
  String get changelogFixed => 'Corrigido';

  @override
  String changelogWhatsNewBanner(String version) {
    return 'O Kruftle foi atualizado para $version.';
  }

  @override
  String get changelogWhatsNewAction => 'Ver o que mudou';

  @override
  String get legalPrivacyTitle => 'Política de Privacidade';

  @override
  String get legalTermsTitle => 'Termos de Serviço';

  @override
  String get legalUnavailable => 'Não foi possível carregar este documento.';

  @override
  String get legalOpenInBrowser => 'Abrir no navegador';

  @override
  String get consentTitle => 'Termos e privacidade';

  @override
  String get consentBody =>
      'O Kruftle executa o comando de limpeza da própria cadeia de ferramentas, o que apaga a saída de compilação desta máquina. Leia os Termos de Serviço e a Política de Privacidade antes de começar — continuar significa que você aceita ambos.';

  @override
  String get consentAccept => 'Aceitar e continuar';

  @override
  String get consentDecline => 'Recusar e sair';
}
