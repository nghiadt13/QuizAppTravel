import '../../../../core/mappers/mapper.dart';
import '../../domain/entities/host_user.dart';
import '../dtos/host_user_dto.dart';

class HostUserMapper implements IMapper<HostUserDto, HostUser> {
  @override
  HostUser map(HostUserDto source) {
    return HostUser(
      uid: source.uid,
      displayName: source.displayName,
      email: source.email,
      avatarUrl: source.avatarUrl,
      createdAt: source.createdAt,
    );
  }
}
