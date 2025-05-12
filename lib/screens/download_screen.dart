import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadScreen extends StatefulWidget {
  final String ageLabel;
  final String fileType; // 'pdf' or 'word'

  const DownloadScreen({
    super.key,
    required this.ageLabel,
    required this.fileType,
  });

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  List<Map<String, dynamic>> books = [];
  List<bool> isDownloaded = [];

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Books')
          .where('agerange', isEqualTo: widget.ageLabel)
          .where('type', isEqualTo: widget.fileType)
          .get();

      final bookData = snapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        books = bookData;
        isDownloaded = List.generate(books.length, (_) => false);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load books: $e')),
      );
    }
  }

  void openBook(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the book URL')),
      );
    }
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
      body: books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: const LinearGradient(
                                  colors: [Colors.red, Colors.blue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.book, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                book['title'] ?? 'Untitled',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (!isDownloaded[index]) {
                                  setState(() {
                                    isDownloaded[index] = true;
                                  });
                                } else {
                                  openBook(book['url'] ?? '');
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isDownloaded[index] ? 'OPEN' : 'GET',
                                  style: const TextStyle(
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement file picker and Firebase upload
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text('Upload Book'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
