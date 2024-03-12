import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'anlyze_page.dart';
import 'history_page.dart';
import 'login_page.dart';

enum Page { ANALYZE, HISTORY }

//메인 페이지 카메라, 갤러리 선택
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Page page = Page.ANALYZE;

  Widget body = AnalyzePage();
  String apiUrl = "http://3.34.55.153";
  final storage = FlutterSecureStorage();
  String? token;
  int? userId;
  List<dynamic> historyList = [];
  String? id;

  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storage.delete(key: 'token');
    storage.delete(key: 'userId');
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LoginPage(true, prefs)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var futureID = storage.read(key: 'id');
    futureID.then((value) {
      setState(() {
        id = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //imagepicker로 사진 가져오는 작업
    //web에서 동작시 오류발생 추후 수정

    String titleText = "분석하기";
    switch (page) {
      case Page.ANALYZE:
        body = AnalyzePage();
        titleText = "분석하기";
        break;
      case Page.HISTORY:
        body = HistoryBody();
        titleText = "히스토리";
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
        ),
        backgroundColor: Colors.blue[300],
        elevation: 0.3,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue[200]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$id"),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text("분석하기"),
                    leading: Icon(CupertinoIcons.camera_fill),
                    minLeadingWidth: 10,
                    trailing: Icon(CupertinoIcons.right_chevron,
                        color: Colors.black12),
                    onTap: () {
                      setState(() {
                        page = Page.ANALYZE;
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ListTile(
                    title: Text("히스토리"),
                    leading: Icon(CupertinoIcons.timer),
                    minLeadingWidth: 10,
                    trailing: Icon(CupertinoIcons.right_chevron,
                        color: const Color.fromARGB(31, 241, 219, 219)),
                    onTap: () {
                      setState(() {
                        page = Page.HISTORY;
                      });
                    },
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextButton(
                onPressed: () {
                  //로그아웃
                  print("로그아웃");
                  logOut();
                },
                child: Text(
                  "로그아웃",
                  style: TextStyle(
                    color: Colors.blue[200],
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            )
          ],
        ),
      ),
      body: body,
    );
  }
}
