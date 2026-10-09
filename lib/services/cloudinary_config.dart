class CloudinaryConfig {
  static const cloudName = 'wdsr1l5v';
  static const uploadPreset = 'ceylona_uploads';

  static bool get isConfigured =>
      cloudName.isNotEmpty && uploadPreset.isNotEmpty;
}