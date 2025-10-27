class PredictionResult {
  final String id;
  final String imageUrl;
  final String plantName;
  final String diseaseName;
  final double confidence;
  final String description;
  final List<String> symptoms;
  final List<String> treatments;
  final List<String> preventionTips;
  final DateTime timestamp;
  final bool isHealthy;
  final bool isMockData;

  PredictionResult({
    required this.id,
    required this.imageUrl,
    required this.plantName,
    required this.diseaseName,
    required this.confidence,
    required this.description,
    required this.symptoms,
    required this.treatments,
    required this.preventionTips,
    required this.timestamp,
    required this.isHealthy,
    this.isMockData = false,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      plantName: json['plantName'] ?? 'Unknown Plant',
      diseaseName: json['diseaseName'] ?? 'Unknown Disease',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      treatments: List<String>.from(json['treatments'] ?? []),
      preventionTips: List<String>.from(json['preventionTips'] ?? []),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isHealthy: json['isHealthy'] ?? false,
      isMockData: json['isMockData'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'plantName': plantName,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'description': description,
      'symptoms': symptoms,
      'treatments': treatments,
      'preventionTips': preventionTips,
      'timestamp': timestamp.toIso8601String(),
      'isHealthy': isHealthy,
      'isMockData': isMockData,
    };
  }

  // Helper method to get confidence percentage
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  // Helper method to get severity level
  String get severityLevel {
    if (isHealthy) return 'Healthy';
    if (confidence < 0.3) return 'Low';
    if (confidence < 0.7) return 'Medium';
    return 'High';
  }

  // Helper method to get severity color
  String get severityColor {
    if (isHealthy) return 'green';
    if (confidence < 0.3) return 'yellow';
    if (confidence < 0.7) return 'orange';
    return 'red';
  }
}





