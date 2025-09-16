import 'app_config.dart';
import 'main_common.dart';

void main() {
  final config = AppConfig(
    appName: "Food2Go Dev",
    flavor: "development",
    baseUrl: "https://dev.api.food2go.com",
  );
  mainCommon(config);
}
