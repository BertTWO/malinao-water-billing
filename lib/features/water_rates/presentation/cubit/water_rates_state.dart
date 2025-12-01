part of 'water_rates_cubit.dart';

abstract class WaterRatesState extends Equatable {
  const WaterRatesState();

  @override
  List<Object?> get props => [];
}

class WaterRatesInitial extends WaterRatesState {}

class WaterRatesLoading extends WaterRatesState {}

class WaterRatesLoaded extends WaterRatesState {
  final WaterRateEntity? rate;
  const WaterRatesLoaded(this.rate);
  @override
  List<Object?> get props => [];
}

class WaterRatesHistoryLoaded extends WaterRatesState {
  final List<WaterRateEntity> rates;
  const WaterRatesHistoryLoaded(this.rates);
  @override
  List<Object?> get props => [rates];
}

class WaterRatesError extends WaterRatesState {
  final String message;
  const WaterRatesError(this.message);
  @override
  List<Object?> get props => [message];
}
