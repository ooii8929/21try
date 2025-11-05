import 'package:flutter/material.dart';

class TryRecordDetailScreen extends StatefulWidget {
  final int tryRecordId;

  const TryRecordDetailScreen({Key? key, required this.tryRecordId})
      : super(key: key);

  @override
  State<TryRecordDetailScreen> createState() => _TryRecordDetailScreenState();
}

class _TryRecordDetailScreenState extends State<TryRecordDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Detail')),
      body: const Center(child: Text('Record Detail Screen - Placeholder')),
    );
  }
}
