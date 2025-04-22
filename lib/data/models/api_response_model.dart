class ApiResponse<T> {
  final String? msg;
  final int? code;
  final T? data;

  ApiResponse({
    this.msg,
    this.code,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return ApiResponse(
      msg: json['msg'] as String?,
      code: json['code'] as int?,
      data: json['data'] != null ? fromJsonT(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'msg': msg,
      'code': code,
      'data': data != null ? toJsonT(data as T) : null,
    };
  }

  bool get isSuccess => code == 0;
}
