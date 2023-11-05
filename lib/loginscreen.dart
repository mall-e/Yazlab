import 'package:flutter/material.dart';
import 'package:googleapis/connectors/v1.dart';
import 'package:yazlab/professor.dart';
import 'package:yazlab/professorscreen.dart';
import 'package:yazlab/sqloperations.dart';
import 'package:yazlab/studentscreen/studentscreen.dart';
import 'package:yazlab/yonetici.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 221, 255, 222),
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Gölgenin rengi
                spreadRadius: 1, // Gölgenin genişlemesi
                blurRadius: 10, // Gölgenin ne kadar bulanık olacağı
                offset: Offset(0, 5), // Gölgenin pozisyonu
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.black, // Kenar rengi
                    width: 0.5, // Kenar kalınlığı
                  ),
                ),
                child: Text(
                  "Yazlab",
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AnimatedButton(title: "Yönetici"),
                  AnimatedButton(title: "Hoca"),
                  AnimatedButton(title: "Öğrenci"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final String title;

  AnimatedButton({required this.title});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  double _width = 0.2;
  double _height = 0.1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showBottomSheet(context);
      },
      onTapDown: (details) {
        // Tıklanma anında küçültme
        setState(() {
          _width = 0.18;
          _height = 0.09;
        });
      },
      onTapUp: (details) {
        // Tıklanma bırakıldığında büyütme
        setState(() {
          _width = 0.2;
          _height = 0.1;
        });
      },
      onTapCancel: () {
        // Tıklama iptal edildiğinde büyütme
        setState(() {
          _width = 0.2;
          _height = 0.1;
        });
      },
      child: AnimatedContainer(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * _width,
        height: MediaQuery.of(context).size.height * _height,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 93, 179, 96),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          widget.title,
          style: TextStyle(fontSize: 17.0),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return CustomBottomSheet(title: widget.title);
        });
  }
}

class CustomBottomSheet extends StatefulWidget {
  final String title;

  CustomBottomSheet({required this.title});

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _isHidden = true;
  bool _loginCheck = true;

  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  Future<bool> login(String username, String password) async {
    bool isAuthenticated = false;
    List tables = ["yonetici", "hoca", "ogrenciler"];
    switch (widget.title) {
      case "Öğrenci":
        isAuthenticated = await checkCredentials(username, password, tables[2]);
        break;
      case "Hoca":
        isAuthenticated = await checkCredentials(username, password, tables[1]);
      case "Yönetici":
        isAuthenticated = await checkCredentials(username, password, tables[0]);
      default:
    }
    if (isAuthenticated) {
      print("Giriş Başarılı");
      return true;
    } else {
      print("Giriş Başarısız");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Center(
                  child: Text(
                "${widget.title} Hesabıyla Giriş Yapın",
                style: TextStyle(fontSize: 20.0),
              )),
            ),
            TextField(
              controller: username,
              decoration: InputDecoration(
                labelText: "Kullanıcı Adı",
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: password,
              obscureText: _isHidden,
              decoration: InputDecoration(
                labelText: "Şifre",
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: _toggleVisibility,
                  icon: _isHidden
                      ? Icon(Icons.visibility_off)
                      : Icon(Icons.visibility),
                ),
              ),
            ),
            !_loginCheck
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Girdiğiniz bilgilere ait kullanıcı bulunamadı!",
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : SizedBox(),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: ElevatedButton(
                onPressed: () async {
                  bool isloggedin = false;
                  isloggedin = await login(username.text, password.text);
                  if (isloggedin && widget.title == "Öğrenci") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StudentScreen(loginType: "ogrenci", username: username.text)));
                    setState(() {
                      _loginCheck = true;
                    });
                  }
                  if (isloggedin && widget.title == "Hoca") {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfessorScreen(loginType: "hoca", username: username.text)));
                    setState(() {
                      _loginCheck = true;
                    });
                  }
                  if (isloggedin && widget.title == "Yönetici") {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => YoneticiScreen()));
                    setState(() {
                      _loginCheck = true;
                    });
                  }
                  else {
                    setState(() {
                      _loginCheck = false;
                    });
                  }
                },
                child: Text("Giriş"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
