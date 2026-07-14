import '../../../../core/mappers/mapper.dart';
import '../../domain/entities/preset_avatar.dart';
import '../dtos/preset_avatar_dto.dart';

class PresetAvatarMapper implements IMapper<PresetAvatarDto, PresetAvatar> {
  @override
  PresetAvatar map(PresetAvatarDto source) {
    return PresetAvatar(
      id: source.id,
      label: source.label,
      imageUrl: source.imageUrl,
      order: source.order,
    );
  }
}
