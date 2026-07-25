import 'package:pora/app/features/brief/domain/entity/brief_product_list.dart';
import 'package:pora/app/features/brief/domain/repository/brief_repository.dart';

class GetBriefUseCase {
  final BriefRepository briefRepository;

  const GetBriefUseCase({required this.briefRepository});
  Future<BriefProductListEntity> call() async {
    return await briefRepository.getBriefData();
  }
}
