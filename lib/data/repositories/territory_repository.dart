import '../models/indicator.dart';
import '../services/synthetic_data_service.dart';
import '../services/weather_service.dart';

enum DataSourceStatus { live, cache, synthetic }

class TerritoryData {
  const TerritoryData(this.indicators, this.climateSource);
  final List<Indicator> indicators;
  final DataSourceStatus climateSource;
}

/// Combina dados sintéticos (API simulada) com clima real e define o fallback offline.
class TerritoryRepository {
  TerritoryRepository(this._weather, this._synthetic);

  final WeatherService _weather;
  final SyntheticDataService _synthetic;

  Future<TerritoryData> load() async {
    final base = await _synthetic.fetchIndicators();
    List<Indicator> climate;
    DataSourceStatus source;
    try {
      final result = await _weather.fetch();
      climate = result.indicators;
      source = result.fromCache ? DataSourceStatus.cache : DataSourceStatus.live;
    } catch (_) {
      climate = _synthetic.climateFallback();
      source = DataSourceStatus.synthetic;
    }
    return TerritoryData([...base, ...climate], source);
  }
}
