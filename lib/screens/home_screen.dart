import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/download_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, String>> ageGroups = [
    {'label': 'Ages 0-4', 'image': 'assets/ages_0_4.png'},
    {'label': 'Ages 4-8', 'image': 'assets/ages_4_8.png'},
    {'label': 'Ages 9-12', 'image': 'assets/ages_8_12.png'},
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF5FF), // light pink background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose your child’s age:",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Word Column
                    Expanded(
                      child: Column(
                        children: [
                          FaIcon(FontAwesomeIcons.fileWord, size: 40, color: Colors.blue),
                          SizedBox(height: 8),
                          ...ageGroups.map((group) => Expanded(
                                child: AgeButton(
                                  label: group['label']!,
                                  imagePath: group['image']!,
                                  isPdf: false,
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    // PDF Column
                    Expanded(
                      child: Column(
                        children: [
                          FaIcon(FontAwesomeIcons.filePdf, size: 40, color: Colors.red),
                          SizedBox(height: 8),
                          ...ageGroups.map((group) => Expanded(
                                child: AgeButton(
                                  label: group['label']!,
                                  imagePath: group['image']!,
                                  isPdf: true,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AgeButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final bool isPdf;

  const AgeButton({super.key, 
    required this.label,
    required this.imagePath,
    required this.isPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DownloadScreen(
                ageLabel: label,
                fileType: isPdf ? 'pdf' : 'word',
              ),
            ),
          );
        },
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
