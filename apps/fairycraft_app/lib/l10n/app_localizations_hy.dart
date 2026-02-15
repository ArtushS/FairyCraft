// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Armenian (`hy`).
class AppLocalizationsHy extends AppLocalizations {
  AppLocalizationsHy([String locale = 'hy']) : super(locale);

  @override
  String get appName => 'FairyCraft';

  @override
  String get commonAccount => 'Հաշիվ';

  @override
  String get commonSettings => 'Կարգավորումներ';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Գաղտնաբառ';

  @override
  String get commonBackToLogin => 'Վերադառնալ մուտքին';

  @override
  String get commonRetry => 'Կրկին փորձել';

  @override
  String get commonContinue => 'Շարունակել';

  @override
  String get commonDone => 'Պատրաստ է';

  @override
  String get commonSkip => 'Բաց թողնել';

  @override
  String get commonNotAvailable => 'Հասանելի չէ';

  @override
  String get commonLink => 'Կապել';

  @override
  String get commonUnlink => 'Անջատել';

  @override
  String get commonStop => 'Կանգ';

  @override
  String get commonUpdate => 'Թարմացնել';

  @override
  String get homeTagline =>
      'Հանգիստ միջավայր՝ միասին քնելուց առաջ հեքիաթներ ստեղծելու համար։';

  @override
  String get homeCreateStoryTitle => 'Ստեղծել հեքիաթ';

  @override
  String get homeCreateStorySubtitle => 'Սկսեք նոր արկած մեկ հպումով։';

  @override
  String get homeMyStoriesTitle => 'Իմ հեքիաթները';

  @override
  String get homeMyStoriesSubtitle => 'Շարունակեք կարդալ պահպանված գլուխները։';

  @override
  String get homeStoryPreferences => 'Հեքիաթի նախընտրություններ';

  @override
  String get homeAccountTooltip => 'Հաշիվ';

  @override
  String get homeSettingsTooltip => 'Կարգավորումներ';

  @override
  String get authLoginTitle => 'FairyCraft մուտք';

  @override
  String get authLoginButton => 'Մուտք գործել';

  @override
  String get authCreateAccountButton => 'Ստեղծել հաշիվ';

  @override
  String get authForgotPasswordButton => 'Մոռացե՞լ եք գաղտնաբառը';

  @override
  String authLoginFailed(String error) {
    return 'Մուտքը ձախողվեց՝ $error';
  }

  @override
  String get authRegisterTitle => 'Ստեղծել FairyCraft հաշիվ';

  @override
  String get authRegisterButton => 'Գրանցվել';

  @override
  String authRegisterFailed(String error) {
    return 'Գրանցումը ձախողվեց՝ $error';
  }

  @override
  String get authResetPasswordTitle => 'Վերականգնել գաղտնաբառը';

  @override
  String get authSendResetEmailButton => 'Ուղարկել նամակ';

  @override
  String authResetEmailFailed(String error) {
    return 'Չհաջողվեց ուղարկել վերականգնման նամակը՝ $error';
  }

  @override
  String get authResetSentTitle => 'Նամակն ուղարկվեց';

  @override
  String get authResetSentBody =>
      'Եթե email-ը գոյություն ունի, վերականգնման հրահանգներն արդեն ուղարկվել են։';

  @override
  String get authCheckingSession => 'Ստուգում ենք սեսիան...';

  @override
  String get authSessionSlow =>
      'Սեսիայի ստուգումը սովորականից ավելի երկար է տևում։';

  @override
  String get authChangePasswordTitle => 'Փոխել գաղտնաբառը';

  @override
  String get authNewPasswordLabel => 'Նոր գաղտնաբառ';

  @override
  String get authPasswordUpdated => 'Գաղտնաբառը թարմացվեց։';

  @override
  String authPasswordChangeFailed(String error) {
    return 'Սխալ՝ $error';
  }

  @override
  String get authProviderLinkTitle => 'Պրովայդերի կապում';

  @override
  String get authLinkGoogleStub => 'Կապել Google-ը (stub)';

  @override
  String get authLinkFacebookStub => 'Կապել Facebook-ը (stub)';

  @override
  String authProviderLinkRequested(String provider) {
    return '$provider-ի կապման հարցումը կատարվեց (առայժմ stub)։';
  }

  @override
  String authProviderLinkFailed(String error) {
    return 'Սխալ՝ $error';
  }

  @override
  String get accountTitle => 'Հաշիվ';

  @override
  String get accountEmailLabel => 'Email';

  @override
  String get accountLinkedProviders => 'Կապված պրովայդերներ';

  @override
  String get accountGoogle => 'Google';

  @override
  String get accountFacebook => 'Facebook';

  @override
  String get accountEmailPassword => 'Email և գաղտնաբառ';

  @override
  String get accountLogout => 'Դուրս գալ';

  @override
  String accountProviderUnlinked(String provider) {
    return '$provider-ը անջատվեց։';
  }

  @override
  String accountProviderLinkRequested(String provider) {
    return '$provider-ի կապումը հարցվել է։';
  }

  @override
  String get accountProviderUpdateFailed =>
      'Չհաջողվեց թարմացնել պրովայդերը։ Փորձեք կրկին։';

  @override
  String get myStoriesTitle => 'Իմ հեքիաթները';

  @override
  String get myStoriesEmpty => 'Դեռ հեքիաթ չկա։';

  @override
  String myStoriesChaptersCount(int count) {
    return 'Գլուխներ՝ $count';
  }

  @override
  String get onboardingWelcomeTitle => 'Բարի գալուստ';

  @override
  String get onboardingHeroTitle => 'Ինչպե՞ս է կոչվում ձեր հերոսը';

  @override
  String get onboardingHeroDescription =>
      'Հերոսի անունը կհայտնվի ձեր հեքիաթներում և կարող եք փոխել ցանկացած պահի։';

  @override
  String get onboardingHeroNameLabel => 'Հերոսի անուն';

  @override
  String get onboardingHeroNameHint => 'Լունա, Արամ, Միա...';

  @override
  String get onboardingAgeTitle => 'Ո՞ր տարիքի համար են հեքիաթները';

  @override
  String get onboardingAgeDescription =>
      'Սա օգնում է ընտրել հարմար բառապաշար և պատմման տեմպ։';

  @override
  String onboardingAgeYears(int age) {
    return '$age տարեկան';
  }

  @override
  String get onboardingFamilyTitle => 'Ովքե՞ր են ձեր ընտանիքում';

  @override
  String get onboardingFamilyDescription =>
      'Ընտանեկան ռեժիմը օգնում է հեքիաթներում ավելացնել հարազատ կերպարներ։';

  @override
  String get onboardingUseFamilyMode => 'Օգտագործել ընտանեկան ռեժիմ';

  @override
  String get onboardingIllustrationsTitle =>
      'Իլյուստրացիաներ և ստեղծարարություն';

  @override
  String get onboardingIllustrationsDescription =>
      'Ընտրեք՝ հեքիաթում պատկերներ ավելացնե՞լ, և որքան ստեղծարար լինի պատմությունը։';

  @override
  String get onboardingAutoIllustrations => 'Ավտո իլյուստրացիաներ';

  @override
  String onboardingCreativityPercent(int percent) {
    return 'Ստեղծարարություն $percent%';
  }

  @override
  String get familyMom => 'Մամա';

  @override
  String get familyDad => 'Պապա';

  @override
  String get familySister => 'Քույր';

  @override
  String get familyBrother => 'Եղբայր';

  @override
  String get familyGrandma => 'Տատիկ';

  @override
  String get familyGrandpa => 'Պապիկ';

  @override
  String get storyPreferencesTitle => 'Հեքիաթի նախընտրություններ';

  @override
  String get storyPreferencesCreativeControlTitle =>
      'Ստեղծարար կառավարման կենտրոն';

  @override
  String get storyPreferencesCreativeControlDescription =>
      'Այս նախընտրությունները պահվում են ավտոմատ և կիրառվում են ամեն անգամ հեքիաթ ստեղծելիս։';

  @override
  String get storyPreferencesCharacterSection => 'Կերպար';

  @override
  String get storyPreferencesHeroNameLabel => 'Հերոսի անուն';

  @override
  String get storyPreferencesHeroNameHint => 'Լունա, Արամ, Միլա...';

  @override
  String get storyPreferencesAgeSection => 'Տարիք';

  @override
  String storyPreferencesAgeYears(int age) {
    return '$age տարեկան';
  }

  @override
  String get storyPreferencesLengthSection => 'Երկարություն';

  @override
  String get storyPreferencesLengthShort => 'Կարճ';

  @override
  String get storyPreferencesLengthMedium => 'Միջին';

  @override
  String get storyPreferencesLengthLong => 'Երկար';

  @override
  String get storyPreferencesComplexitySection => 'Բարդություն';

  @override
  String get storyPreferencesComplexitySimple => 'Պարզ';

  @override
  String get storyPreferencesComplexityMedium => 'Միջին';

  @override
  String get storyPreferencesComplexityComplex => 'Բարդ';

  @override
  String get storyPreferencesInteractivitySection => 'Ինտերակտիվություն';

  @override
  String get storyPreferencesInteractiveChoices =>
      'Ավելացնել ընտրության տարբերակներ';

  @override
  String get storyPreferencesFamilySection => 'Ընտանիք';

  @override
  String get storyPreferencesIncludeFamilyMembers =>
      'Հեքիաթներում ներառել ընտանիքի անդամներին';

  @override
  String get storyPreferencesIllustrationsSection => 'Իլյուստրացիաներ';

  @override
  String get storyPreferencesAddIllustrations =>
      'Ավելացնել իլյուստրացիաներ ավտոմատ';

  @override
  String get storyPreferencesCreativitySection => 'Ստեղծարարություն';

  @override
  String storyPreferencesCreativityPercent(int percent) {
    return '$percent%';
  }

  @override
  String get storyPreferencesResetButton =>
      'Վերակայել հեքիաթի նախընտրությունները';

  @override
  String get storySetupTitle => 'Ստեղծել հեքիաթ';

  @override
  String get storySetupPreferencesTooltip => 'Հեքիաթի նախընտրություններ';

  @override
  String get storySetupIdeaTitle => 'Պատմեք հեքիաթի ձեր գաղափարը';

  @override
  String get storySetupIdeaHint =>
      'Մուտքագրեք գաղափարը կամ օգտագործեք ձայնը...';

  @override
  String get storySetupFamilyMode => 'Ընտանեկան ռեժիմ';

  @override
  String get storySetupFamilyModeSubtitle =>
      'Սյուժեում և կերպարներում ներառել ընտանիքի անդամներին։';

  @override
  String get storySetupHeroSection => 'Հերոս';

  @override
  String get storySetupLocationSection => 'Վայր';

  @override
  String get storySetupStyleSection => 'Ոճ';

  @override
  String get storySetupGenerateButton => 'Ստեղծել';

  @override
  String get storySetupErrorNetwork =>
      'Չհաջողվեց կապվել հեքիաթի ծառայության հետ։ Ստուգեք կապը և փորձեք կրկին։';

  @override
  String get storySetupErrorGeneric =>
      'Հեքիաթի ստեղծումը չհաջողվեց։ Փորձեք կրկին։';

  @override
  String get storyReaderNoStorySelected => 'Հեքիաթ ընտրված չէ։';

  @override
  String get storyReaderNoChapter => 'Դեռ հասանելի գլուխ չկա։';

  @override
  String get storyReaderProgressTitle => 'Հեքիաթի առաջընթաց';

  @override
  String get storyReaderComplete => 'Հեքիաթը ավարտված է';

  @override
  String storyReaderChapter(int index) {
    return 'Գլուխ $index';
  }

  @override
  String get storyReaderWhatNext => 'Ի՞նչ կլինի հետո';

  @override
  String get storyReaderTheEnd => 'Վերջ';

  @override
  String get storyReaderCompleteDescription =>
      'Այս արկածը ավարտվեց։ Կարող եք ցանկացած պահի սկսել նոր հեքիաթ։';

  @override
  String get storyReaderIllustrations => 'Իլյուստրացիաներ';

  @override
  String get storyReaderPromptHint =>
      'Նկարագրեք, թե ինչ պատկեր եք ուզում տեսնել...';

  @override
  String get storyReaderGenerateImage => 'Ստեղծել պատկեր';

  @override
  String get storyReaderVoiceInput => 'Ձայնային մուտք';

  @override
  String get storyReaderUseRecognizedText => 'Օգտագործել ճանաչված տեքստը';

  @override
  String storyReaderLastPrompt(String prompt) {
    return 'Վերջին prompt-ը՝ $prompt';
  }

  @override
  String get storyReaderErrorNetwork => 'Կապը անկայուն է։ Փորձեք կրկին։';

  @override
  String get storyReaderErrorGeneric => 'Ինչ-որ բան սխալ գնաց։ Փորձեք կրկին։';

  @override
  String get debugFirebaseTitle => 'Firebase կարգաբերում';

  @override
  String debugFirebaseReady(String value) {
    return 'Firebase պատրաստ է՝ $value';
  }

  @override
  String debugAppCheckAttempted(String value) {
    return 'AppCheck-ը փորձարկվել է՝ $value';
  }

  @override
  String debugBootstrapError(String value) {
    return 'Բեռնման սխալ՝ $value';
  }

  @override
  String debugAuthService(String value) {
    return 'Auth ծառայություն՝ $value';
  }

  @override
  String get voiceHelpTitle => 'Ձայնային օգնություն';

  @override
  String get voiceHelpDescription =>
      'Օգտագործեք միկրոֆոնը, որպեսզի արագ գրանցեք գաղափարներ հեքիաթի համար։';

  @override
  String voiceHelpListening(String value) {
    return 'Լսում է՝ $value';
  }

  @override
  String voiceHelpLastText(String value) {
    return 'Վերջին տեքստը՝ $value';
  }

  @override
  String get voiceHelpStartListening => 'Սկսել լսել';

  @override
  String get voiceHelpStop => 'Կանգ';

  @override
  String get settingsTitle => 'Կարգավորումներ';

  @override
  String get settingsGeneralAccessibilityHeader => 'Ընդհանուր / Մատչելիություն';

  @override
  String get settingsReduceMotionTitle => 'Նվազեցնել անիմացիան';

  @override
  String get settingsReduceMotionSubtitle =>
      'Անջատեք՝ անցումները և շարժումները նվազեցնելու համար։';

  @override
  String get settingsLanguageHeader => 'Լեզու';

  @override
  String get settingsLanguageTitle => 'Լեզու';

  @override
  String get settingsVoiceInputHelpTitle => 'Ձայնային մուտքի օգնություն';

  @override
  String get settingsVoiceInputLanguageTitle => 'Ձայնային մուտքի լեզու';

  @override
  String get settingsVoiceInputLanguageAuto => 'Ավտո';

  @override
  String get settingsVoiceInputLanguageApp => 'Հավելվածի լեզու';

  @override
  String get settingsVoiceInputLanguageEnglish => 'Անգլերեն';

  @override
  String get settingsVoiceInputLanguageRussian => 'Ռուսերեն';

  @override
  String get settingsVoiceInputLanguageArmenian => 'Հայերեն';

  @override
  String get settingsDefaultNarrationVoiceTitle => 'Լռելյայն ձայն';

  @override
  String get settingsDefaultNarrationVoiceComingSoon => 'Շուտով';

  @override
  String get settingsAudioHeader => 'Աուդիո';

  @override
  String get settingsVoiceNarrationTitle => 'Ձայնային ընթերցում';

  @override
  String get settingsDefaultNarrationVoiceSystemTitle => 'Լռելյայն ձայն';

  @override
  String get settingsDefaultNarrationVoiceSystemSubtitle =>
      'Համակարգային լռելյայն ընտրիչ';

  @override
  String get settingsVolumeTitle => 'Ձայնի ուժգնություն';

  @override
  String get settingsSpeedTitle => 'Արագություն';

  @override
  String get settingsIntensityTitle => 'Ինտենսիվություն';

  @override
  String get settingsTestVoiceButton => 'Ստուգել ձայնը';

  @override
  String get settingsChooseVoiceSheetTitle => 'Ընտրեք ընթերցման ձայնը';

  @override
  String get settingsNoVoicesAvailable =>
      'Այս լեզվի համար ձայներ հասանելի չեն։';

  @override
  String get settingsLoadingVoices => 'Ձայների բեռնում...';

  @override
  String get settingsLanguageScreenTitle => 'Լեզու';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsLanguageArmenian => 'Հայերեն';

  @override
  String get settingsVoiceHelpScreenTitle => 'Ձայնային մուտքի օգնություն';

  @override
  String get settingsVoiceHelpDescription =>
      'Օգտագործեք ձայնային մուտքը՝ հեքիաթների գաղափարները արագ գրանցելու համար։';

  @override
  String get settingsVoiceHelpPointOne => 'Խոսեք հստակ և սարքը պահեք մոտ։';

  @override
  String get settingsVoiceHelpPointTwo =>
      'Աջակցվում են հայերեն, ռուսերեն և անգլերեն լեզուները։';

  @override
  String get settingsVoiceHelpPointThree =>
      'Ճանաչված տեքստը կարող եք խմբագրել մինչև գեներացումը։';

  @override
  String get settingsTestVoicePhrase =>
      'Բարև։ Ահա թե ինչպես է հնչում ձեր ընթերցման ձայնը։';

  @override
  String get settingsSystemDefaultLabel => 'Համակարգային լռելյայն';

  @override
  String get settingsTtsLanguageModeTitle => 'Ընթերցման լեզու';

  @override
  String get settingsTtsLanguageModeAuto => 'Ավտո որոշում';

  @override
  String get settingsTtsLanguageModeFollowApp => 'Հետևել հավելվածի լեզվին';

  @override
  String get settingsTtsLanguageModeEnglish => 'Անգլերեն (ԱՄՆ)';

  @override
  String get settingsTtsLanguageModeRussian => 'Ռուսերեն';

  @override
  String get settingsTtsLanguageModeArmenian => 'Հայերեն';

  @override
  String get settingsVoiceGenderTitle => 'Նախընտրելի ձայնի սեռ';

  @override
  String get settingsVoiceGenderAny => 'Ցանկացած';

  @override
  String get settingsVoiceGenderFemale => 'Իգական';

  @override
  String get settingsVoiceGenderMale => 'Արական';

  @override
  String get settingsVoiceQualityTitle => 'Ձայնի որակի պրոֆիլ';

  @override
  String get settingsVoiceQualityDefault => 'Լռելյայն';

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
  String get ttsListenButton => 'Լսել';

  @override
  String get ttsNarrationTitle => 'Ընթերցում';

  @override
  String get ttsVoiceGenderLabel => 'Ձայնի սեռ';

  @override
  String get ttsVoiceLabel => 'Ձայն';

  @override
  String get ttsLanguageModeLabel => 'Լեզվի ռեժիմ';

  @override
  String get ttsQualityPresetLabel => 'Որակ';

  @override
  String get ttsVolumeLabel => 'Ձայնի ուժգնություն';

  @override
  String get ttsSpeedLabel => 'Արագություն';

  @override
  String get ttsIntensityLabel => 'Ինտենսիվություն';

  @override
  String get ttsPlayLabel => 'Նվագարկել';

  @override
  String get ttsPauseLabel => 'Դադար';

  @override
  String get ttsResumeLabel => 'Շարունակել';

  @override
  String get ttsStopLabel => 'Կանգ';

  @override
  String get ttsPreparingAudioLabel => 'Պատրաստում ենք աուդիոն...';

  @override
  String ttsPreparingAudioChunks(int current, int total) {
    return 'Պատրաստում ենք աուդիոն... ($current/$total մաս)';
  }

  @override
  String get ttsPlayingLabel => 'Նվագարկվում է...';

  @override
  String get ttsPausedLabel => 'Դադար';

  @override
  String get ttsCompletedLabel => 'Ավարտված';

  @override
  String get ttsErrorNoVoices => 'Ընտրված ֆիլտրերի համար ձայներ չկան։';

  @override
  String get ttsGenderAny => 'Ցանկացած';

  @override
  String get ttsGenderFemale => 'Իգական';

  @override
  String get ttsGenderMale => 'Արական';

  @override
  String get ttsLanguageAuto => 'Ավտո';

  @override
  String get ttsLanguageFollowApp => 'Հետևել հավելվածի լեզվին';

  @override
  String get ttsLanguageEnglish => 'Անգլերեն (ԱՄՆ)';

  @override
  String get ttsLanguageRussian => 'Ռուսերեն';

  @override
  String get ttsLanguageArmenian => 'Հայերեն';

  @override
  String get ttsQualityDefault => 'Լռելյայն';

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
  String get ttsNarrationDisabled =>
      'Ձայնային ընթերցումը անջատված է Կարգավորումներում։';

  @override
  String get ttsErrorNarrationEmpty => 'Ընթերցման տեքստը դատարկ է։';

  @override
  String get ttsErrorNoVoicesForLanguage =>
      'Այս լեզվի համար ձայներ հասանելի չեն։';

  @override
  String get ttsErrorSelectVoice => 'Չհաջողվեց ընտրել ընթերցման ձայնը։';

  @override
  String get ttsErrorNoAudioChunks => 'Աուդիո հատվածներ չեն ստեղծվել։';

  @override
  String get ttsErrorNetwork => 'Ցանցային կապը անկայուն է։ Փորձեք կրկին։';

  @override
  String get ttsErrorStart => 'Չհաջողվեց սկսել ընթերցումը։ Փորձեք կրկին։';

  @override
  String get sttRecordingTapToStop => 'Գրանցում... Հպեք կանգնեցնելու համար';

  @override
  String get sttProcessingVoice => 'Ձայնի մշակում...';

  @override
  String get sttTapMicToUseVoice => 'Հպեք միկրոֆոնին՝ ձայնային մուտքի համար';

  @override
  String sttDetectedLanguage(String language) {
    return 'Հայտնաբերված լեզու՝ $language';
  }

  @override
  String get sttStartRecordingTooltip => 'Սկսել ձայնագրումը';

  @override
  String get sttStopRecordingTooltip => 'Կանգնեցնել ձայնագրումը';

  @override
  String get sttErrorPermissionRequired =>
      'Ձայնային մուտքի համար անհրաժեշտ է միկրոֆոնի թույլտվություն։';

  @override
  String get sttErrorUnableStartRecording =>
      'Չհաջողվեց սկսել ձայնագրումը։ Փորձեք կրկին։';

  @override
  String get sttErrorAudioNotCreated => 'Ձայնագրության ֆայլը չի ստեղծվել։';

  @override
  String get sttErrorAudioNotFound => 'Ձայնագրության ֆայլը չի գտնվել։';

  @override
  String get sttErrorProcessingInProgress =>
      'Վերծանումը ընթացքի մեջ է։ Փորձեք ավելի կարճ ձայնագրություն։';

  @override
  String get sttErrorNetwork => 'Ցանցային կապը անկայուն է։ Փորձեք կրկին։';

  @override
  String get sttErrorFailed => 'Չհաջողվեց վերծանել ձայնը։ Փորձեք կրկին։';

  @override
  String get sttErrorKeyMissing =>
      'VOICEMAKER_API_KEY-ը բացակայում է։ Գործարկեք --dart-define=VOICEMAKER_API_KEY=<key> դրոշով։';

  @override
  String get sttErrorProxyMissing =>
      'STT proxy URL-ը բացակայում է։ Օգտագործեք --dart-define=STT_PROXY_URL=<backend_url>։';

  @override
  String get sttErrorProxyInvalid => 'STT proxy URL-ը սխալ է։';

  @override
  String get storyRequestLogLangHeader => 'Հարցման լեզու';
}
