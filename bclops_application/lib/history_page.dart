import 'package:bclops_application/result_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cp949_codec/cp949_codec.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//이 클래스 자체는 추후 drawer 사용 여부에 따라 page와 합병, 삭제될 수 있음
class HistoryBody extends StatefulWidget {
  const HistoryBody({super.key});

  @override
  State<HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends State<HistoryBody> {
  // List<dynamic> historyList = [
  //   {
  //     "date": "20231106",
  //     "dist": "100",
  //     "img": "https://cdn2.thecatapi.com/images/2vk.jpg",
  //   },
  //   {
  //     "date": "20231106",
  //     "dist": "100",
  //     "img": "https://cdn2.thecatapi.com/images/a15.jpg",
  //   },
  //   {
  //     "date": "20231106",
  //     "dist": "100",
  //     "img": "https://cdn2.thecatapi.com/images/bnk.jpg",
  //   },
  //   {
  //     "date": "20231106",
  //     "dist": "100",
  //     "img": "https://cdn2.thecatapi.com/images/d6c.jpg",
  //   },
  //   {
  //     "date": "20231106",
  //     "dist": "100",
  //     "img": "https://cdn2.thecatapi.com/images/eid.jpg",
  //   },
  //   {
  //     "date": "20231106",
  //     "dist": "100",
  //     "img": "https://cdn2.thecatapi.com/images/MTUzMTU3Ng.jpg",
  //   },
  //   {
  //     "date": "20231106",
  //     "dist": "100",
  //     "img": "https://cdn2.thecatapi.com/images/MTU3OTc2NQ.jpg",
  //   },
  //   {
  //     "date": "20231106",
  //     "dist": "100",
  //     "img": "https://cdn2.thecatapi.com/images/MTczMDA4MQ.jpg",
  //   },
  //   {
  //     "date": "20231106",
  //     "dist": "100",
  //     "img": "https://cdn2.thecatapi.com/images/utX9jo5EO.jpg",
  //   },
  //   {
  //     "date": "20231106",
  //     "dist": "100",
  //     "img": "https://cdn2.thecatapi.com/images/WAwazYKhH.jpg",
  //   },
  // ];
  String apiUrl = "http://3.34.55.153";
  final storage = FlutterSecureStorage();
  String? token;
  int? userId;

  Future<String?> _readCsvUrl(String url) async {
    Dio dio = Dio();
    var data =
        await dio.get(url, options: Options(responseType: ResponseType.bytes));
    print(data.data);
    String? result = cp949.decode(data.data);
    return result;
  }

  Future<List<dynamic>?> _parsingResult(List<dynamic> data) async {
    List<dynamic>? resultUrl = [];
    List<String> resultImg = [];
    // resultUrl["csvData"] = csvData;
    String url = data[1]["resultImageUrl"];
    String? csvData = await _readCsvUrl(url);
    resultImg.add(data[0]["resultImageUrl"]);

    if (data.length > 3) {
      for (int i = 3; i < data.length; i++) {
        resultImg.add(data[i]["resultImageUrl"]);
      }
    }
    resultUrl.add(resultImg);
    resultUrl.add(data[2]["resultImageUrl"]);
    resultUrl.add(csvData!);
    print(resultUrl[0]);
    return resultUrl;
  }

  Future<List<dynamic>?> _getHistory() async {
    String? userIdString = await storage.read(key: 'userId');
    userId = int.parse(userIdString!);
    token = await storage.read(key: 'token');
    final baseOptions = BaseOptions(
        baseUrl: apiUrl,
        headers: {'x-access-token': token},
        queryParameters: {'userId': userId});
    print(userId);
    var dio = Dio(baseOptions);
    final result = await dio.get("/web/image-histories");
    if (result.data["isSuccess"]) {
      print(result.data["result"]["imageHistories"]);
      Navigator.pop(context);
      return result.data["result"]["imageHistories"];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getHistory(),
      builder: ((context, snapshot) {
        if (snapshot.hasData == false) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(fontSize: 15),
            ),
          );
        } else {
          final List<dynamic> historyList = List.from(snapshot.data!.reversed);
          if (historyList!.isEmpty) {
            return Center(child: Text("히스토리 기록이 없습니다"));
          } else {
            return ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data = historyList[index];

                //date format 바꾸기
                // DateTime stoDate = DateTime.parse(data["date"]);
                // String date = DateFormat("yyyy년MM월dd일").format(stoDate);
                print(data);
                int id = data["id"];
                String date = data["createdAt"];
                String dist = data["distance"].toString();
                String imgUrl = data["imageUrl"];
                List<dynamic> urlData = data["resultImages"];
                bool isHovering = false;
                return Column(
                  children: [
                    //기록 삭제 swipe로 삭제
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      //InkWell은 터치 효과때문에 사용
                      child: InkWell(
                        onTap: () {},
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            //여기서 통신 후 히스토리 받아오기
                            var parsingData = _parsingResult(urlData);
                            parsingData.then((value) => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResultPage(
                                          resultImgsUrl: value![0],
                                          stereonetUrl: value[1],
                                          time: "${date}_$id",
                                          distance: dist,
                                          data: value[2]),
                                    ),
                                  )
                                });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 20.0, 5, 100.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      date,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "거리:${dist}cm",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: CachedNetworkImage(
                                  imageUrl: imgUrl,
                                  placeholder: (context, url) => SpinKitCircle(
                                    color: Colors.blue[200],
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  width: 180,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            );
          }
        }
      }),
    );
  }
}
