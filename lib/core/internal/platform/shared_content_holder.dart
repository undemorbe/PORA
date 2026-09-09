class SharedContentHolder {
  SharedContentHolder._();
  static final SharedContentHolder instance = SharedContentHolder._();

  String? _pendingRecipeUrl;

  bool get hasPending => _pendingRecipeUrl != null;

  void setRecipeUrl(String url) => _pendingRecipeUrl = url.trim();

  String? consume() {
    final v = _pendingRecipeUrl;
    _pendingRecipeUrl = null;
    return v;
  }
}
