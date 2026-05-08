import 'package:geolinked/services/api_service.dart';

class DataFlowService {
  DataFlowService._();

  static ApiResult<T> loadLocal<T>({
    required T? Function() reader,
    required String emptyMessage,
  }) {
    try {
      final T? value = reader();
      if (value == null) {
        return ApiResult<T>.failure(emptyMessage);
      }
      return ApiResult<T>.success(value);
    } catch (_) {
      return ApiResult<T>.failure('Could not read local data.');
    }
  }

  static Future<ApiResult<void>> saveLocal({
    required Future<void> Function() writer,
  }) async {
    try {
      await writer();
      return ApiResult<void>.success(null);
    } catch (_) {
      return ApiResult<void>.failure('Could not save local data.');
    }
  }

  static Future<ApiResult<T>> loadApi<T>({
    required Future<ApiResult<dynamic>> Function() request,
    required T Function(dynamic payload) parser,
  }) async {
    try {
      final ApiResult<dynamic> result = await request();
      if (!result.success) {
        return ApiResult<T>.failure(
          result.errorMessage ?? 'Request failed.',
          statusCode: result.statusCode,
        );
      }

      final T parsed = parser(result.data);
      return ApiResult<T>.success(parsed, statusCode: result.statusCode);
    } catch (_) {
      return ApiResult<T>.failure('Could not parse server data.');
    }
  }
}
