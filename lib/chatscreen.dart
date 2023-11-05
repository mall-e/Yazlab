import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazlab/professor.dart';
import 'package:yazlab/sqloperations.dart';
import 'package:yazlab/student.dart';

class ChatScreen extends StatefulWidget {
  final int student_id;
  final int sender;

  const ChatScreen({Key? key, required this.student_id, required this.sender}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<ChatMessage> chatMessages; // Chat mesajlarını tutacak liste
  late Future<List<ChatMessage>>
      chatMessagesFuture; // Mesajları asenkron olarak çekecek Future

  @override
  void initState() {
    super.initState();
    // Burada fetchChatMessages fonksiyonunu çağırıyoruz ve sonucu bir Future'a atıyoruz.
    // Professor sınıfınızı ve kullanıcı kimliğini doğru şekilde sağladığınızdan emin olun.
    final professorId = Provider.of<Professor>(context, listen: false).id;
    final studentId = Provider.of<Student>(context, listen: false).studentId;
    chatMessagesFuture = widget.sender == 0
      ? fetchChatMessages(professorId, widget.student_id, true)
      : fetchChatMessages(professorId, widget.student_id, false);

  }

  @override
void dispose() {
  // ScrollController'ı temizle
  _scrollController.dispose();
  // Diğer dispose işlemleri
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    final professor = Provider.of<Professor>(context, listen: false);
    final student = Provider.of<Student>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Chat Ekranı'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ChatMessage>>(
              future: chatMessagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Hata: ${snapshot.error}"));
                } else if (snapshot.hasData) {
                  chatMessages = snapshot.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: chatMessages.length,
                    itemBuilder: (context, index) {
                      ChatMessage message = chatMessages[index];
                      return Align(
                        alignment: message.isSentByMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ChatBubble(
                          message: message.message,
                          isSentByMe: message.isSentByMe,
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text("Mesaj yok"));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 30.0),
                        hintText: 'Mesajınızı buraya yazın.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.width * 0.07,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.0),
                      color: Colors.green,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        DateTime dateTime = DateTime.now();
                        if(widget.sender == 0){

                          _sendMessage(professor.id, widget.student_id,
                              _messageController.text, dateTime);
                        }
                        else{
                          _sendMessage(widget.student_id, student.studentId,
                              _messageController.text, dateTime);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(int pid, int sid, String message, DateTime dt) async {
    var conn = connect();
    final messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      setState(() {
        // Mesajı listeye ekle
        chatMessages.add(
          ChatMessage(
            message: messageText,
            isSentByMe: true,
          ),
        );
        // ScrollController ile listenin sonuna kaydır
        Future.delayed(Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        });
      });
      // Mesajı veritabanına yaz
      // Mesaj giriş alanını temizle
      _messageController.clear();
    }

    try {
      await conn.open();

      // SQL komutu
      String sql = '''
      INSERT INTO chat (professor_id, student_id, message, datetime)
      VALUES (@pid, @sid, @message, @dt);
    ''';

      // SQL komutunu ve parametreleri veritabanına gönder
      await conn.query(sql, substitutionValues: {
        'pid': pid,
        'sid': sid,
        'message': message,
        'dt': dt.toIso8601String(),
      });

      print('Mesaj başarıyla gönderildi.');
    } catch (e) {
      // Hata oluşursa ekrana yazdır
      print('Bir hata oluştu: $e');
    } finally {
      // Her durumda veritabanı bağlantısını kapat
      await conn.close();
    }
  }
}

class ChatMessage {
  final String message;
  final bool isSentByMe;

  ChatMessage({required this.message, required this.isSentByMe});
}

Future<List<ChatMessage>> fetchChatMessages(
    int currentUserId, int otherUserId, bool isProfessor) async {
  var conn = connect();

  List<ChatMessage> chatMessages = [];

  try {
    // Veritabanına bağlan
    await conn.open();

    // SQL sorgusu: Tüm mesajları seç
    String sql = '''
      SELECT message, professor_id, student_id FROM chat
      WHERE (professor_id = @currentUserId AND student_id = @otherUserId)
      OR (professor_id = @otherUserId AND student_id = @currentUserId)
      ORDER BY datetime ASC;
    ''';

    // SQL sorgusunu çalıştır
    List<List<dynamic>> results = await conn.query(sql, substitutionValues: {
      'currentUserId': currentUserId,
      'otherUserId': otherUserId
    });

    // Sorgu sonuçlarından mesajları listeye ekle
    for (final row in results) {
      bool isSentByMe =
          isProfessor ? (row[1] == currentUserId) : (row[2] == currentUserId);
      chatMessages.add(ChatMessage(message: row[0], isSentByMe: isSentByMe));
    }
  } catch (e) {
    // Hata oluşursa ekrana yazdır
    print('Bir hata oluştu: $e');
  } finally {
    // Her durumda veritabanı bağlantısını kapat
    await conn.close();
  }

  return chatMessages;
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isSentByMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomLeft: isSentByMe ? Radius.circular(12) : Radius.circular(0),
      bottomRight: isSentByMe ? Radius.circular(0) : Radius.circular(12),
    );

    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: isSentByMe ? Colors.blue[200] : Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isSentByMe ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }
}
