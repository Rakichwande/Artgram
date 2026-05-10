/// Central place for all API configuration.
/// Change baseUrl when moving from local → production.
/// 
/// HOW TO USE:
///   1. Run the FastAPI server (bash run.sh)
///   2. It will print your local IP (e.g. 192.168.1.45)
///   3. Replace the IP below with yours
///   4. Hot-restart Flutter
class ApiConfig {
  // ── Change this to your laptop's local IP ──────────────────────────────────
  // Run: hostname -I | awk '{print $1}'  in your terminal to get it
  static const String _localIp = '192.168.137.107';   // ← CHANGE THIS

  // ── Base URL — switch between environments here ───────────────────────────
  static const String baseUrl = 'http://$_localIp:8000';

  // ── Endpoints ─────────────────────────────────────────────────────────────
  static const String uploadEndpoint  = '$baseUrl/upload';
  static const String imagesEndpoint  = '$baseUrl/images';
  static const String healthEndpoint  = '$baseUrl/health';

  // ── Helper: build full image URL from filename ───────────────────────────
  static String imageUrl(String filename) => '$imagesEndpoint/$filename';

  // ── Helper: check if a URL is from our FastAPI server ────────────────────
  static bool isFastApiUrl(String url) => url.startsWith(baseUrl);
}
