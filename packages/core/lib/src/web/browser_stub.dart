void watchStorage(String key, void Function() callback) {}
void protectUnsavedChanges(bool dirty) {}
void updatePageMetadata({
  required String title,
  required String description,
  String canonical = '',
  String image = '',
  bool noIndex = false,
}) {}
void downloadFile(String url, String filename) {}
