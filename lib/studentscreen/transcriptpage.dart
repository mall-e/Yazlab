import 'package:flutter/material.dart';
import 'package:yazlab/transciprtrow.dart';

class TranscriptPage extends StatelessWidget {

  List<TranscriptRow> transcriptList;

  TranscriptPage(this.transcriptList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transcript'),
      ),
      body: ListView.builder(
        itemCount: transcriptList.length,
        itemBuilder: (context, index) {
          return TranscriptItem(data: transcriptList[index]);
        },
      ),
    );
  }
}

class TranscriptItem extends StatelessWidget {
  final TranscriptRow data;

  TranscriptItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 2, child: Text(data.kod, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text(data.isim, style: TextStyle(fontSize: 16))),
                Expanded(child: Text(data.status)),
                Expanded(child: Text(data.dil)),
                Expanded(child: Text('${data.t}')),
                Expanded(child: Text('${data.u}')),
                Expanded(child: Text('${data.uk}')),
                Expanded(child: Text('${data.akts}')),
                Expanded(child: Text(data.not)),
                Expanded(child: Text('${data.puan}')),
                Expanded(flex: 2, child: Text(data.aciklama)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
