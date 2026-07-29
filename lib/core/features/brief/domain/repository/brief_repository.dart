import 'package:pora/core/features/brief/domain/entity/brief_product_list.dart';

abstract class BriefRepository {
  Future<void> setBriefData({required BriefProductListEntity products});
  Future<BriefProductListEntity> getBriefData();
}
