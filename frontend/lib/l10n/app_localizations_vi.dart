// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Hồ Sơ Pháp Y';

  @override
  String get roleForensicScientist => 'Pháp Y';

  @override
  String get roleMurderer => 'Hung Thủ';

  @override
  String get roleInvestigator => 'Điều Tra Viên';

  @override
  String get roleWitness => 'Nhân Chứng';

  @override
  String get roleAccomplice => 'Đồng Phạm';

  @override
  String get statusLobby => 'Phòng Chờ';

  @override
  String get statusSetup => 'Thiết Lập';

  @override
  String get statusCardDrafting => 'Rút Thẻ';

  @override
  String get statusCrimeSelection => 'Chọn Án';

  @override
  String get statusForensicSetup => 'Sắp Xếp Hiện Trường';

  @override
  String get statusInvestigation => 'Điều Tra';

  @override
  String get statusWitnessIdentification => 'Nhận Diện Nhân Chứng';

  @override
  String get statusGameOver => 'Kết Thúc';

  @override
  String get unitRoster => 'DANH SÁCH ĐƠN VỊ';

  @override
  String get abandonMission => 'RỜI KHỎI NHIỆM VỤ';

  @override
  String get dossier => 'HỒ SƠ';

  @override
  String get action => 'HÀNH ĐỘNG';

  @override
  String get dossiers => 'HỒ SƠ';

  @override
  String get solve => 'PHÁ ÁN';

  @override
  String get phaseRound => 'VÒNG HIỆN TẬP';

  @override
  String get sceneAnalysis => 'PHÂN TÍCH HIỆN TRƯỜNG';

  @override
  String get hienTruong => 'HIỆN TRƯỜNG';

  @override
  String get hoSoPhapY => 'HỒ SƠ PHÁP Y';

  @override
  String get means => 'SÁT KHÍ';

  @override
  String get clues => 'VẬT CHỨNG';

  @override
  String get potentialMeans => 'SÁT KHÍ (MEANS)';

  @override
  String get keyClues => 'VẬT CHỨNG (CLUES)';

  @override
  String get solveAction => 'PHÁ ÁN!';

  @override
  String get examiningScene =>
      'NHÂN VIÊN PHÁP Y ĐANG KHÁM NGHIỆM HIỆN TRƯỜNG...';

  @override
  String get you => 'BẠN';

  @override
  String get suspectDossiers => 'SƠ YẾU LÝ LỊCH NGHI PHẠM';

  @override
  String get yourIdentity => 'DANH TÍNH CỦA BẠN';

  @override
  String equippedWith(Object clues, Object means) {
    return 'SỞ HỮU $means SÁT KHÍ & $clues VẬT CHỨNG';
  }

  @override
  String get confirmCrime => 'XÁC NHẬN BẰNG CHỨNG';

  @override
  String get waitingForForensic => 'CHỜ PHÁP Y THIẾT LẬP HIỆN TRƯỜNG...';

  @override
  String get confirmTiles => 'XÁC NHẬN HIỆN TRƯỜNG';

  @override
  String get murdererCards => 'BẰNG CHỨNG CỦA HUNG THỦ';

  @override
  String get waitingForSuspectsSelection => 'ĐANG CHỜ CÁC NGHI PHẠM...';
}
