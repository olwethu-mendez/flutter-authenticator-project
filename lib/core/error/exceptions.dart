class ServerException implements Exception{
  final String? message;
  ServerException([this.message]);
}
class CacheException implements Exception{}
class InvalidRequestException implements Exception{
  final String? message;
  InvalidRequestException([this.message]);}
class InvalidCredentialsExceptions implements Exception{
  final String? message;
  InvalidCredentialsExceptions([this.message]);
}
class TimeoutException implements Exception{
  final String? message;
  TimeoutException([this.message]);
}