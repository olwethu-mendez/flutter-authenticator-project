class AppConfig {
static const String localIPAddress = "10.0.2.2:5233";
static const String apiBaseUrl = "http://$localIPAddress/api";
static const String notificationsHub = "$apiBaseUrl/notification-hub";
static const String usersHub = "$apiBaseUrl/user-hub";

// Networking
static const Duration connectTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 40);
}