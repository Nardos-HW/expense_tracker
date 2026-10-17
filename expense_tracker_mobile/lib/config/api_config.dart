class ApiConfig {
  /// Base URL for the Laravel backend API.
  ///
  /// NOTE FOR DEVELOPMENT:
  /// - When testing locally in the browser on the same machine (e.g. via `flutter run -d web-server --web-port 5000`),
  ///   `http://127.0.0.1:8000/api` works as expected.
  /// - If the web-server app is opened from another device on the same local network (e.g. mobile phone browser),
  ///   this MUST be changed to your computer's LAN IP address (e.g. `http://192.168.1.X:8000/api`),
  ///   and the Laravel dev server must be started listening on all interfaces:
  ///   `php artisan serve --host=0.0.0.0 --port=8000`
  static const String baseUrl = 'http://127.0.0.1:8000/api';
}
