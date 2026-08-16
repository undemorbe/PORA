import 'package:pora/core/features/brief/data/models/brief_product_model.dart';
import 'package:pora/core/features/brief/domain/entity/brief_product_list.dart';
import 'package:pora/core/internal/network/api_client/api_client.dart';

abstract class BriefRemote {
  Future<void> setBriefData({required BriefProductListEntity products});
  Future<BriefProductListEntity> getBriefData();
}

class BriefRemoteImpl implements BriefRemote {
  final ApiClient apiClient;

  BriefRemoteImpl({required this.apiClient});

  @override
  Future<BriefProductListEntity> getBriefData() async {
    // await + explicit unwrap — иначе типовые ошибки прячутся Future-flattening'ом.
    final response = await apiClient.getUserBrief();
    return response;
  }

  @override
  Future<void> setBriefData({required BriefProductListEntity products}) async {
    final items = products.products
        .map((e) => BriefProductModel.fromEntity(e).toJson())
        .toList();
    await apiClient.setUserBrief(productsList: {'brief-items': items});
  }
}
