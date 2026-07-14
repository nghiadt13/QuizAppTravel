import '../../domain/entities/travel_reward.dart';
import '../../domain/repositories/i_reward_repository.dart';
import '../datasources/reward_remote_data_source.dart';
import '../dtos/travel_reward_dto.dart';
import '../mappers/travel_reward_mapper.dart';

class RewardRepositoryImpl implements IRewardRepository {
  final IRewardRemoteDataSource _remoteDataSource;
  final TravelRewardMapper _mapper;

  RewardRepositoryImpl(this._remoteDataSource, this._mapper);

  @override
  Future<TravelReward> getRandomReward() async {
    final dto = await _remoteDataSource.getRandomReward();
    return _mapper.map(dto);
  }

  @override
  Future<void> claimReward(String userId, TravelReward reward) async {
    final dto = TravelRewardDto(
      id: reward.id,
      type: reward.type.name,
      title: reward.title,
      description: reward.description,
      value: reward.value,
      iconUrl: reward.iconUrl,
    );
    await _remoteDataSource.claimReward(userId, dto);
  }

  @override
  Future<List<TravelReward>> getUserRewards(String userId) async {
    final list = await _remoteDataSource.getUserRewards(userId);
    return list.map((dto) => _mapper.map(dto)).toList();
  }
}
