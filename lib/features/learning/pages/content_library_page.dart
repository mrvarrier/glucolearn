import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class ContentLibraryPage extends StatefulWidget {
  const ContentLibraryPage({super.key});

  @override
  State<ContentLibraryPage> createState() => _ContentLibraryPageState();
}

class _ContentLibraryPageState extends State<ContentLibraryPage> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Understanding Diabetes',
    'Blood Sugar Management',
    'Nutrition & Diet',
    'Exercise & Activity',
    'Medication Management',
    'Complications Prevention',
    'Mental Health & Coping',
  ];

  final List<Map<String, dynamic>> _mockContent = [
    {
      'id': '1',
      'title': 'What is Type 2 Diabetes?',
      'description': 'Learn the basics of Type 2 diabetes and how it affects your body.',
      'category': 'Understanding Diabetes',
      'type': 'video',
      'duration': 15,
      'difficulty': 'Beginner',
      'thumbnail': 'assets/images/diabetes_basics.jpg',
    },
    {
      'id': '2',
      'title': 'Blood Sugar Monitoring',
      'description': 'How to properly monitor your blood glucose levels.',
      'category': 'Blood Sugar Management',
      'type': 'video',
      'duration': 20,
      'difficulty': 'Beginner',
      'thumbnail': 'assets/images/blood_sugar.jpg',
    },
    {
      'id': '3',
      'title': 'Healthy Meal Planning',
      'description': 'Create balanced meals that help manage blood sugar.',
      'category': 'Nutrition & Diet',
      'type': 'slides',
      'duration': 25,
      'difficulty': 'Intermediate',
      'thumbnail': 'assets/images/meal_planning.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.contentLibrary),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context, 
                delegate: ContentSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSM),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.spaceSM),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: AppColors.backgroundSecondary,
                    selectedColor: AppColors.primary.withValues(alpha: 0.1),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          
          // Content List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemCount: _mockContent.length,
              itemBuilder: (context, index) {
                final content = _mockContent[index];
                return _buildContentCard(context, content);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, Map<String, dynamic> content) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
      child: InkWell(
        onTap: () {
          context.pushNamed('content-detail', pathParameters: {
            'id': content['id'].toString(),
          });
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Icon(
                  _getContentIcon(content['type']),
                  color: AppColors.primary,
                  size: AppDimensions.iconLG,
                ),
              ),
              
              const SizedBox(width: AppDimensions.spaceMD),
              
              // Content Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content['title'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spaceSM),
                    Text(
                      content['description'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spaceSM),
                    Row(
                      children: [
                        _buildChip(
                          context,
                          '${content['duration']} min',
                          Icons.timer_outlined,
                        ),
                        const SizedBox(width: AppDimensions.spaceSM),
                        _buildChip(
                          context,
                          content['difficulty'],
                          Icons.psychology_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Play/Start Button
              IconButton(
                onPressed: () {
                  if (content['type'] == 'video') {
                    context.pushNamed('video-player', pathParameters: {
                      'id': content['id'].toString(),
                    });
                  } else {
                    context.pushNamed('content-detail', pathParameters: {
                      'id': content['id'].toString(),
                    });
                  }
                },
                icon: Icon(
                  content['type'] == 'video' 
                      ? Icons.play_circle_filled
                      : Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: AppDimensions.iconLG,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSM,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getContentIcon(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_outline;
      case 'slides':
        return Icons.slideshow_outlined;
      case 'quiz':
        return Icons.quiz_outlined;
      case 'document':
        return Icons.description_outlined;
      default:
        return Icons.article_outlined;
    }
  }
}

class ContentSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter a search term'),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Search results for "$query"',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Search functionality coming soon!',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = ['Diabetes Types', 'Blood Sugar', 'Nutrition', 'Exercise', 'Medication'];
    
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestion),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }
}