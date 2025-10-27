import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CareGuidePage extends ConsumerStatefulWidget {
  const CareGuidePage({super.key});

  @override
  ConsumerState<CareGuidePage> createState() => _CareGuidePageState();
}

class _CareGuidePageState extends ConsumerState<CareGuidePage> {
  final List<CareGuideCategory> _categories = [
    CareGuideCategory(
      title: 'General Plant Care',
      icon: Icons.eco,
      color: Colors.green,
      guides: [
        CareGuide(
          title: 'Watering Guidelines',
          description: 'Learn the proper way to water different types of plants',
          content: [
            'Check soil moisture before watering',
            'Water deeply but infrequently',
            'Use room temperature water',
            'Avoid overwatering to prevent root rot',
            'Water in the morning for best results',
          ],
        ),
        CareGuide(
          title: 'Light Requirements',
          description: 'Understanding light needs for healthy plant growth',
          content: [
            'Identify your plant\'s light preferences',
            'Rotate plants regularly for even growth',
            'Use grow lights for low-light areas',
            'Monitor for signs of too much or too little light',
            'Adjust placement based on seasonal changes',
          ],
        ),
        CareGuide(
          title: 'Soil and Fertilization',
          description: 'Proper soil management and feeding schedules',
          content: [
            'Use well-draining soil mixtures',
            'Fertilize during growing season only',
            'Follow package instructions for fertilizer amounts',
            'Repot when roots outgrow container',
            'Test soil pH for optimal nutrient uptake',
          ],
        ),
      ],
    ),
    CareGuideCategory(
      title: 'Disease Prevention',
      icon: Icons.health_and_safety,
      color: Colors.blue,
      guides: [
        CareGuide(
          title: 'Common Plant Diseases',
          description: 'Recognize and prevent common plant diseases',
          content: [
            'Powdery mildew: White powdery coating on leaves',
            'Root rot: Yellowing leaves and mushy roots',
            'Leaf spot: Brown or black spots on foliage',
            'Blight: Rapid wilting and browning',
            'Rust: Orange or brown pustules on leaves',
          ],
        ),
        CareGuide(
          title: 'Prevention Strategies',
          description: 'Keep your plants healthy and disease-free',
          content: [
            'Maintain proper air circulation',
            'Avoid overhead watering',
            'Remove dead or diseased plant material',
            'Use disease-resistant plant varieties',
            'Practice crop rotation in gardens',
          ],
        ),
      ],
    ),
    CareGuideCategory(
      title: 'Pest Management',
      icon: Icons.bug_report,
      color: Colors.orange,
      guides: [
        CareGuide(
          title: 'Common Plant Pests',
          description: 'Identify and control common plant pests',
          content: [
            'Aphids: Small green or black insects on new growth',
            'Spider mites: Tiny red or brown mites with webbing',
            'Mealybugs: White cottony masses on stems and leaves',
            'Scale insects: Brown or white bumps on plant surfaces',
            'Whiteflies: Small white insects that fly when disturbed',
          ],
        ),
        CareGuide(
          title: 'Natural Pest Control',
          description: 'Eco-friendly methods to manage plant pests',
          content: [
            'Introduce beneficial insects like ladybugs',
            'Use neem oil spray for organic control',
            'Remove pests manually with cotton swabs',
            'Apply insecticidal soap for soft-bodied pests',
            'Maintain plant health to resist pest damage',
          ],
        ),
      ],
    ),
    CareGuideCategory(
      title: 'Seasonal Care',
      icon: Icons.calendar_today,
      color: Colors.purple,
      guides: [
        CareGuide(
          title: 'Spring Care',
          description: 'Essential tasks for spring plant care',
          content: [
            'Repot plants that have outgrown containers',
            'Begin regular fertilization schedule',
            'Increase watering frequency as growth resumes',
            'Prune dead or damaged growth',
            'Start seeds for new plants',
          ],
        ),
        CareGuide(
          title: 'Winter Care',
          description: 'Protecting plants during winter months',
          content: [
            'Reduce watering frequency',
            'Move sensitive plants indoors',
            'Provide supplemental lighting if needed',
            'Maintain humidity levels',
            'Avoid fertilizing during dormancy',
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Care Guide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(CareGuideCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            category.icon,
            color: category.color,
            size: 24,
          ),
        ),
        title: Text(
          category.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: category.guides.map((guide) => _buildGuideItem(guide)).toList(),
      ),
    );
  }

  Widget _buildGuideItem(CareGuide guide) {
    return ListTile(
      title: Text(
        guide.title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        guide.description,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showGuideDetails(guide),
    );
  }

  void _showGuideDetails(CareGuide guide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                guide.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Description
              Text(
                guide.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Content
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: guide.content.length,
                  itemBuilder: (context, index) {
                    final item = guide.content[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Care Guide'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Search for care tips...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search functionality coming soon!'),
                ),
              );
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

class CareGuideCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<CareGuide> guides;

  CareGuideCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.guides,
  });
}

class CareGuide {
  final String title;
  final String description;
  final List<String> content;

  CareGuide({
    required this.title,
    required this.description,
    required this.content,
  });
}





