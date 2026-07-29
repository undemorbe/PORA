import 'package:pora/core/features/brief/domain/entity/brief_product_list.dart';
import 'package:pora/core/features/brief/domain/repository/brief_repository.dart';

class PostBriefUseCase {
  final BriefRepository briefRepository;

  PostBriefUseCase({required this.briefRepository});

  Future<void> call({required BriefProductListEntity products}) async {
    await briefRepository.setBriefData(products: products);
  }
}
