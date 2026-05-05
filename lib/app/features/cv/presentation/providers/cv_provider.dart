import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:swift_apply/app/features/cv/data/models/cv_file_model.dart';
import 'package:swift_apply/app/features/cv/data/repositories/cv_repository.dart';

@injectable
class CvProvider extends ChangeNotifier {
  CvProvider(this._repository);

  final CvRepository _repository;

  bool _loading = false;
  List<CvFile> _items = const [];

  bool get loading => _loading;
  List<CvFile> get items => _items;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = await _repository.getAllCvs();
    _loading = false;
    notifyListeners();
  }

  Future<bool> pickAndAddCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    final file = result?.files.single;
    final path = file?.path;
    if (file == null || path == null) return false;

    await _repository.addCv(
      CvFile(
        name: file.name,
        path: path,
        addedAt: DateTime.now(),
        isDefault: _items.isEmpty,
      ),
    );
    await load();
    return true;
  }

  Future<void> rename(CvFile cv, String name) async {
    final id = cv.id;
    if (id == null) return;
    await _repository.renameCv(id, name);
    await load();
  }

  Future<void> setDefault(CvFile cv) async {
    final id = cv.id;
    if (id == null) return;
    await _repository.setDefault(id);
    await load();
  }

  Future<void> delete(CvFile cv) async {
    final id = cv.id;
    if (id == null) return;
    await _repository.deleteCv(id);
    await load();
  }
}
