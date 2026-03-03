import 'package:signalr_netcore/iretry_policy.dart';

class ExponentialRetryPolicy extends IRetryPolicy {
  @override
  int? nextRetryDelayInMilliseconds(RetryContext retryContext) {
    // Retry after 2s, 5s, 10s, then every 30s thereafter
    switch (retryContext.previousRetryCount) {
      case 0: return 2000;
      case 1: return 5000;
      case 2: return 10000;
      default: return 30000; 
    }
  }
}