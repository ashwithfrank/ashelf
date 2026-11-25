class LibItem {
  LibItem({
    required this.isFolder,
    required this.name,
    required this.path,
    this.ext = '',
    this.type = 'other',
    this.size = 0,
    this.url = '',
    this.dlUrl = '',
    String? title,
    this.category = '',
    this.year,
    this.modified,
  }) : title = (title == null || title.isEmpty) ? name : title;

  final bool isFolder;
  final String name;
  final String path;
  final String ext;
  final String type;
  final int size;
  final String url;
  final String dlUrl;
  final String title;
  final String category;
  final String? year;
  final String? modified;

  String get parent =>
      path.contains('/') ? path.substring(0, path.lastIndexOf('/')) : '';

  factory LibItem.fromJson(Map<String, dynamic> j) => LibItem(
        isFolder: j['kind'] == 'folder',
        name: j['name'] as String,
        path: j['path'] as String,
        ext: (j['ext'] ?? '') as String,
        type: (j['type'] ?? 'other') as String,
        size: ((j['size'] ?? 0) as num).toInt(),
        url: (j['url'] ?? '') as String,
        dlUrl: (j['dlUrl'] ?? '') as String,
        title: j['title'] as String?,
        category: (j['category'] ?? '') as String,
        year: j['year'] as String?,
        modified: j['modified'] as String?,
      );
}
