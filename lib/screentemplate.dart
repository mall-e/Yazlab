import 'package:flutter/material.dart';

class ScreenTemplate extends StatefulWidget {
  final List<Icon> buttons;
  final Map<int, Widget> pages;

  const ScreenTemplate({
    Key? key,
    required this.buttons,
    required this.pages,
  }) : super(key: key);

  @override
  _ScreenTemplateState createState() => _ScreenTemplateState();
}

class _ScreenTemplateState extends State<ScreenTemplate> {
  late Widget page;

  @override
  void initState() {
    // Varsayılan olarak ilk sayfayı göster
    page = widget.pages[0] ?? Center(child: Text("Sayfa bulunamadı!"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 189, 189, 189),
      appBar: AppBar(
        // AppBar ayarlarınız...
      ),
      body: Row(
        children: [
          // Sol tarafta yer alan özel navbar
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 15.0, right: 7.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
              ),
              width: MediaQuery.of(context).size.width * 0.1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.buttons.length,
                  (index) => IconButton(
                    icon: widget.buttons[index],
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        page = widget.pages[index] ?? Center(child: Text("Sayfa bulunamadı!"));
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: page),
        ],
      ),
    );
  }
}
