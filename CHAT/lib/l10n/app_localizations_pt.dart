// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class SPt extends S {
  SPt([String locale = 'pt']) : super(locale);

  @override
  String get welcomeTagline =>
      'Mensagens privadas para a sua equipe. Chats, grupos, canais de voz e muito mais.';

  @override
  String get welcomeCta => 'Continuar com seu número';

  @override
  String get legalPrefix => 'Ao continuar você aceita os ';

  @override
  String get legalTerms => 'Termos';

  @override
  String get legalAnd => ' e a ';

  @override
  String get legalPrivacy => 'Política de Privacidade';

  @override
  String get legalSuffix => ' do Chatsito.';

  @override
  String get phoneTitle => 'Seu número de telefone';

  @override
  String get phoneSubtitle =>
      'Enviaremos um SMS com um código de 6 dígitos para verificar sua conta.';

  @override
  String get phoneCarrierFee => 'Podem ser aplicadas tarifas da sua operadora.';

  @override
  String get phoneCta => 'Enviar código';

  @override
  String get searchCountry => 'Buscar país';

  @override
  String get otpTitle => 'Verifique seu número';

  @override
  String get otpSentTo => 'Digite o código enviado para ';

  @override
  String get otpNotReceived => 'Não chegou?';

  @override
  String otpResendIn(Object time) {
    return 'Reenviar em $time';
  }

  @override
  String get profileTitle => 'Configure seu perfil';

  @override
  String get profileSubtitle =>
      'Adicione seu nome e uma foto. Você pode mudá-los quando quiser.';

  @override
  String get profileNameLabel => 'Seu nome';

  @override
  String get profileNameHint => 'Ex.: Marta García';

  @override
  String get profileCta => 'Começar a conversar';

  @override
  String get chatsTitle => 'Conversas';

  @override
  String get searchHint => 'Buscar';

  @override
  String get newChat => 'Nova conversa';

  @override
  String get newCommunity => 'Nova comunidade';

  @override
  String get joinWithCode => 'Entrar com código';

  @override
  String get newChatHint => 'Telefone (só dígitos)';

  @override
  String get newChatAction => 'Abrir conversa';

  @override
  String get newChatError => 'Não há nenhum usuário com esse número';

  @override
  String get joinTitle => 'Entrar em uma comunidade';

  @override
  String get joinHint => 'Código de convite';

  @override
  String get joinAction => 'Entrar';

  @override
  String get joinError => 'Código inválido ou expirado';

  @override
  String get cancel => 'Cancelar';

  @override
  String get navChats => 'Conversas';

  @override
  String get navGroups => 'Grupos';

  @override
  String get navCalls => 'Chamadas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get today => 'Hoje';

  @override
  String get typing => 'digitando…';

  @override
  String get messageHint => 'Mensagem';

  @override
  String get attachCamera => 'Câmera';

  @override
  String get attachGallery => 'Galeria';

  @override
  String get attachVideo => 'Vídeo';

  @override
  String get attachDocument => 'Documento';

  @override
  String get attachAudio => 'Áudio';

  @override
  String get attachLocation => 'Localização';

  @override
  String get attachContact => 'Contato';

  @override
  String get attachPoll => 'Enquete';

  @override
  String get newGroupTitle => 'Novo grupo';

  @override
  String participantsSelected(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n participantes selecionados',
      one: '1 participante selecionado',
    );
    return '$_temp0';
  }

  @override
  String get groupNameHint => 'Nome do grupo';

  @override
  String get addParticipants => 'Adicionar participantes';

  @override
  String get createGroupCta => 'Criar grupo';

  @override
  String get communityFallback => 'Comunidade';

  @override
  String membersCount(Object n) {
    return '$n membros';
  }

  @override
  String get textChannels => 'Canais de texto';

  @override
  String get voiceChannels => 'Canais de voz';

  @override
  String get voiceEmpty => 'Vazio';

  @override
  String voiceConnected(Object n) {
    return '$n conectados';
  }

  @override
  String get connecting => 'Conectando…';

  @override
  String voiceChannelSubtitle(Object name) {
    return 'Canal de voz · $name';
  }

  @override
  String get rolesTitle => 'Cargos';

  @override
  String get newRole => 'Novo cargo';

  @override
  String get roleNameLabel => 'Nome';

  @override
  String get roleNameHint => 'Nome do cargo';

  @override
  String get roleColor => 'Cor';

  @override
  String get rolePermissions => 'Permissões';

  @override
  String get roleMembers => 'Membros';

  @override
  String get createRoleCta => 'Criar cargo';

  @override
  String get saveRole => 'Salvar';

  @override
  String get permViewChannel => 'Ver canais';

  @override
  String get permSendMessages => 'Enviar mensagens';

  @override
  String get permManageMessages => 'Gerenciar mensagens';

  @override
  String get permManageChannels => 'Gerenciar canais';

  @override
  String get permManageRoles => 'Gerenciar cargos';

  @override
  String get permKickMembers => 'Expulsar membros';

  @override
  String get permManageInvites => 'Criar convites';

  @override
  String get permVoiceConnect => 'Conectar à voz';

  @override
  String get permVoiceSpeak => 'Falar na voz';

  @override
  String get permVoiceMuteMembers => 'Silenciar outros';

  @override
  String get permAdmin => 'Administrador';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get availableVerified => 'Disponível · ✓ verificado';

  @override
  String get setAccount => 'Conta';

  @override
  String get setPrivacy => 'Privacidade';

  @override
  String get setChats => 'Conversas';

  @override
  String get setNotifications => 'Notificações';

  @override
  String get setStorage => 'Armazenamento e dados';

  @override
  String get setHelp => 'Ajuda';

  @override
  String get setInvite => 'Convidar um amigo';

  @override
  String get inviteCommunityTitle => 'Convidar para a comunidade';

  @override
  String get inviteFriendTitle => 'Convidar um amigo';

  @override
  String get inviteCommunityHeading => 'Convide pessoas para a comunidade';

  @override
  String get inviteFriendHeading => 'Convide sua equipe para o Chatsito';

  @override
  String get inviteCommunityCopy =>
      'Compartilhe este código: no Chatsito, \"Entrar com código\". Expira em 7 dias.';

  @override
  String get inviteFriendCopy =>
      'Compartilhe seu link pessoal. Quando entrarem, você os verá nas suas conversas na hora.';

  @override
  String get copyAction => 'Copiar';

  @override
  String get shareMessage => 'Mensagem';

  @override
  String get shareEmail => 'E-mail';

  @override
  String get shareMore => 'Mais';

  @override
  String get done => 'Pronto';

  @override
  String get shareLink => 'Compartilhar link';

  @override
  String get actionAudio => 'Áudio';

  @override
  String get actionVideo => 'Vídeo';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionMute => 'Silenciar';

  @override
  String get aboutHeader => 'Sobre';

  @override
  String get aboutSample =>
      'Disponível ✨ Desenhando coisas bonitas na equipe de produto.';

  @override
  String get mediaFiles => 'Mídia e arquivos';

  @override
  String get seeAll => 'Ver tudo ›';

  @override
  String get muteNotifications => 'Silenciar notificações';

  @override
  String get tempMessages => 'Mensagens temporárias';

  @override
  String get disabled => 'Desativado';

  @override
  String get encryption => 'Criptografia';

  @override
  String get verified => 'Verificado';

  @override
  String blockContact(Object name) {
    return 'Bloquear $name';
  }

  @override
  String get reportContact => 'Denunciar contato';

  @override
  String get e2eNotice => 'Suas mensagens são criptografadas de ponta a ponta.';

  @override
  String get catInfo => 'Informações';

  @override
  String get catPhoneNumber => 'Número de telefone';

  @override
  String get catChangeNumber => 'Mudar número';

  @override
  String get catEmail => 'E-mail';

  @override
  String get catAdd => 'Adicionar';

  @override
  String get catRequestInfo => 'Solicitar informações da minha conta';

  @override
  String get catDeleteAccount => 'Excluir minha conta';

  @override
  String get catWhoCanSee => 'Quem pode ver minhas informações';

  @override
  String get catLastSeen => 'Visto por último e online';

  @override
  String get catEveryone => 'Todos';

  @override
  String get catProfilePhoto => 'Foto de perfil';

  @override
  String get catMyContacts => 'Meus contatos';

  @override
  String get catStatus => 'Status';

  @override
  String get catReadReceipts => 'Confirmações de leitura';

  @override
  String get catBlocked => 'Contatos bloqueados';

  @override
  String get catScreenLock => 'Bloqueio com código';

  @override
  String get catDisplay => 'Tela';

  @override
  String get catTheme => 'Tema';

  @override
  String get catLight => 'Claro';

  @override
  String get catWallpaper => 'Papel de parede';

  @override
  String get catFontSize => 'Tamanho da fonte';

  @override
  String get catMedium => 'Médio';

  @override
  String get catEnterToSend => 'Tecla Enter para enviar';

  @override
  String get catSaveToRoll => 'Salvar no rolo da câmera';

  @override
  String get catBackup => 'Backup';

  @override
  String get catChatHistory => 'Histórico de conversas';

  @override
  String get catMessages => 'Mensagens';

  @override
  String get catShowNotifications => 'Mostrar notificações';

  @override
  String get catTone => 'Toque';

  @override
  String get catVibration => 'Vibração';

  @override
  String get catDefault => 'Padrão';

  @override
  String get catShowPreview => 'Mostrar prévia';

  @override
  String get catNotifyReactions => 'Notificar reações';

  @override
  String get catManageStorage => 'Gerenciar armazenamento';

  @override
  String get catAutoDownload => 'Download automático';

  @override
  String get catOnMobile => 'Com dados móveis';

  @override
  String get catPhotos => 'Fotos';

  @override
  String get catOnWifi => 'Com Wi-Fi';

  @override
  String get catAll => 'Tudo';

  @override
  String get catNetworkUsage => 'Uso da rede';

  @override
  String get catViewNetwork => 'Ver uso da rede';

  @override
  String get catLessData => 'Usar menos dados nas chamadas';

  @override
  String get catHelpCenter => 'Central de ajuda';

  @override
  String get catContactUs => 'Fale conosco';

  @override
  String get catTermsPrivacy => 'Termos e Política de Privacidade';

  @override
  String get catAppInfo => 'Informações do app';
}
