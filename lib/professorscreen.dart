import 'package:flutter/material.dart';
import 'package:yazlab/screentemplate.dart';
import 'package:yazlab/sqloperations.dart';

class ProfessorScreen extends StatefulWidget {
  const ProfessorScreen({Key? key}) : super(key: key);

  @override
  _ProfessorScreenState createState() => _ProfessorScreenState();
}

class _ProfessorScreenState extends State<ProfessorScreen> {
  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      buttons: [
        Icon(
          Icons.home,
          color: Colors.white,
        ),
        Icon(
          Icons.search,
          color: Colors.white,
        ),
        Icon(
          Icons.settings,
          color: Colors.white,
        )
      ],
      pages: {
        0: InterestPage(),
        1: MyApp(),
        2: InterestPage(),
      },
    );
  }
}

class InterestPage extends StatelessWidget {
  const InterestPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    TextEditingController interestcontroller = TextEditingController();
    return UITemplate(
        page: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("İlgi alanınızı giriniz"),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: interestcontroller,
                  decoration: InputDecoration(),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  var connection = await connect();
                  try {
                    await connection.query(
                      'UPDATE hoca SET interests = @interest WHERE professor_id = @idValue',
                      substitutionValues: {
                        'interest': interestcontroller.text,
                        'idValue': 1,
                      },
                    );
                    print('Veri başarıyla eklendi');
                  } catch (e) {
                    print('Veri eklenirken hata oluştu: $e');
                  } finally {
                    await connection.close();
                  }
                },
                child: Text("Ekle"),
              )
            ],
          ),
        ),
      ],
    ));
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Öğrenci Talep Uygulaması',
      home: UITemplate(
        page: DefaultTabController(
          length: 2, // İki sekme olacak
          child: Scaffold(
            appBar: AppBar(
              title: Text('Öğrenci Talepleri'),
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Talepleri Görüntüle'),
                  Tab(text: 'Talep Gönder'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                StudentRequestList(),
                RequestFormPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudentRequestList extends StatefulWidget {
  List<String> studentRequests = ["zort", "zart"];

  @override
  _StudentRequestListState createState() => _StudentRequestListState();
}

class _StudentRequestListState extends State<StudentRequestList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.studentRequests.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(widget.studentRequests[index]),
        );
      },
    );
  }
}

class RequestFormPage extends StatefulWidget {
  @override
  _RequestFormPageState createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  final TextEditingController requestController = TextEditingController();

  void _submitRequest() {
    String requestText = requestController.text;
    if (requestText.isNotEmpty) {
      setState(() {
        StudentRequestList().studentRequests.add(requestText);
      });
      requestController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: requestController,
            decoration: InputDecoration(labelText: 'Talebinizi yazın'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitRequest,
            child: Text('Talep Gönder'),
          ),
        ],
      ),
    );
  }
}
