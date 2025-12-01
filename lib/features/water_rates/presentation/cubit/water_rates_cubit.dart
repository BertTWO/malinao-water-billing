import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:malinaowaterbilling/features/water_rates/domain/repository/water_rates_repo.dart';
import 'package:malinaowaterbilling/features/water_rates/domain/water_rates.dart';

part 'water_rates_state.dart';

class WaterRatesCubit extends Cubit<WaterRatesState> {
  final WaterRatesRepo _waterRatesRepo;

  WaterRatesCubit(this._waterRatesRepo) : super(WaterRatesInitial());

  void getCurrentRate() async {
    emit(WaterRatesLoading());
    try {
      final rate = await _waterRatesRepo.getCurrentRate();
      emit(WaterRatesLoaded(rate));
    } catch (e) {
      emit(WaterRatesError(e.toString()));
    }
  }

  void updateRate(double newRate) async {
    emit(WaterRatesLoading());
    try {
      await _waterRatesRepo.updateRate(newRate);
      final updatedRate = await _waterRatesRepo.getCurrentRate();
      emit(WaterRatesLoaded(updatedRate));
    } catch (e) {
      emit(WaterRatesError(e.toString()));
    }
  }

  void listenToRateHistory() {
    _waterRatesRepo.getRateHistory().listen((rates) {
      emit(WaterRatesHistoryLoaded(rates));
    });
  }
}
