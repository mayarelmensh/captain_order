import 'app_config.dart';
import 'main_common.dart';

void main() {
  final config = AppConfig(
    appName: "Food2Go Dev",
    flavor: "development",
    baseUrl: "https://bcknd.food2go.online",
  );
  mainCommon(config);
}
