class ModelUrls {
  // Zero-shot model URLs
  static const String clipImageEncoder =
      'https://huggingface.co/Spritan/CLIP_tlite/resolve/main/CLIPImageEncoder.tflite';
  static const String clipTextEncoder =
      'https://huggingface.co/Spritan/CLIP_tlite/resolve/main/CLIPTextEncoder.tflite';
  static const String tokenizedPrompts =
      'https://huggingface.co/Spritan/CLIP_tlite/resolve/main/tokenized_prompts.pb';

  // Classification model URLs
  static const String plantClassifier =
      'https://huggingface.co/NimurAI/plantdetectionmodel/resolve/main/model.pt';
  static const String plantLabels =
      'https://huggingface.co/NimurAI/plantdetectionmodel/resolve/main/labels.txt';
}

class ModelPaths {
  // Zero-shot model paths
  static const String clipImageEncoder = 'CLIPImageEncoder.tflite';
  static const String clipTextEncoder = 'CLIPTextEncoder.tflite';
  static const String tokenizedPrompts = 'tokenized_prompts.pb';

  // Classification model paths
  static const String plantClassifier = 'model.pt';
  static const String plantLabels = 'labels.txt';
}

class ModelConfigs {
  static List<Map<String, dynamic>> getZeroShotConfigs() => [
        {
          'name': 'CLIP Image Encoder',
          'url': ModelUrls.clipImageEncoder,
          'localPath': ModelPaths.clipImageEncoder,
          'type': 'zeroshot',
        },
        {
          'name': 'CLIP Text Encoder',
          'url': ModelUrls.clipTextEncoder,
          'localPath': ModelPaths.clipTextEncoder,
          'type': 'zeroshot',
        },
        {
          'name': 'Tokenized Prompts',
          'url': ModelUrls.tokenizedPrompts,
          'localPath': ModelPaths.tokenizedPrompts,
          'type': 'zeroshot',
        },
      ];

  static List<Map<String, dynamic>> getClassificationConfigs() => [
        {
          'name': 'Plant Classification Model',
          'url': ModelUrls.plantClassifier,
          'localPath': ModelPaths.plantClassifier,
          'type': 'classification',
        },
        {
          'name': 'Plant Labels',
          'url': ModelUrls.plantLabels,
          'localPath': ModelPaths.plantLabels,
          'type': 'classification',
        },
      ];
}
