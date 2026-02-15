// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'FairyCraft';

  @override
  String get commonAccount => 'Аккаунт';

  @override
  String get commonSettings => 'Настройки';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Пароль';

  @override
  String get commonBackToLogin => 'Назад ко входу';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonSkip => 'Пропустить';

  @override
  String get commonNotAvailable => 'Недоступно';

  @override
  String get commonLink => 'Привязать';

  @override
  String get commonUnlink => 'Отвязать';

  @override
  String get commonStop => 'Стоп';

  @override
  String get commonUpdate => 'Обновить';

  @override
  String get homeTagline =>
      'Спокойное пространство для совместного создания сказок перед сном.';

  @override
  String get homeCreateStoryTitle => 'Создать историю';

  @override
  String get homeCreateStorySubtitle => 'Начните новое приключение в один тап.';

  @override
  String get homeMyStoriesTitle => 'Мои истории';

  @override
  String get homeMyStoriesSubtitle => 'Продолжайте читать сохранённые главы.';

  @override
  String get homeStoryPreferences => 'Параметры истории';

  @override
  String get homeAccountTooltip => 'Аккаунт';

  @override
  String get homeSettingsTooltip => 'Настройки';

  @override
  String get authLoginTitle => 'Вход в FairyCraft';

  @override
  String get authLoginButton => 'Войти';

  @override
  String get authCreateAccountButton => 'Создать аккаунт';

  @override
  String get authForgotPasswordButton => 'Забыли пароль';

  @override
  String authLoginFailed(String error) {
    return 'Ошибка входа: $error';
  }

  @override
  String get authRegisterTitle => 'Создать аккаунт FairyCraft';

  @override
  String get authRegisterButton => 'Зарегистрироваться';

  @override
  String authRegisterFailed(String error) {
    return 'Ошибка регистрации: $error';
  }

  @override
  String get authResetPasswordTitle => 'Сброс пароля';

  @override
  String get authSendResetEmailButton => 'Отправить письмо';

  @override
  String authResetEmailFailed(String error) {
    return 'Не удалось отправить письмо для сброса: $error';
  }

  @override
  String get authResetSentTitle => 'Письмо отправлено';

  @override
  String get authResetSentBody =>
      'Если email существует, инструкции по сбросу уже отправлены.';

  @override
  String get authCheckingSession => 'Проверяем сессию...';

  @override
  String get authSessionSlow =>
      'Проверка сессии занимает больше времени, чем обычно.';

  @override
  String get authChangePasswordTitle => 'Сменить пароль';

  @override
  String get authNewPasswordLabel => 'Новый пароль';

  @override
  String get authPasswordUpdated => 'Пароль обновлён.';

  @override
  String authPasswordChangeFailed(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get authProviderLinkTitle => 'Привязка провайдера';

  @override
  String get authLinkGoogleStub => 'Привязать Google (заглушка)';

  @override
  String get authLinkFacebookStub => 'Привязать Facebook (заглушка)';

  @override
  String authProviderLinkRequested(String provider) {
    return 'Запрос на привязку $provider выполнен (пока заглушка).';
  }

  @override
  String authProviderLinkFailed(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get accountTitle => 'Аккаунт';

  @override
  String get accountEmailLabel => 'Email';

  @override
  String get accountLinkedProviders => 'Привязанные провайдеры';

  @override
  String get accountGoogle => 'Google';

  @override
  String get accountFacebook => 'Facebook';

  @override
  String get accountEmailPassword => 'Email и пароль';

  @override
  String get accountLogout => 'Выйти';

  @override
  String accountProviderUnlinked(String provider) {
    return '$provider отвязан.';
  }

  @override
  String accountProviderLinkRequested(String provider) {
    return 'Запрошена привязка $provider.';
  }

  @override
  String get accountProviderUpdateFailed =>
      'Не удалось обновить провайдера. Попробуйте снова.';

  @override
  String get myStoriesTitle => 'Мои истории';

  @override
  String get myStoriesEmpty => 'Историй пока нет.';

  @override
  String myStoriesChaptersCount(int count) {
    return 'Глав: $count';
  }

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать';

  @override
  String get onboardingHeroTitle => 'Как зовут вашего героя?';

  @override
  String get onboardingHeroDescription =>
      'Имя героя будет использоваться в историях, и его можно изменить в любой момент.';

  @override
  String get onboardingHeroNameLabel => 'Имя героя';

  @override
  String get onboardingHeroNameHint => 'Луна, Арам, Мия...';

  @override
  String get onboardingAgeTitle =>
      'Для какого возраста истории подходят лучше?';

  @override
  String get onboardingAgeDescription =>
      'Мы используем это, чтобы подобрать комфортный словарь и темп.';

  @override
  String onboardingAgeYears(int age) {
    return '$age лет';
  }

  @override
  String get onboardingFamilyTitle => 'Кто в вашей семье?';

  @override
  String get onboardingFamilyDescription =>
      'Семейный режим помогает добавлять в истории знакомых персонажей.';

  @override
  String get onboardingUseFamilyMode => 'Использовать семейный режим';

  @override
  String get onboardingIllustrationsTitle => 'Иллюстрации и креативность';

  @override
  String get onboardingIllustrationsDescription =>
      'Выберите, добавлять ли изображения и насколько фантазийными будут истории.';

  @override
  String get onboardingAutoIllustrations => 'Автоиллюстрации';

  @override
  String onboardingCreativityPercent(int percent) {
    return 'Креативность $percent%';
  }

  @override
  String get familyMom => 'Мама';

  @override
  String get familyDad => 'Папа';

  @override
  String get familySister => 'Сестра';

  @override
  String get familyBrother => 'Брат';

  @override
  String get familyGrandma => 'Бабушка';

  @override
  String get familyGrandpa => 'Дедушка';

  @override
  String get storyPreferencesTitle => 'Параметры истории';

  @override
  String get storyPreferencesCreativeControlTitle =>
      'Центр творческих настроек';

  @override
  String get storyPreferencesCreativeControlDescription =>
      'Эти параметры сохраняются автоматически и применяются при создании каждой новой истории.';

  @override
  String get storyPreferencesCharacterSection => 'Персонаж';

  @override
  String get storyPreferencesHeroNameLabel => 'Имя героя';

  @override
  String get storyPreferencesHeroNameHint => 'Луна, Арам, Мила...';

  @override
  String get storyPreferencesAgeSection => 'Возраст';

  @override
  String storyPreferencesAgeYears(int age) {
    return '$age лет';
  }

  @override
  String get storyPreferencesLengthSection => 'Длина';

  @override
  String get storyPreferencesLengthShort => 'Короткая';

  @override
  String get storyPreferencesLengthMedium => 'Средняя';

  @override
  String get storyPreferencesLengthLong => 'Длинная';

  @override
  String get storyPreferencesComplexitySection => 'Сложность';

  @override
  String get storyPreferencesComplexitySimple => 'Простая';

  @override
  String get storyPreferencesComplexityMedium => 'Средняя';

  @override
  String get storyPreferencesComplexityComplex => 'Сложная';

  @override
  String get storyPreferencesInteractivitySection => 'Интерактивность';

  @override
  String get storyPreferencesInteractiveChoices => 'Добавлять варианты выбора';

  @override
  String get storyPreferencesFamilySection => 'Семья';

  @override
  String get storyPreferencesIncludeFamilyMembers =>
      'Добавлять членов семьи в истории';

  @override
  String get storyPreferencesIllustrationsSection => 'Иллюстрации';

  @override
  String get storyPreferencesAddIllustrations =>
      'Добавлять иллюстрации автоматически';

  @override
  String get storyPreferencesCreativitySection => 'Креативность';

  @override
  String storyPreferencesCreativityPercent(int percent) {
    return '$percent%';
  }

  @override
  String get storyPreferencesResetButton => 'Сбросить параметры истории';

  @override
  String get storySetupTitle => 'Создать историю';

  @override
  String get storySetupPreferencesTooltip => 'Параметры истории';

  @override
  String get storySetupIdeaTitle => 'Поделитесь идеей истории';

  @override
  String get storySetupIdeaHint => 'Введите идею или используйте голос...';

  @override
  String get storySetupFamilyMode => 'Семейный режим';

  @override
  String get storySetupFamilyModeSubtitle =>
      'Добавлять членов семьи в сюжет и персонажей.';

  @override
  String get storySetupHeroSection => 'Герой';

  @override
  String get storySetupLocationSection => 'Локация';

  @override
  String get storySetupStyleSection => 'Стиль';

  @override
  String get storySetupGenerateButton => 'Сгенерировать';

  @override
  String get storySetupErrorNetwork =>
      'Не удалось связаться с сервисом историй. Проверьте подключение и попробуйте снова.';

  @override
  String get storySetupErrorGeneric =>
      'Не удалось создать историю. Попробуйте снова.';

  @override
  String get storyReaderNoStorySelected => 'История не выбрана.';

  @override
  String get storyReaderNoChapter => 'Пока нет доступной главы.';

  @override
  String get storyReaderProgressTitle => 'Прогресс истории';

  @override
  String get storyReaderComplete => 'История завершена';

  @override
  String storyReaderChapter(int index) {
    return 'Глава $index';
  }

  @override
  String get storyReaderWhatNext => 'Что будет дальше?';

  @override
  String get storyReaderTheEnd => 'Конец';

  @override
  String get storyReaderCompleteDescription =>
      'Это приключение завершено. Вы всегда можете начать новую историю.';

  @override
  String get storyReaderIllustrations => 'Иллюстрации';

  @override
  String get storyReaderPromptHint =>
      'Опишите, какую картинку вы хотите увидеть...';

  @override
  String get storyReaderGenerateImage => 'Сгенерировать изображение';

  @override
  String get storyReaderVoiceInput => 'Голосовой ввод';

  @override
  String get storyReaderUseRecognizedText => 'Использовать распознанный текст';

  @override
  String storyReaderLastPrompt(String prompt) {
    return 'Последний промпт: $prompt';
  }

  @override
  String get storyReaderErrorNetwork =>
      'Соединение нестабильно. Попробуйте снова.';

  @override
  String get storyReaderErrorGeneric =>
      'Что-то пошло не так. Попробуйте снова.';

  @override
  String get debugFirebaseTitle => 'Отладка Firebase';

  @override
  String debugFirebaseReady(String value) {
    return 'Firebase готов: $value';
  }

  @override
  String debugAppCheckAttempted(String value) {
    return 'AppCheck запущен: $value';
  }

  @override
  String debugBootstrapError(String value) {
    return 'Ошибка инициализации: $value';
  }

  @override
  String debugAuthService(String value) {
    return 'Сервис авторизации: $value';
  }

  @override
  String get voiceHelpTitle => 'Голосовая помощь';

  @override
  String get voiceHelpDescription =>
      'Используйте микрофон, чтобы быстро записывать идеи для истории и промптов.';

  @override
  String voiceHelpListening(String value) {
    return 'Прослушивание: $value';
  }

  @override
  String voiceHelpLastText(String value) {
    return 'Последний текст: $value';
  }

  @override
  String get voiceHelpStartListening => 'Начать запись';

  @override
  String get voiceHelpStop => 'Стоп';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsGeneralAccessibilityHeader => 'Общие / Доступность';

  @override
  String get settingsReduceMotionTitle => 'Уменьшить анимации';

  @override
  String get settingsReduceMotionSubtitle =>
      'Выключите, чтобы снизить количество переходов и движений.';

  @override
  String get settingsLanguageHeader => 'Язык';

  @override
  String get settingsLanguageTitle => 'Язык';

  @override
  String get settingsVoiceInputHelpTitle => 'Помощь по голосовому вводу';

  @override
  String get settingsVoiceInputLanguageTitle => 'Язык голосового ввода';

  @override
  String get settingsVoiceInputLanguageAuto => 'Авто';

  @override
  String get settingsVoiceInputLanguageApp => 'Язык приложения';

  @override
  String get settingsVoiceInputLanguageEnglish => 'Английский';

  @override
  String get settingsVoiceInputLanguageRussian => 'Русский';

  @override
  String get settingsVoiceInputLanguageArmenian => 'Армянский';

  @override
  String get settingsDefaultNarrationVoiceTitle => 'Голос озвучки по умолчанию';

  @override
  String get settingsDefaultNarrationVoiceComingSoon => 'Скоро';

  @override
  String get settingsAudioHeader => 'Аудио';

  @override
  String get settingsVoiceNarrationTitle => 'Озвучивание';

  @override
  String get settingsDefaultNarrationVoiceSystemTitle =>
      'Голос озвучки по умолчанию';

  @override
  String get settingsDefaultNarrationVoiceSystemSubtitle =>
      'Системный выбор по умолчанию';

  @override
  String get settingsVolumeTitle => 'Громкость';

  @override
  String get settingsSpeedTitle => 'Скорость';

  @override
  String get settingsIntensityTitle => 'Интонация';

  @override
  String get settingsTestVoiceButton => 'Проверить голос';

  @override
  String get settingsChooseVoiceSheetTitle => 'Выберите голос озвучки';

  @override
  String get settingsNoVoicesAvailable =>
      'Для этого языка нет доступных голосов.';

  @override
  String get settingsLoadingVoices => 'Загрузка голосов...';

  @override
  String get settingsLanguageScreenTitle => 'Язык';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsLanguageArmenian => 'Հայերեն';

  @override
  String get settingsVoiceHelpScreenTitle => 'Помощь по голосовому вводу';

  @override
  String get settingsVoiceHelpDescription =>
      'Используйте голосовой ввод, чтобы быстро фиксировать идеи для историй.';

  @override
  String get settingsVoiceHelpPointOne =>
      'Говорите чётко и держите устройство ближе.';

  @override
  String get settingsVoiceHelpPointTwo =>
      'Поддерживаются армянский, русский и английский языки.';

  @override
  String get settingsVoiceHelpPointThree =>
      'Перед генерацией вы можете отредактировать распознанный текст.';

  @override
  String get settingsTestVoicePhrase => 'Привет! Так звучит ваш голос озвучки.';

  @override
  String get settingsSystemDefaultLabel => 'Системный по умолчанию';

  @override
  String get settingsTtsLanguageModeTitle => 'Язык озвучки';

  @override
  String get settingsTtsLanguageModeAuto => 'Автоопределение';

  @override
  String get settingsTtsLanguageModeFollowApp => 'Как в приложении';

  @override
  String get settingsTtsLanguageModeEnglish => 'Английский (США)';

  @override
  String get settingsTtsLanguageModeRussian => 'Русский';

  @override
  String get settingsTtsLanguageModeArmenian => 'Армянский';

  @override
  String get settingsVoiceGenderTitle => 'Предпочитаемый голос';

  @override
  String get settingsVoiceGenderAny => 'Любой';

  @override
  String get settingsVoiceGenderFemale => 'Женский';

  @override
  String get settingsVoiceGenderMale => 'Мужской';

  @override
  String get settingsVoiceQualityTitle => 'Профиль качества';

  @override
  String get settingsVoiceQualityDefault => 'По умолчанию';

  @override
  String get settingsVoiceQualityExpressive => 'ProPlus Expressive';

  @override
  String get settingsVoiceQualityHighRes => 'ProPlus High-Res';

  @override
  String get settingsVoiceQualityTurbo => 'ProPlus Turbo';

  @override
  String get settingsVoiceQualityPro2 => 'Pro2';

  @override
  String get settingsVoiceQualityPro1 => 'Pro1';

  @override
  String get ttsListenButton => 'Слушать';

  @override
  String get ttsNarrationTitle => 'Озвучка';

  @override
  String get ttsVoiceGenderLabel => 'Пол голоса';

  @override
  String get ttsVoiceLabel => 'Голос';

  @override
  String get ttsLanguageModeLabel => 'Режим языка';

  @override
  String get ttsQualityPresetLabel => 'Качество';

  @override
  String get ttsVolumeLabel => 'Громкость';

  @override
  String get ttsSpeedLabel => 'Скорость';

  @override
  String get ttsIntensityLabel => 'Интонация';

  @override
  String get ttsPlayLabel => 'Воспроизвести';

  @override
  String get ttsPauseLabel => 'Пауза';

  @override
  String get ttsResumeLabel => 'Продолжить';

  @override
  String get ttsStopLabel => 'Остановить';

  @override
  String get ttsPreparingAudioLabel => 'Подготовка аудио...';

  @override
  String ttsPreparingAudioChunks(int current, int total) {
    return 'Подготовка аудио... ($current/$total фрагментов)';
  }

  @override
  String get ttsPlayingLabel => 'Воспроизведение...';

  @override
  String get ttsPausedLabel => 'Пауза';

  @override
  String get ttsCompletedLabel => 'Завершено';

  @override
  String get ttsErrorNoVoices => 'Нет голосов для выбранных фильтров.';

  @override
  String get ttsGenderAny => 'Любой';

  @override
  String get ttsGenderFemale => 'Женский';

  @override
  String get ttsGenderMale => 'Мужской';

  @override
  String get ttsLanguageAuto => 'Авто';

  @override
  String get ttsLanguageFollowApp => 'Как в приложении';

  @override
  String get ttsLanguageEnglish => 'Английский (США)';

  @override
  String get ttsLanguageRussian => 'Русский';

  @override
  String get ttsLanguageArmenian => 'Армянский';

  @override
  String get ttsQualityDefault => 'По умолчанию';

  @override
  String get ttsQualityExpressive => 'ProPlus Expressive';

  @override
  String get ttsQualityHighRes => 'ProPlus High-Res';

  @override
  String get ttsQualityTurbo => 'ProPlus Turbo';

  @override
  String get ttsQualityPro2 => 'Pro2';

  @override
  String get ttsQualityPro1 => 'Pro1';

  @override
  String get ttsNarrationDisabled => 'Озвучивание отключено в настройках.';

  @override
  String get ttsErrorNarrationEmpty => 'Текст для озвучки пуст.';

  @override
  String get ttsErrorNoVoicesForLanguage =>
      'Для этого языка нет доступных голосов.';

  @override
  String get ttsErrorSelectVoice => 'Не удалось выбрать голос озвучки.';

  @override
  String get ttsErrorNoAudioChunks => 'Аудиофрагменты не были сгенерированы.';

  @override
  String get ttsErrorNetwork =>
      'Сетевое соединение нестабильно. Попробуйте снова.';

  @override
  String get ttsErrorStart => 'Не удалось запустить озвучку. Попробуйте снова.';

  @override
  String get sttRecordingTapToStop =>
      'Идёт запись... Нажмите, чтобы остановить';

  @override
  String get sttProcessingVoice => 'Обработка голоса...';

  @override
  String get sttTapMicToUseVoice => 'Нажмите на микрофон для голосового ввода';

  @override
  String sttDetectedLanguage(String language) {
    return 'Определённый язык: $language';
  }

  @override
  String get sttStartRecordingTooltip => 'Начать запись';

  @override
  String get sttStopRecordingTooltip => 'Остановить запись';

  @override
  String get sttErrorPermissionRequired =>
      'Для голосового ввода нужен доступ к микрофону.';

  @override
  String get sttErrorUnableStartRecording =>
      'Не удалось начать запись. Попробуйте снова.';

  @override
  String get sttErrorAudioNotCreated => 'Аудиофайл записи не был создан.';

  @override
  String get sttErrorAudioNotFound => 'Аудиофайл записи не найден.';

  @override
  String get sttErrorProcessingInProgress =>
      'Транскрибация в процессе. Попробуйте более короткую запись.';

  @override
  String get sttErrorNetwork =>
      'Сетевое соединение нестабильно. Попробуйте снова.';

  @override
  String get sttErrorFailed => 'Не удалось распознать голос. Попробуйте снова.';

  @override
  String get sttErrorKeyMissing =>
      'Отсутствует VOICEMAKER_API_KEY. Запустите с --dart-define=VOICEMAKER_API_KEY=<key>.';

  @override
  String get sttErrorProxyMissing =>
      'Не указан URL STT-прокси. Используйте --dart-define=STT_PROXY_URL=<backend_url>.';

  @override
  String get sttErrorProxyInvalid => 'Некорректный URL STT-прокси.';

  @override
  String get storyRequestLogLangHeader => 'Язык запроса';
}
