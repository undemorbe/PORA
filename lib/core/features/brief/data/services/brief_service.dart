import 'package:pora/core/features/brief/data/datasource/brief_remote.dart';
import 'package:pora/core/features/brief/domain/entity/brief_product_list.dart';
import 'package:pora/core/features/brief/domain/repository/brief_repository.dart';
import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/network/single_flight.dart';

class BriefService implements BriefRepository {
  final BriefRemote briefRemote;

  BriefService({required this.briefRemote});

  /// AI-карточки (suggestions, tip of day, chat) читают brief одновременно
  /// при открытии экрана — склеиваем в один запрос.
  final _getFlight = SingleFlight<BriefProductListEntity?>();

  //! Impl failure, success
  @override
  Future<BriefProductListEntity?> getBriefData() => _getFlight.run(_fetch);

  Future<BriefProductListEntity?> _fetch() async {
    try {
      return await briefRemote.getBriefData();
    } catch (e) {
      // TODO: handle error
      Logger.talker.error(e.toString());
      return BriefProductListEntity(products: []);
    }
  }

  @override
  Future<void> setBriefData({required BriefProductListEntity products}) async {
    await briefRemote.setBriefData(products: products);
  }
}
