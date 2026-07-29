import 'package:pora/core/features/brief/data/datasource/brief_remote.dart';
import 'package:pora/core/features/brief/domain/entity/brief_product_list.dart';
import 'package:pora/core/features/brief/domain/repository/brief_repository.dart';

class BriefService implements BriefRepository {
  final BriefRemote briefRemote;

  const BriefService({required this.briefRemote});

  //! Impl failure, success
  @override
  Future<BriefProductListEntity> getBriefData() async {
    try {
      return await briefRemote.getBriefData();
    } catch (e) {
      // TODO: handle error
      rethrow;
    }
  }

  @override
  Future<void> setBriefData({required BriefProductListEntity products}) async {
    await briefRemote.setBriefData(products: products);
  }
}
