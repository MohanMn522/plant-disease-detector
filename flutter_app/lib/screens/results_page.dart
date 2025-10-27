import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/prediction_result.dart';

class ResultsPage extends ConsumerWidget {
  final File image;
  final PredictionResult result;

  const ResultsPage({
    super.key,
    required this.image,
    required this.result,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareResults(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Main Result
            _buildImageSection(),
            
            const SizedBox(height: 24),
            
            // Disease Information
            _buildDiseaseInfo(),
            
            const SizedBox(height: 24),
            
            // Confidence and Severity
            _buildConfidenceSection(),
            
            const SizedBox(height: 24),
            
            // Symptoms
            if (result.symptoms.isNotEmpty) ...[
              _buildSection('Symptoms', result.symptoms),
              const SizedBox(height: 24),
            ],
            
            // Treatments
            if (result.treatments.isNotEmpty) ...[
              _buildSection('Recommended Treatments', result.treatments),
              const SizedBox(height: 24),
            ],
            
            // Prevention Tips
            if (result.preventionTips.isNotEmpty) ...[
              _buildSection('Prevention Tips', result.preventionTips),
              const SizedBox(height: 24),
            ],
            
            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          image,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 250,
        ),
      ),
    );
  }

  Widget _buildDiseaseInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: result.isHealthy ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isHealthy ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.isHealthy ? Icons.check_circle : Icons.warning,
                color: result.isHealthy ? Colors.green : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.plantName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      result.isHealthy ? 'Healthy Plant' : result.diseaseName,
                      style: TextStyle(
                        fontSize: 16,
                        color: result.isHealthy ? Colors.green.shade700 : Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (result.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              result.description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics,
            color: Colors.blue.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confidence Level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  result.confidencePercentage,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getSeverityColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.severityLevel,
              style: TextStyle(
                color: _getSeverityColor(),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _launchCareGuide(context),
            icon: const Icon(Icons.eco),
            label: const Text('View Care Guide'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _launchExpertConsultation(context),
            icon: const Icon(Icons.support_agent),
            label: const Text('Consult Expert'),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor() {
    switch (result.severityLevel) {
      case 'Healthy':
        return Colors.green;
      case 'Low':
        return Colors.yellow;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _shareResults(BuildContext context) {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing functionality will be implemented'),
      ),
    );
  }

  void _launchCareGuide(BuildContext context) {
    // Navigate to care guide or open external link
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening care guide...'),
      ),
    );
  }

  void _launchExpertConsultation(BuildContext context) async {
    // Launch expert consultation URL
    const url = 'https://example.com/expert-consultation';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open expert consultation'),
        ),
      );
    }
  }
}





