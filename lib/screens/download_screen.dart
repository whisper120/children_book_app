import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DownloadScreen extends StatefulWidget {
  final String ageLabel;
  final String fileType; // 'pdf' or 'word'

  const DownloadScreen({required this.ageLabel, required this.fileType});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final List<String> books = ['Book 1', 'Book 2'];
  late List<bool> isDownloaded;

  @override
  void initState() {
    super.initState();
    isDownloaded = List.generate(books.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isPdf = widget.fileType == 'pdf';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ageLabel),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: FaIcon(
              isPdf ? FontAwesomeIcons.filePdf : FontAwesomeIcons.fileWord,
              color: isPdf ? Colors.red : Colors.white,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Book list
          Expanded(
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.blue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.ac_unit, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Title
                      Expanded(
                        child: Text(
                          books[index],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // GET / OPEN
                      GestureDetector(
                        onTap: () {
                          if (!isDownloaded[index]) {
                            setState(() {
                              isDownloaded[index] = true;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isDownloaded[index] ? 'OPEN' : 'GET',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Upload Book Button
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement file picker and Firebase upload
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('Upload Book'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
