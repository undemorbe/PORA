import 'package:pora/app/features/brief/data/models/brief_product_model.dart';
import 'package:pora/app/features/brief/data/models/brief_product_model_list.dart';
import 'package:pora/app/features/brief/domain/entity/brief_product_list.dart';
import 'package:pora/app/internal/network/api_client/api_client.dart';

abstract class BriefRemote {
  Future<void> setBriefData({required BriefProductListEntity products});
  Future<BriefProductListEntity> getBriefData();
}

class BriefRemoteImpl implements BriefRemote {
  final ApiClient apiClient;

  BriefRemoteImpl({required this.apiClient});

  @override
  Future<BriefProductListEntity> getBriefData() async {
    final response = apiClient.getUserBrief();
    return response;
  }

  @override
  Future<void> setBriefData({required BriefProductListEntity products}) async {
    await apiClient.setUserBrief(
      productsList: {'brief-items': products.products},
    );
  }
}
