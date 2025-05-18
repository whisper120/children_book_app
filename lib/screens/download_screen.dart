import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';

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
  List<String> filePaths = [];
  List<bool> isDownloading = [];
  List<double> progress = [];
  bool fetchAttempted = false;

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
        fetchAttempted = true;
        isDownloaded = List.generate(books.length, (_) => false);
        filePaths = List.generate(books.length, (_) => '');
        isDownloading = List.generate(books.length, (_) => false);
        progress = List.generate(books.length, (_) => 0.0);
      });
    } catch (e) {
      setState(() {
        fetchAttempted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load books: $e')),
      );
    }
  }

  Future<void> downloadBook(int index, String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = url.split('/').last;
    final filePath = '${dir.path}/$fileName';

    setState(() {
      isDownloading[index] = true;
      progress[index] = 0.0;
    });

    try {
      await Dio().download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress[index] = received / total;
            });
          }
        },
      );

      setState(() {
        isDownloaded[index] = true;
        filePaths[index] = filePath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded ${books[index]['title']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      setState(() {
        isDownloading[index] = false;
      });
    }
  }

  void openBook(int index) {
    if (filePaths[index].isNotEmpty && File(filePaths[index]).existsSync()) {
      OpenFilex.open(filePaths[index]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not found, please download again')),
      );
      setState(() {
        isDownloaded[index] = false;
      });
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
      body: !fetchAttempted
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text('No books found'))
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
                                  child: Center(
                                  child: FaIcon(
                                    widget.fileType == 'pdf' ? FontAwesomeIcons.filePdf : FontAwesomeIcons.fileWord,
                                    color: Colors.white,
                                    size: 20,
                                  ),
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
                                    if (!isDownloaded[index] && !isDownloading[index]) {
                                      downloadBook(index, book['url'] ?? '');
                                    } else if (isDownloaded[index]) {
                                      openBook(index);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: isDownloading[index]
                                        ? SizedBox(
                                            width: 36,
                                            height: 36,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  value: progress[index],
                                                  strokeWidth: 3,
                                                  color: Colors.blue,
                                                ),
                                                Text(
                                                  '${(progress[index] * 100).toStringAsFixed(0)}%',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Text(
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
                  ],
                ),
    );
  }
}
