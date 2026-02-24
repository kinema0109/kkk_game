// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Deception: Manager Game';

  @override
  String get roleForensicScientist => 'Forensic Scientist';

  @override
  String get roleMurderer => 'Murderer';

  @override
  String get roleInvestigator => 'Investigator';

  @override
  String get roleWitness => 'Witness';

  @override
  String get roleAccomplice => 'Accomplice';

  @override
  String get statusLobby => 'Lobby';

  @override
  String get statusSetup => 'Setup';

  @override
  String get statusCardDrafting => 'Card Drafting';

  @override
  String get statusCrimeSelection => 'Crime Selection';

  @override
  String get statusForensicSetup => 'Forensic Setup';

  @override
  String get statusInvestigation => 'Investigation';

  @override
  String get statusWitnessIdentification => 'Witness Identification';

  @override
  String get statusGameOver => 'Game Over';

  @override
  String get unitRoster => 'UNIT ROSTER';

  @override
  String get abandonMission => 'ABANDON MISSION';

  @override
  String get dossier => 'DOSSIER';

  @override
  String get action => 'ACTION';

  @override
  String get dossiers => 'DOSSIERS';

  @override
  String get solve => 'PHÁ ÁN';

  @override
  String get phaseRound => 'PHASE ROUND';

  @override
  String get sceneAnalysis => 'SCENE ANALYSIS';

  @override
  String get hienTruong => 'HIỆN TRƯỜNG';

  @override
  String get hoSoPhapY => 'HỒ SƠ PHÁP Y';

  @override
  String get means => 'MEANS';

  @override
  String get clues => 'CLUES';

  @override
  String get potentialMeans => 'SÁT KHÍ (MEANS)';

  @override
  String get keyClues => 'VẬT CHỨNG (CLUES)';

  @override
  String get solveAction => 'SOLVE!';

  @override
  String get examiningScene =>
      'THE FORENSIC SCIENTIST IS EXAMINING THE SCENE...';

  @override
  String get you => 'YOU';

  @override
  String get suspectDossiers => 'SUSPECT DOSSIERS';

  @override
  String get yourIdentity => 'YOUR IDENTITY';

  @override
  String equippedWith(Object clues, Object means) {
    return 'EQUIPPED WITH $means MEANS & $clues CLUES';
  }

  @override
  String get confirmCrime => 'CONFIRM EVIDENCE';

  @override
  String get waitingForForensic => 'WAITING FOR FORENSIC SCIENTIST...';

  @override
  String get confirmTiles => 'CONFIRM SCENE';

  @override
  String get murdererCards => 'MURDERER\'S EVIDENCE';

  @override
  String get waitingForSuspectsSelection => 'WAITING FOR SUSPECTS...';
}
