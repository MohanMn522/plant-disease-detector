import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/prediction_provider.dart';
import '../models/prediction_result.dart';

/// HistoryPage:
/// - If you create it inside a parent that owns the TabController,
///   pass `onGoToDetection: () => tabController.animateTo(0)`.
/// - Otherwise it will try DefaultTabController.of(context).animateTo(0),
///   and if that fails it will navigate to '/detection' as a fallback.
class HistoryPage extends ConsumerStatefulWidget {
  final VoidCallback? onGoToDetection;

  const HistoryPage({super.key, this.onGoToDetection});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // Load history when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(predictionControllerProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final predictionState = ref.watch(predictionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction History'),
        actions: [
          if (predictionState.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearHistoryDialog(context),
            ),
        ],
      ),
      body: predictionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : predictionState.history.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(predictionState.history),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No predictions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by analyzing a plant image',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleGoToDetection,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Analyze Plant'),
          ),
        ],
      ),
    );
  }

  void _handleGoToDetection() {
    // 1) If parent provided a callback, use it.
    if (widget.onGoToDetection != null) {
      widget.onGoToDetection!();
      return;
    }

    // 2) Otherwise try to animate the DefaultTabController if present.
    try {
      final controller = DefaultTabController.of(context);
      controller.animateTo(0);
      return;
    } catch (_) {
      // intentionally fall through to fallback navigation
    }

    // 3) Fallback: navigate to a detection route (replace with your route name)
    //    or push the detection screen directly.
    Navigator.of(context).pushReplacementNamed('/detection');
  }

  Widget _buildHistoryList(List<PredictionResult> history) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(predictionControllerProvider.notifier).loadHistory();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final prediction = history[index];
          return _buildHistoryItem(prediction);
        },
      ),
    );
  }

  Widget _buildHistoryItem(PredictionResult prediction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewPredictionDetails(prediction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Plant/Disease Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: prediction.isHealthy
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  prediction.isHealthy ? Icons.eco : Icons.warning,
                  color: prediction.isHealthy
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Prediction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.plantName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prediction.isHealthy ? 'Healthy Plant' : prediction.diseaseName,
                      style: TextStyle(
                        fontSize: 14,
                        color: prediction.isHealthy
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • HH:mm').format(prediction.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Confidence Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(prediction.confidence).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  prediction.confidencePercentage,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getConfidenceColor(prediction.confidence),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _viewPredictionDetails(PredictionResult prediction) {
    // Navigate to results page with historical data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoricalResultsPage(prediction: prediction),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all prediction history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(predictionControllerProvider.notifier).clearHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History cleared'),
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Historical Results Page
class HistoricalResultsPage extends StatelessWidget {
  final PredictionResult prediction;

  const HistoricalResultsPage({
    super.key,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historical Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Historical Info Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Historical Prediction',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Analyzed on ${DateFormat('MMM dd, yyyy at HH:mm').format(prediction.timestamp)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildDiseaseInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: prediction.isHealthy ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: prediction.isHealthy ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                prediction.isHealthy ? Icons.check_circle : Icons.warning,
                color: prediction.isHealthy ? Colors.green : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.plantName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      prediction.isHealthy ? 'Healthy Plant' : prediction.diseaseName,
                      style: TextStyle(
                        fontSize: 16,
                        color: prediction.isHealthy ? Colors.green.shade700 : Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (prediction.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              prediction.description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
