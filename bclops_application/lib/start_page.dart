import 'package:bclops_application/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//시작 페이지 추후 로그인 페이지로 교체, 수정될 수 있음
class StartPage extends StatelessWidget {
  bool isOnboarded;
  SharedPreferences prefs;
  StartPage(this.isOnboarded, this.prefs, {super.key});

  @override
  Widget build(BuildContext context) {
    //디스플레이 화면 비례로 크기 구하기. 이는 테스트 후 바뀔 수 있음
    double displayheight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: displayheight * 0.25,
            ),
            Image.asset(
              'assets/images/aiclops_logo.png',
              width: 200,
            ),
            SizedBox(
              height: displayheight * 0.12,
            ),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blueAccent[250],
                ),
                onPressed: () {
                  //온보딩 동작했는지 확인하고 아닐시
                  // if (!isOnboarded) {
                  //   Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => OnBoarding()),
                  //   );
                  // } else {
                  //   print('시작 누름');

                  //   Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => HomePage()),
                  //   );
                  // }
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage(isOnboarded, prefs)));
                },
                child: Text('시작'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
