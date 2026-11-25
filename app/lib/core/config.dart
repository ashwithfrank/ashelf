class Config {
  /// Raw URL of manifest.json in the ashelf-library repo.
  static const manifestUrl =
      'https://raw.githubusercontent.com/ashwithfrank/ashelf-library/main/manifest.json';

  /// Virtual root of the manifest. Its folders (BCA, BCOM, ...) are the courses.
  static const rootPath = 'library';

  /// Latest GitHub release of the app, used by the update checker.
  static const latestReleaseApi =
      'https://api.github.com/repos/ashwithfrank/ashelf/releases/latest';

  static const portfolioUrl = 'https://ashwithfrank.github.io/';
  static const appRepoUrl = 'https://github.com/ashwithfrank/ashelf';
  static const libraryRepoUrl = 'https://github.com/ashwithfrank/ashelf-library';
}
