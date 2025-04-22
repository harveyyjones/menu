class PaginationResponse<T> {
  final int currentPage;
  final int perPage;
  final int totalItemsCount;
  final int lastPage;
  final int? nextPage;
  final List<T> data;

  PaginationResponse({
    required this.currentPage,
    required this.perPage,
    required this.totalItemsCount,
    required this.lastPage,
    this.nextPage,
    required this.data,
  });

  factory PaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginationResponse<T>(
      currentPage: int.parse(json['currentPage'] as String),
      perPage: int.parse(json['perPage'] as String),
      totalItemsCount: int.parse(json['totalItemsCount'] as String),
      lastPage: int.parse(json['lastPage'] as String),
      nextPage: json['nextPage'] != null
          ? int.parse(json['nextPage'] as String)
          : null,
      data: (json['data'] as List)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
