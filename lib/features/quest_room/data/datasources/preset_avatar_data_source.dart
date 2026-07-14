import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/preset_avatar_dto.dart';

abstract interface class IPresetAvatarDataSource {
  Future<List<PresetAvatarDto>> fetchPresetAvatars();
}

class PresetAvatarDataSourceImpl implements IPresetAvatarDataSource {
  final FirebaseFirestore _firestore;

  PresetAvatarDataSourceImpl(this._firestore);

  @override
  Future<List<PresetAvatarDto>> fetchPresetAvatars() async {
    try {
      final snapshot = await _firestore
          .collection('presetAvatars')
          .orderBy('order')
          .get();

      if (snapshot.docs.isEmpty) {
        // Fallback default presets if Firestore is empty
        return const [
          PresetAvatarDto(id: 'dog', label: 'Dog', imageUrl: 'assets/avatars/dog.png', order: 1),
          PresetAvatarDto(id: 'cat', label: 'Cat', imageUrl: 'assets/avatars/cat.png', order: 2),
          PresetAvatarDto(id: 'bird', label: 'Bird', imageUrl: 'assets/avatars/bird.png', order: 3),
          PresetAvatarDto(id: 'rabbit', label: 'Rabbit', imageUrl: 'assets/avatars/rabbit.png', order: 4),
          PresetAvatarDto(id: 'fox', label: 'Fox', imageUrl: 'assets/avatars/fox.png', order: 5),
          PresetAvatarDto(id: 'owl', label: 'Owl', imageUrl: 'assets/avatars/owl.png', order: 6),
        ];
      }

      return snapshot.docs
          .map((doc) => PresetAvatarDto.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch preset avatars.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
