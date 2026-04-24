class PagedResult<T> {
  final List<T> data;

  /// Opaque cursor for the next page. `null` when there are no more results.
  final String? cursor;

  const PagedResult({required this.data, required this.cursor});
}
