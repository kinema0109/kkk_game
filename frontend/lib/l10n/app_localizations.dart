import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Deception: Manager Game'**
  String get appTitle;

  /// No description provided for @roleForensicScientist.
  ///
  /// In en, this message translates to:
  /// **'Forensic Scientist'**
  String get roleForensicScientist;

  /// No description provided for @roleMurderer.
  ///
  /// In en, this message translates to:
  /// **'Murderer'**
  String get roleMurderer;

  /// No description provided for @roleInvestigator.
  ///
  /// In en, this message translates to:
  /// **'Investigator'**
  String get roleInvestigator;

  /// No description provided for @roleWitness.
  ///
  /// In en, this message translates to:
  /// **'Witness'**
  String get roleWitness;

  /// No description provided for @roleAccomplice.
  ///
  /// In en, this message translates to:
  /// **'Accomplice'**
  String get roleAccomplice;

  /// No description provided for @statusLobby.
  ///
  /// In en, this message translates to:
  /// **'Lobby'**
  String get statusLobby;

  /// No description provided for @statusSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get statusSetup;

  /// No description provided for @statusCardDrafting.
  ///
  /// In en, this message translates to:
  /// **'Card Drafting'**
  String get statusCardDrafting;

  /// No description provided for @statusCrimeSelection.
  ///
  /// In en, this message translates to:
  /// **'Crime Selection'**
  String get statusCrimeSelection;

  /// No description provided for @statusForensicSetup.
  ///
  /// In en, this message translates to:
  /// **'Forensic Setup'**
  String get statusForensicSetup;

  /// No description provided for @statusInvestigation.
  ///
  /// In en, this message translates to:
  /// **'Investigation'**
  String get statusInvestigation;

  /// No description provided for @statusWitnessIdentification.
  ///
  /// In en, this message translates to:
  /// **'Witness Identification'**
  String get statusWitnessIdentification;

  /// No description provided for @statusGameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get statusGameOver;

  /// No description provided for @unitRoster.
  ///
  /// In en, this message translates to:
  /// **'UNIT ROSTER'**
  String get unitRoster;

  /// No description provided for @abandonMission.
  ///
  /// In en, this message translates to:
  /// **'ABANDON MISSION'**
  String get abandonMission;

  /// No description provided for @dossier.
  ///
  /// In en, this message translates to:
  /// **'DOSSIER'**
  String get dossier;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'ACTION'**
  String get action;

  /// No description provided for @dossiers.
  ///
  /// In en, this message translates to:
  /// **'DOSSIERS'**
  String get dossiers;

  /// No description provided for @solve.
  ///
  /// In en, this message translates to:
  /// **'PHÁ ÁN'**
  String get solve;

  /// No description provided for @phaseRound.
  ///
  /// In en, this message translates to:
  /// **'PHASE ROUND'**
  String get phaseRound;

  /// No description provided for @sceneAnalysis.
  ///
  /// In en, this message translates to:
  /// **'SCENE ANALYSIS'**
  String get sceneAnalysis;

  /// No description provided for @hienTruong.
  ///
  /// In en, this message translates to:
  /// **'HIỆN TRƯỜNG'**
  String get hienTruong;

  /// No description provided for @hoSoPhapY.
  ///
  /// In en, this message translates to:
  /// **'HỒ SƠ PHÁP Y'**
  String get hoSoPhapY;

  /// No description provided for @means.
  ///
  /// In en, this message translates to:
  /// **'MEANS'**
  String get means;

  /// No description provided for @clues.
  ///
  /// In en, this message translates to:
  /// **'CLUES'**
  String get clues;

  /// No description provided for @potentialMeans.
  ///
  /// In en, this message translates to:
  /// **'SÁT KHÍ (MEANS)'**
  String get potentialMeans;

  /// No description provided for @keyClues.
  ///
  /// In en, this message translates to:
  /// **'VẬT CHỨNG (CLUES)'**
  String get keyClues;

  /// No description provided for @solveAction.
  ///
  /// In en, this message translates to:
  /// **'SOLVE!'**
  String get solveAction;

  /// No description provided for @examiningScene.
  ///
  /// In en, this message translates to:
  /// **'THE FORENSIC SCIENTIST IS EXAMINING THE SCENE...'**
  String get examiningScene;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get you;

  /// No description provided for @suspectDossiers.
  ///
  /// In en, this message translates to:
  /// **'SUSPECT DOSSIERS'**
  String get suspectDossiers;

  /// No description provided for @yourIdentity.
  ///
  /// In en, this message translates to:
  /// **'YOUR IDENTITY'**
  String get yourIdentity;

  /// No description provided for @equippedWith.
  ///
  /// In en, this message translates to:
  /// **'EQUIPPED WITH {means} MEANS & {clues} CLUES'**
  String equippedWith(Object clues, Object means);

  /// No description provided for @confirmCrime.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM EVIDENCE'**
  String get confirmCrime;

  /// No description provided for @waitingForForensic.
  ///
  /// In en, this message translates to:
  /// **'WAITING FOR FORENSIC SCIENTIST...'**
  String get waitingForForensic;

  /// No description provided for @confirmTiles.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM SCENE'**
  String get confirmTiles;

  /// No description provided for @murdererCards.
  ///
  /// In en, this message translates to:
  /// **'MURDERER\'S EVIDENCE'**
  String get murdererCards;

  /// No description provided for @waitingForSuspectsSelection.
  ///
  /// In en, this message translates to:
  /// **'WAITING FOR SUSPECTS...'**
  String get waitingForSuspectsSelection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
