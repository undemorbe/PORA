import 'package:equatable/equatable.dart';
import 'package:pora/core/features/brief/domain/entity/brief_product.dart';

class BriefProductListEntity extends Equatable {
  final List<BriefProductEntity> products;

  const BriefProductListEntity({required this.products});

  @override
  List<Object?> get props => [products];
}
