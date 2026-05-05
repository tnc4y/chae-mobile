import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../models/chapter.dart';
import '../models/chapter_page.dart';
import '../models/downloaded_chapter.dart';

class DownloadService {
  static final instance = DownloadService._();
  DownloadService._();

  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 30)));

  Future<String> _baseDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/chae_downloads');
    await dir.create(recursive: true);
    return dir.path;
  }

  Future<bool> isDownloaded(String chapterId) async {
    final base = await _baseDir();
    return File('$base/$chapterId.cbz').exists();
  }

  Future<List<DownloadedChapter>> getDownloads() async {
    final base = await _baseDir();
    final dir = Directory(base);
    if (!await dir.exists()) return [];

    final results = <DownloadedChapter>[];
    for (final entity in dir.listSync()) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final raw = await entity.readAsString();
          results.add(DownloadedChapter.fromJson(
              jsonDecode(raw) as Map<String, dynamic>));
        } catch (_) {}
      }
    }
    results.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return results;
  }

  Future<void> downloadChapter({
    required Chapter chapter,
    required List<ChapterPage> pages,
    void Function(int current, int total)? onProgress,
  }) async {
    final base = await _baseDir();
    final tempDir = Directory('$base/tmp_${chapter.id}');
    await tempDir.create(recursive: true);

    try {
      for (var i = 0; i < pages.length; i++) {
        final filename = '${(i + 1).toString().padLeft(4, '0')}.jpg';
        await _dio.download(pages[i].imageUrl, '${tempDir.path}/$filename');
        onProgress?.call(i + 1, pages.length);
      }

      final encoder = ZipFileEncoder();
      final cbzPath = '$base/${chapter.id}.cbz';
      encoder.create(cbzPath);
      for (var i = 0; i < pages.length; i++) {
        final filename = '${(i + 1).toString().padLeft(4, '0')}.jpg';
        encoder.addFile(File('${tempDir.path}/$filename'));
      }
      encoder.close();

      final meta = DownloadedChapter(
        chapterId: chapter.id,
        webtoonId: chapter.webtoonId,
        chapterNumber: chapter.chapterNumber,
        title: chapter.title,
        pageCount: pages.length,
        downloadedAt: DateTime.now(),
        cbzPath: cbzPath,
      );
      await File('$base/${chapter.id}.json')
          .writeAsString(jsonEncode(meta.toJson()));
    } finally {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    }
  }

  Future<List<ChapterPage>> loadLocalPages(String chapterId) async {
    final base = await _baseDir();
    final cbzFile = File('$base/$chapterId.cbz');
    if (!await cbzFile.exists()) throw Exception('Bölüm indirilmemiş');

    final tempDir = await getTemporaryDirectory();
    final extractDir = Directory('${tempDir.path}/cbz_$chapterId');
    await extractDir.create(recursive: true);

    final bytes = await cbzFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final fileEntries = archive.files
        .where((f) => f.isFile)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final result = <ChapterPage>[];
    for (var i = 0; i < fileEntries.length; i++) {
      final entry = fileEntries[i];
      final outFile = File('${extractDir.path}/${entry.name}');
      await outFile.writeAsBytes(entry.content as List<int>);
      result.add(ChapterPage(
        id: '$chapterId-$i',
        pageNumber: i + 1,
        imageUrl: outFile.path,
        width: 0,
        height: 0,
      ));
    }
    return result;
  }

  Future<void> deleteDownload(String chapterId) async {
    final base = await _baseDir();
    for (final ext in ['.cbz', '.json']) {
      final file = File('$base/$chapterId$ext');
      if (await file.exists()) await file.delete();
    }
  }
}
