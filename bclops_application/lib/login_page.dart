import 'package:bclops_application/home_page.dart';
import 'package:bclops_application/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  bool isOnboarded;
  SharedPreferences prefs;
  LoginPage(this.isOnboarded, this.prefs, {super.key});

  @override
  Widget build(BuildContext context) {
    final double displayheight = MediaQuery.sizeOf(context).height;
    final double displaywidth = MediaQuery.sizeOf(context).width;
    print(displayheight);
    final idController = TextEditingController();
    final passController = TextEditingController();
    final storage = FlutterSecureStorage();
    String id = '';
    String password = '';
    var dio = Dio();
    return Scaffold(
      //scrollview 추가
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: kIsWeb ? displayheight * 0.1 : displayheight * 0.2,
            ),
            kIsWeb
                ? Container(
                    margin: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/images/aiclops_logo.png',
                      width: displaywidth * 0.3,
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/images/aiclops_logo.png',
                      width: displaywidth * 0.5,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
              child: TextField(
                controller: idController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "아이디",
                  //아이콘 추가하였습니다.
                  prefixIcon: Icon(CupertinoIcons.person),
                  contentPadding: EdgeInsets.all(3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
              child: TextField(
                obscureText: true,
                controller: passController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "비밀번호",
                  //아이콘 추가하였습니다.
                  prefixIcon: Icon(CupertinoIcons.lock),
                  contentPadding: EdgeInsets.all(3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff59FFC3),
                    fixedSize: Size(displaywidth * 0.5, displayheight * 0.05)),
                onPressed: () async {
                  var id = idController.text;
                  var password = passController.text;
                  print('id: $id');
                  print('password: $password');
                  var data = {'userId': id, 'password': password};

                  Response res = await dio
                      .post('http://3.34.55.153/web/auth/sign-in', data: data);

                  String userId = res.data['result']['id'].toString();
                  String token = res.data['result']['jwt'];
                  print("token : $token");

                  // await storage.write(key: 'id', value: userId);
                  await storage.write(key: 'token', value: token);
                  await storage.write(key: 'userId', value: userId);
                  await storage.write(key: 'id', value: id);

                  var secureStorage = await storage.read(key: 'token');
                  print(secureStorage);
                  // 서버 연결해서 확인 후 메인 페이지 이동 예정
                  // 회원 정보 일치할 시 온보딩 확인 후 메인 페이지로 이동
                  if (isOnboarded) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  } else {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => OnBoarding()));
                  }
                },
                child: Text(
                  '로그인',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffD7FFF0),
                      fixedSize:
                          Size(displaywidth * 0.5, displayheight * 0.05)),
                  onPressed: () {
                    // 서버 연결해서 확인 후 메인 페이지 이동 예정
                    //push로 변경하였습니다
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignupPage()));
                  },
                  child: Text(
                    '회원가입',
                    style: TextStyle(color: Colors.black),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    void FlutterDialog() {
      showDialog(
          context: context,
          //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "회원정보를 입력해주세요",
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("확인"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }

    double displayheight = MediaQuery.sizeOf(context).height;
    double displaywidth = MediaQuery.sizeOf(context).width;

    final idController = TextEditingController();
    final passController = TextEditingController();
    final passCheckController = TextEditingController();
    final nameController = TextEditingController();
    return Scaffold(
      //signup화면엔 appbar 추가하였습니다.
      appBar: AppBar(
        title: Text("회원가입"),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.blueAccent,
            size: 30,
          ),
        ),
        backgroundColor: Color.fromARGB(230, 244, 244, 244),
        elevation: 0.3,
      ),
      //scrollview 추가
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: displayheight * 0.1,
          ),
          Container(
            width: displaywidth * 0.2,
            margin: const EdgeInsets.all(20.0),
            child: Image.asset('assets/images/aiclops_logo.png'),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
          //   child: TextField(
          //     controller: nameController,
          //     decoration: InputDecoration(
          //       border: OutlineInputBorder(),
          //       label: Text('이름을 입력해주세요'),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: TextField(
              controller: idController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('아이디를 입력해주세요'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: TextField(
              controller: passController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('비밀번호를 입력해주세요'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: TextField(
              controller: passCheckController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('비밀번호를 다시 입력해주세요'),
              ),
            ),
          ),
          //Row 씌우고 취소 버튼 추가해야할듯 합니다.
          Column(
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff59FFC3),
                      fixedSize:
                          Size(displaywidth * 0.5, displayheight * 0.05)),
                  onPressed: () async {
                    print(idController.text);
                    print(passController.text);
                    print(passCheckController.text);

                    // 서버 연결
                    var userId = idController.text;
                    var password = passCheckController.text;
                    var data = {'userId': userId, 'password': password};
                    Response res = await Dio()
                        .post('http://3.34.55.153/web/User', data: data);

                    if (idController.text != '' &&
                        passController != '' &&
                        passCheckController != '') {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginPage(false, prefs)));
                    } else {
                      FlutterDialog();
                    }
                  },
                  child: Text(
                    '회원가입',
                    style: TextStyle(color: Colors.black),
                  )),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff59FFC3),
                      fixedSize:
                          Size(displaywidth * 0.5, displayheight * 0.05)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '취소',
                    style: TextStyle(color: Colors.black),
                  )),
            ],
          )
        ]),
      ),
    );
  }
}

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      margin: EdgeInsets.fromLTRB(0, 100, 30, 0),
      child: IntroductionScreen(
        pages: [
          // 첫 번째 페이지
          PageViewModel(
            image: Image.asset(
              'assets/images/stereonet.png',
              width: 400,
            ),
            title: "STEREONET",
            body:
                "평사투영망은 지표 지질조사시 측정된 3차원적인 형태의 \n 지질구조요소, 즉 면구조(층리, 엽리, 단층, 절리 등)와 \n 선 구조(습곡축, 단층, 경면, 광물배열방향)를 \n 알기 쉽게 2차원적으로 표현하기 위하여 고안된 방법입니다",
            decoration: PageDecoration(
              titleTextStyle: TextStyle(
                color: Colors.blueAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          // 두 번째 페이지
          PageViewModel(
            title: "STEP 1",
            body: "먼저 절리 사진을 선택하거나 \n 직접 절리 사진을 촬영합니다.",
            image: Image.asset(
              'assets/images/STEP 1.png',
              width: 400,
              fit: BoxFit.contain,
            ),
            decoration: PageDecoration(
              titleTextStyle: TextStyle(
                color: Colors.blueAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          PageViewModel(
            title: "STEP 2",
            body: "사진을 선택한 후 \n 사진과 카메라 사이의 거리를 입력합니다.",
            image: Image.asset(
              'assets/images/STEP 2.png',
              width: 400,
              fit: BoxFit.contain,
            ),
            decoration: PageDecoration(
              titleTextStyle: TextStyle(
                color: Colors.blueAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          PageViewModel(
            title: "STEP 3",
            body:
                "최종적으로 이미지 분석 결과를 확인합니다. \n\n 분석 결과로는 \n 분류된 절리군, 절리군 stereonet, \n 수치화된 절리군 정보를 나타낸 표가 나타납니다.",
            image: Image.asset(
              'assets/images/STEP 3.png',
              width: 400,
              fit: BoxFit.contain,
            ),
            decoration: PageDecoration(
              titleTextStyle: TextStyle(
                color: Colors.blueAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
        next: Text("NEXT"),
        done: Text("DONE"),
        onDone: () {
          prefs.setBool("isOnBoarded", true);
          Navigator.pushReplacement(
            // push vs pushReplacement
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
      ),
    ));
  }
}
