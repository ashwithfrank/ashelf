class Config {
  /// Raw URL of manifest.json in the ashelf-library repo.
  static const manifestUrl =
      'https://raw.githubusercontent.com/ashwithfrank/ashelf-library/main/manifest.json';

  /// Virtual root used by the manifest paths.
  static const rootPath = 'library';

  /// Folder the Library tab opens on. Change it if you add more courses.
  static const startPath = 'library/BCA';
}
