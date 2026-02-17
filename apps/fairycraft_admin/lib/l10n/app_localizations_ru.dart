// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String policiesLanguageFilterLabel(String value) {
    return 'Язык: $value';
  }

  @override
  String policiesTierFilterLabel(String value) {
    return 'Тариф: $value';
  }

  @override
  String get policiesAgeRangeFilter => 'Фильтр по возрасту';

  @override
  String get policiesNewPolicy => 'Новая политика';

  @override
  String get commonReload => 'Перезагрузить';

  @override
  String get policiesBackfillInProgress => 'Заполнение...';

  @override
  String get policiesBackfillButton => 'Заполнить allowPersonalNames';

  @override
  String policiesBackfillSummary(int scanned, int updated, int skipped) {
    return 'Готово. Просканировано: $scanned, обновлено: $updated, пропущено: $skipped.';
  }

  @override
  String get policiesDeletePolicyTitle => 'Удалить политику';

  @override
  String policiesDeletePolicyConfirm(String id) {
    return 'Удалить политику \"$id\"? Это действие необратимо.';
  }

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get policiesColumnActive => 'Активна';

  @override
  String get policiesColumnPolicyId => 'ID политики';

  @override
  String get policiesColumnScope => 'Область';

  @override
  String get policiesColumnReadingLevel => 'Уровень чтения';

  @override
  String get policiesColumnVersionStamp => 'Версия';

  @override
  String get policiesColumnActions => 'Действия';

  @override
  String get commonEdit => 'Редактировать';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonRemove => 'Удалить';

  @override
  String get testConsoleTitle => 'Тестовая консоль агента';

  @override
  String get testConsoleDescription => 'Выполняет локальное разрешение эффективной политики, вызывает dry-run шлюза и сохраняет test_runs_v1.';

  @override
  String get tcAgeLabel => 'Возраст';

  @override
  String get tcTierLabel => 'Тариф';

  @override
  String get tcLanguageLabel => 'Язык';

  @override
  String get tcHeroTypeLabel => 'Тип героя';

  @override
  String get tcHeroAgeLabel => 'Возраст героя';

  @override
  String get tcStoryIdeaLabel => 'Идея истории';

  @override
  String get tcLocationLabel => 'Место';

  @override
  String get tcGenreLabel => 'Жанр';

  @override
  String get tcLengthLabel => 'Длина';

  @override
  String get tcComplexityLabel => 'Сложность';

  @override
  String get tcCreativityLabel => 'Креативность';

  @override
  String get tcFamilyMembersLabel => 'Члены семьи (dad:1,mom:1,grandma:1)';

  @override
  String get tcFamilyNamesTitle => 'Имена семьи (опционально)';

  @override
  String get tcMomNameLabel => 'Имя мамы';

  @override
  String get tcDadNameLabel => 'Имя папы';

  @override
  String get tcGrandmaNameLabel => 'Имя бабушки';

  @override
  String get tcGrandpaNameLabel => 'Имя дедушки';

  @override
  String get tcBrothersNamesTitle => 'Имена братьев (опционально)';

  @override
  String get tcSistersNamesTitle => 'Имена сестер (опционально)';

  @override
  String get tcAddBrotherButton => 'Добавить брата';

  @override
  String get tcAddSisterButton => 'Добавить сестру';

  @override
  String get tcBrotherLabel => 'Брат';

  @override
  String get tcSisterLabel => 'Сестра';

  @override
  String tcIndexedName(String prefix, int index) {
    return '$prefix $index имя';
  }

  @override
  String get tcRemoveTooltip => 'Удалить';

  @override
  String get tcIllustrationsEnabled => 'Иллюстрации включены';

  @override
  String get tcSafeMode => 'Режим безопасности';

  @override
  String get tcDisableScary => 'Отключить страшный контент';

  @override
  String get tcRequireParentConfirmation => 'Требовать подтверждение родителя для старших';

  @override
  String get tcRunButton => 'Запустить dry-run через шлюз';

  @override
  String get tcRunning => 'Запуск...';

  @override
  String tcEffectivePolicyHeader(String id) {
    return 'Эффективная политика: $id';
  }

  @override
  String tcTemplatesMatched(int count) {
    return 'Совпавшие шаблоны: $count';
  }

  @override
  String get tcCardEffectivePolicy => 'Эффективная политика + выбор шаблонов';

  @override
  String get tcCardComposedPayload => 'Составленный payload';

  @override
  String get tcCardGatewayResponse => 'Ответ шлюза';

  @override
  String get templatesSearchHint => 'Поиск по имени/тегу/описанию';

  @override
  String templatesTypeFilterLabel(String value) {
    return 'Тип: $value';
  }

  @override
  String get templatesNewTemplate => 'Новый шаблон';

  @override
  String get templatesColumnActive => 'Активен';

  @override
  String get templatesColumnName => 'Имя';

  @override
  String get templatesColumnType => 'Тип';

  @override
  String get templatesColumnTags => 'Теги';

  @override
  String get templatesColumnScopes => 'Области';

  @override
  String get templatesColumnActions => 'Действия';

  @override
  String templatesEditorTitle(String id) {
    return 'Шаблон: $id';
  }

  @override
  String get templatesTemplateTypeLabel => 'Тип шаблона';

  @override
  String get templatesDescriptionLabel => 'Описание';

  @override
  String get templatesTagsLabel => 'Теги (запятые/новая строка)';

  @override
  String get templatesScopesHeader => 'Области';

  @override
  String get templatesAddScopeButton => 'Добавить область';

  @override
  String get templatesTemplateBody => 'Тело шаблона';

  @override
  String get templatesSystemPromptLabel => 'Системная подсказка (опционально)';

  @override
  String get templatesInstructionsLabel => 'Инструкции';

  @override
  String get templatesNegativePromptLabel => 'Негативная подсказка (опционально)';

  @override
  String get policyAgeMinLabel => 'Мин. возраст';

  @override
  String get policyAgeMaxLabel => 'Макс. возраст';

  @override
  String get policyScopeLanguageLabel => 'Язык';

  @override
  String get policyScopeTierLabel => 'Тариф';

  @override
  String get templatesArchiveTitle => 'Архивировать шаблон';

  @override
  String templatesArchiveConfirm(String name) {
    return 'Удалить шаблон \"$name\"? Это действие необратимо.';
  }

  @override
  String policyEditorTitle(String id) {
    return 'Редактировать политику: $id';
  }

  @override
  String get policyActive => 'Активна';

  @override
  String get policyScope => 'Область';

  @override
  String get policyContentRules => 'Правила контента';

  @override
  String get policySafeModeDefault => 'Режим безопасности по умолчанию';

  @override
  String get policyDisallowViolence => 'Запретить насилие';

  @override
  String get policyDisallowDrugs => 'Запретить наркотики';

  @override
  String get policyDisallowHate => 'Запретить ненависть';

  @override
  String get policyDisallowSexualContent => 'Запретить сексуальный контент';

  @override
  String get policyDisallowReligiousPolitical => 'Запретить религиозный/политический';

  @override
  String get policyParentConfirmationForOlder => 'Подтверждение родителя для старших';

  @override
  String get policyDisallowScary => 'Запретить страшный контент';

  @override
  String get policyAllowPersonalNames => 'Разрешить личные имена';

  @override
  String get policyCustomBannedWords => 'Пользовательские запрещенные слова (запятые/новая строка)';

  @override
  String get policyPromptConstraints => 'Ограничения подсказки';

  @override
  String get policyMaxTokensHint => 'Подсказка макс токенов';

  @override
  String get policyMaxCharsHint => 'Подсказка макс символов';

  @override
  String get policyReadingLevel => 'Уровень чтения (simple|normal)';

  @override
  String get policyEnforceStructure => 'Принудить структуру';

  @override
  String get policyImageRules => 'Правила изображений';

  @override
  String get policyAllowImages => 'Разрешить изображения';

  @override
  String get policyAllowedImageStyles => 'Разрешенные стили изображений (запятые/новая строка)';

  @override
  String get policyVersionStamp => 'Версия';
}
