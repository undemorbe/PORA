import 'package:equatable/equatable.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/prediction.dart';

class PredictionListEntity extends Equatable {
  final List<PredictionEntity> predictions;

  const PredictionListEntity({required this.predictions});

  @override
  List<Object> get props => [predictions];
}
