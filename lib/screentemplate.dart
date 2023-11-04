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
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
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
            padding: const EdgeInsets.only(
                top: 15.0, bottom: 15.0, left: 15.0, right: 7.0),
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
                      _changePage(index);
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  //scale: animation,
                  child: child,
                );
              },
              child: widget.pages[selectedIndex] ??
                  Center(child: Text("Sayfa bulunamadı!")),
            ),
          ),
        ],
      ),
    );
  }
}

class UITemplate extends StatefulWidget {
  final Widget page;
  const UITemplate({Key? key, required this.page}) : super(key: key);

  @override
  _UITemplateState createState() => _UITemplateState();
}

class _UITemplateState extends State<UITemplate> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 15.0, left: 10.0, right: 10.0, bottom: 15.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.83,
        height: MediaQuery.of(context).size.height * 0.9,
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
        ),
        child: widget.page,
      ),
    );
  }
}
