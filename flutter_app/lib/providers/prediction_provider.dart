import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prediction_result.dart';
import '../services/api_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Prediction Controller Provider
final predictionControllerProvider = StateNotifierProvider<PredictionController, PredictionState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PredictionController(apiService);
});

// Prediction State
class PredictionState {
  final bool isLoading;
  final List<PredictionResult> history;
  final String? error;

  PredictionState({
    this.isLoading = false,
    this.history = const [],
    this.error,
  });

  PredictionState copyWith({
    bool? isLoading,
    List<PredictionResult>? history,
    String? error,
  }) {
    return PredictionState(
      isLoading: isLoading ?? this.isLoading,
      history: history ?? this.history,
      error: error,
    );
  }
}

// Prediction Controller
class PredictionController extends StateNotifier<PredictionState> {
  final ApiService _apiService;

  PredictionController(this._apiService) : super(PredictionState());

  // Analyze image for disease detection
  Future<PredictionResult> analyzeImage(File imageFile) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.uploadAndPredict(imageFile);
      
      // Add to history
      final updatedHistory = [result, ...state.history];
      state = state.copyWith(
        isLoading: false,
        history: updatedHistory,
      );
      
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Get prediction history
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final history = await _apiService.getPredictionHistory();
      state = state.copyWith(
        isLoading: false,
        history: history,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear history
  void clearHistory() {
    state = state.copyWith(history: []);
  }
}





