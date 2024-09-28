class POSError extends Error {
  final String message;

  POSError(this.message);

  @override
  toString() => message;
}
