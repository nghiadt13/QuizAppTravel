import '../../../../core/mappers/mapper.dart';
import '../../domain/entities/travel_reward.dart';
import '../dtos/travel_reward_dto.dart';

class TravelRewardMapper implements IMapper<TravelRewardDto, TravelReward> {
  @override
  TravelReward map(TravelRewardDto source) {
    RewardType rewardType;
    switch (source.type) {
      case 'voucher':
        rewardType = RewardType.voucher;
        break;
      case 'badge':
        rewardType = RewardType.badge;
        break;
      case 'travelCoins':
      default:
        rewardType = RewardType.travelCoins;
        break;
    }

    return TravelReward(
      id: source.id,
      type: rewardType,
      title: source.title,
      description: source.description,
      value: source.value,
      iconUrl: source.iconUrl,
    );
  }
}
