import 'dart:io';

import 'package:bclops_application/result_page.dart';
import 'package:cp949_codec/cp949_codec.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

//이미지 확인 및 서버로 보내기 전단계
class ImageConfirmPage extends StatefulWidget {
  final XFile pickedImg;
  final Uint8List? webImage;
  const ImageConfirmPage(this.pickedImg, {super.key, this.webImage});

  @override
  State<ImageConfirmPage> createState() => _ImageConfirmPageState();
}

class _ImageConfirmPageState extends State<ImageConfirmPage> {
  // void getWebImage() async {
  //   var f = await widget.pickedImg.readAsBytes();
  //   setState(() {
  //     webImage = f;
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   if (kIsWeb) {
  //     getWebImage();
  //   }
  // }
  //Map<String, String>? resultUrl;

  //Future<Map<String, String>>
  final storage = FlutterSecureStorage();
  Future<String?> _readCsvUrl(String url) async {
    Dio dio = Dio();
    var data =
        await dio.get(url, options: Options(responseType: ResponseType.bytes));
    print(data.data);
    String? result = cp949.decode(data.data);
    return result;
  }

  Future<List<dynamic>?> sendToServer(int dist) async {
    //서버 통신 후 결과 이미지들의 URL, 데이터 받아야함.
    // resultUrl = {
    //   "resultUrl": "https://i.ibb.co/CQxfdHY/cat1.jpg",
    //   "stereonetUrl": "https://i.ibb.co/w6wxdrQ/cat2.jpg",
    //   "tableUrl": "https://i.ibb.co/GnwVqCd/cat3.jpg",
    // };
    String apiUrl = "http://3.34.55.153";
    String? token = await storage.read(key: 'token');
    final baseOptions = BaseOptions(
      baseUrl: apiUrl,
      headers: {'x-access-token': token},
    );
    MultipartFile imgFile;    var dio = Dio(baseOptions);
    if (kIsWeb) {
      imgFile = MultipartFile.fromBytes(widget.webImage!,
          filename: "croppedimage.jpg");
      // imgFile = MultipartFile.fromFileSync(widget.pickedImg.path);
    } else {
      imgFile = MultipartFile.fromFileSync(widget.pickedImg.path);
    }

    FormData formData = FormData.fromMap({"distance": dist, "file": imgFile});
    var result = await dio.post("/web/ai", data: formData);
    print(result.data);
    if (result.data["isSuccess"]) {
      List<dynamic>? resultUrl = [];
      List<String> resultImg = [];
      // resultUrl["csvData"] = csvData;
      List<dynamic> requestResultList = result.data["result"]["presigned_urls"];
      String url = requestResultList[1];
      String? csvData = await _readCsvUrl(url);
      resultImg.add(requestResultList[0]);

      if (requestResultList.length > 3) {
        for (int i = 3; i < requestResultList.length; i++) {
          resultImg.add(requestResultList[i]);
        }
        resultUrl.add(resultImg);
      } else {
        resultUrl.add(resultImg);
      }
      resultUrl.add(requestResultList[2]);
      resultUrl.add(csvData!);
      return resultUrl;
    } else {
      return null;
    }
  }

  void analyzeImage(String dist) async {
    FocusManager.instance.primaryFocus!.unfocus();
    //서버 연결할때 이미지, 거리값 인자로 추가
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => LoadingScreen()));
    Future<List<dynamic>?> urlList = sendToServer(int.parse(dist));
    //서버에서 받은 정보를 replacement 인자로 추가해야함.
    //아래 delay는 로딩창을 보기위한 장치 서버 연결하면 수정
    urlList.then((resultUrl) {
      Navigator.pop(context);
      if (resultUrl != null) {
        var now = DateTime.now();
        String date = DateFormat('yyyyMMdd_hhmms').format(now);
        print(date);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              resultImgsUrl: resultUrl[0],
              stereonetUrl: resultUrl[1],
              distance: dist,
              time: date,
              data: resultUrl[2],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("오류가 발생하였습니다"),
        ));
      }
    });

    // Future.delayed(Duration(seconds: 1), () {
    //   Navigator.pop(context);
    //   if (resultUrl != null) {
    //     var now = DateTime.now();
    //     String date = DateFormat('yyyyMMdd_hmms').format(now);
    //     print(date);
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => ResultPage(
    //           resultUrl!["resultUrl"]!,
    //           resultUrl!["stereonetUrl"]!,
    //           resultUrl!["tableUrl"]!,
    //           date,
    //         ),
    //       ),
    //     );
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content: Text("오류가 발생하였습니다"),
    //     ));
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    // double displaywidth = MediaQuery.of(context).size.width;
    print("build!");
    TextEditingController textController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("이미지 확인"),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 30,
          ),
        ),
        backgroundColor: Colors.blue[300],
        elevation: 0.3,
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus!.unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      height: 150,
                      child: kIsWeb
                          ? Image.memory(widget.webImage!)
                          : Image.file(File(widget.pickedImg.path)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 70.0),
                      child: Text(
                        "이미지까지 거리를 입력해주세요",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: textController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        Text(
                          "cm",
                          style: TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                    //Spacer(flex: 2),
                    SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  print(textController.text);
                  if (textController.text == '') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("거리를 입력해주세요."),
                    ));
                  } else {
                    analyzeImage(textController.text);
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(247, 108, 102, 102),
                ),
                child: Text('분석하기'),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: SpinKitCircle(
            color: Colors.white,
            size: 70,
          ),
        ),
      ),
    );
  }
}
