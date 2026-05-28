import 'package:flutter/material.dart';
import 'package:body_anatomy_viewer/body_anatomy_viewer.dart';

void main() => runApp(const TestApp());

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Body Anatomy Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const TestPage(),
    );
  }
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Body Anatomy Viewer')),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _ExampleCard(
                title: 'Hourglass (Female)',
                subtitle:
                    'Waist 65cm · Chest 95cm · Hips 100cm · Height 168cm',
                metrics: BodyMetrics(
                  gender: Gender.female,
                  heightCm: 168,
                  weightKg: 60,
                  chestCm: 95,
                  waistCm: 65,
                  hipCm: 100,
                  collarCm: 38,
                  frontSleeveCm: 58,
                  inseamCm: 76,
                ),
                highlights: {
                  'abdominals': Color(0xFFE91E63),
                },
              ),
              SizedBox(height: 16),
              _ExampleCard(
                title: 'Muscular Male',
                subtitle:
                    'Chest 115cm · Waist 82cm · Broad shoulders · Heavy',
                metrics: BodyMetrics(
                  gender: Gender.male,
                  heightCm: 180,
                  weightKg: 88,
                  chestCm: 115,
                  waistCm: 82,
                  hipCm: 98,
                  collarCm: 50,
                  frontSleeveCm: 66,
                  inseamCm: 82,
                ),
                highlights: {
                  'pectoral_left': Color(0xFFF44336),
                  'pectoral_right': Color(0xFFF44336),
                  'deltoid_left': Color(0xFFFF9800),
                  'deltoid_right': Color(0xFFFF9800),
                  'abdominals': Color(0xFFE91E63),
                  'quadriceps_left': Color(0xFF2196F3),
                  'quadriceps_right': Color(0xFF2196F3),
                },
              ),
              SizedBox(height: 16),
              _ExampleCard(
                title: 'Slim / Lean',
                subtitle:
                    'Chest 85cm · Waist 70cm · Light build · Height 175cm',
                metrics: BodyMetrics(
                  gender: Gender.female,
                  heightCm: 175,
                  weightKg: 62,
                  chestCm: 85,
                  waistCm: 70,
                  hipCm: 85,
                  collarCm: 40,
                  frontSleeveCm: 62,
                  inseamCm: 80,
                ),
                highlights: {},
              ),
              SizedBox(height: 16),
              _ExampleCard(
                title: 'Overweight',
                subtitle:
                    'Chest 110cm · Waist 105cm · Hips 110cm · Height 172cm',
                metrics: BodyMetrics(
                  gender: Gender.male,
                  heightCm: 172,
                  weightKg: 95,
                  chestCm: 110,
                  waistCm: 105,
                  hipCm: 110,
                  collarCm: 44,
                  frontSleeveCm: 64,
                  inseamCm: 78,
                ),
                highlights: {
                  'abdominals': Color(0xFFE91E63),
                  'glute_left': Color(0xFF9C27B0),
                  'glute_right': Color(0xFF9C27B0),
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final BodyMetrics metrics;
  final Map<String, Color> highlights;

  const _ExampleCard({
    required this.title,
    required this.subtitle,
    required this.metrics,
    required this.highlights,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
            const SizedBox(height: 8),
            BodyAnatomyViewer(
              metrics: metrics,
              highlightedMuscles: highlights,
              viewHeight: 300,
            ),
          ],
        ),
      ),
    );
  }
}
