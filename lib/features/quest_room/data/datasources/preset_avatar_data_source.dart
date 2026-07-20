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
          PresetAvatarDto(
            id: 'dog',
            label: 'Cún con',
            imageUrl: 'assets/avatars/dog.png',
            order: 1,
          ),
          PresetAvatarDto(
            id: 'cat',
            label: 'Mèo nhỏ',
            imageUrl: 'assets/avatars/cat.png',
            order: 2,
          ),
          PresetAvatarDto(
            id: 'bird',
            label: 'Chim xanh',
            imageUrl: 'assets/avatars/bird.png',
            order: 3,
          ),
          PresetAvatarDto(
            id: 'rabbit',
            label: 'Thỏ bông',
            imageUrl: 'assets/avatars/rabbit.png',
            order: 4,
          ),
          PresetAvatarDto(
            id: 'fox',
            label: 'Cáo cam',
            imageUrl: 'assets/avatars/fox.png',
            order: 5,
          ),
          PresetAvatarDto(
            id: 'owl',
            label: 'Cú mèo',
            imageUrl: 'assets/avatars/owl.png',
            order: 6,
          ),
          PresetAvatarDto(
            id: 'panda',
            label: 'Gấu trúc',
            imageUrl: 'assets/avatars/panda.png',
            order: 7,
          ),
          PresetAvatarDto(
            id: 'bear',
            label: 'Gấu nâu',
            imageUrl: 'assets/avatars/bear.png',
            order: 8,
          ),
          PresetAvatarDto(
            id: 'koala',
            label: 'Koala',
            imageUrl: 'assets/avatars/koala.png',
            order: 9,
          ),
          PresetAvatarDto(
            id: 'penguin',
            label: 'Cánh cụt',
            imageUrl: 'assets/avatars/penguin.png',
            order: 10,
          ),
          PresetAvatarDto(
            id: 'monkey',
            label: 'Khỉ con',
            imageUrl: 'assets/avatars/monkey.png',
            order: 11,
          ),
          PresetAvatarDto(
            id: 'tiger',
            label: 'Hổ con',
            imageUrl: 'assets/avatars/tiger.png',
            order: 12,
          ),
        ];
      }

      return snapshot.docs
          .map((doc) => PresetAvatarDto.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw AppException(
        e.message ?? 'Failed to fetch preset avatars.',
        code: e.code,
      );
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
