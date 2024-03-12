import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bclops_application/resultTable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cp949_codec/cp949_codec.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

BuildContext? cont;

class ResultPage extends StatefulWidget {
  final List<String> resultImgsUrl;
  final String stereonetUrl;
  final String time;
  final String distance;
  final String data;
  static Widget? dataTable;
  static ScreenshotController screenshotController = ScreenshotController();

  const ResultPage(
      {super.key,
      required this.resultImgsUrl,
      required this.stereonetUrl,
      required this.time,
      required this.distance,
      required this.data});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int _carouselIndex = 0;
  CarouselController buttonCarouselController = CarouselController();
  @override
  Widget build(BuildContext context) {
    cont = context;
    print("build!");

    Widget dataTable = ResultTable(data: widget.data);

    return Scaffold(
      appBar: AppBar(
        title: Text("결과"),
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
            color: Colors.black87,
            size: 30,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.black87),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => SaveDialog(
                imgUrlList: [widget.resultImgsUrl, widget.stereonetUrl],
                time: widget.time,
                data: widget.data,
                downloadAllOption: true,
              ),
            ),
            child: Text(
              "모두 저장",
            ),
          )
        ],
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                    ),
                    SizedBox(
                      height: 50,
                      child: Text(
                        '거리 : ${widget.distance}cm',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),

                    kIsWeb
                        ? Stack(
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 250,
                                  viewportFraction: 1,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _carouselIndex = index;
                                    });
                                  },
                                ),
                                carouselController: buttonCarouselController,
                                items: widget.resultImgsUrl.map((resultimg) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return GestureDetector(
                                        onTap: () => showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              SaveDialog(
                                            imgUrl: resultimg,
                                            time: widget.time,
                                            downloadAllOption: true,
                                            title:
                                                'ResultImage${_carouselIndex + 1}',
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 30,
                                              child: Text(
                                                (_carouselIndex < 2)
                                                    ? "결과 이미지${_carouselIndex + 1}"
                                                    : "Jointset${_carouselIndex - 1}",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 350,
                                              child: Image.network(resultimg,
                                                  fit: BoxFit.contain,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child: SpinKitCircle(
                                                    color: Colors.blue[200],
                                                  ),
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                              Positioned.fill(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () {
                                        print("previous!");
                                        buttonCarouselController.previousPage();
                                      },
                                    ),
                                    SizedBox(
                                      width: 100,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () {
                                        print("next!");
                                        buttonCarouselController.nextPage();
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        : CarouselSlider(
                            options: CarouselOptions(
                              height: 250,
                              viewportFraction: 1,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _carouselIndex = index;
                                });
                              },
                            ),
                            carouselController: buttonCarouselController,
                            items: widget.resultImgsUrl.map((resultimg) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          SaveDialog(
                                        imgUrl: resultimg,
                                        title:
                                            'ResultImage${_carouselIndex + 1}',
                                        time: widget.time,
                                        downloadAllOption: false,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          child: Text(
                                            (_carouselIndex < 2)
                                                ? "결과 이미지${_carouselIndex + 1}"
                                                : "Jointset${_carouselIndex - 1}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 350,
                                          child: Image.network(resultimg,
                                              fit: BoxFit.contain,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: SpinKitCircle(
                                                color: Colors.blue[200],
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 30,
                      child: Text(
                        "스테레오넷",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (BuildContext context) => SaveDialog(
                            imgUrl: widget.stereonetUrl,
                            title: "Stereonet",
                            time: widget.time,
                            downloadAllOption: false,
                          ),
                        ),
                        child: SizedBox(
                          width: 350,
                          child: CachedNetworkImage(
                            imageUrl: widget.stereonetUrl,
                            placeholder: (context, url) => SpinKitCircle(
                              color: Colors.blue[200],
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: Text(
                        "결과표",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 30),
                    InkWell(
                      child: GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (BuildContext context) => SaveDialog(
                              downloadAllOption: false,
                              data: widget.data,
                              time: widget.time),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Screenshot(
                            controller: ResultPage.screenshotController,
                            child: dataTable,
                          ),
                        ),
                      ),
                    ),
                    // DataTable
                    //Spacer(flex: 2),
                    SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 330,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(247, 108, 102, 102),
                ),
                child: Text('종료'),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class SaveDialog extends StatelessWidget {
  final String? imgUrl;
  final String time;
  final List<dynamic>? imgUrlList;
  final String? data;
  final String? title;
  final bool downloadAllOption;
  static int notificationId = 0;
  const SaveDialog(
      {super.key,
      required this.time,
      required this.downloadAllOption,
      this.imgUrl,
      this.imgUrlList,
      this.title,
      this.data});

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          var directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }

  _downloadCsv() async {
    if (data != null) {
      String? path;
      if (!kIsWeb) {
        await getPermission();
        path = await getDownloadPath();
      }
      List<int> encodedCsv = cp949.encode(data!);
      Uint8List csvBytesList = Uint8List.fromList(encodedCsv);
      String filename = '${time}_table_data';
      String downloadedPath = await FileSaver.instance.saveFile(
        // filePath: kIsWeb ? null : path,
        name: filename,
        bytes: csvBytesList,
        ext: 'csv',
        mimeType: MimeType.csv,
      );
      if (!kIsWeb) {
        if (downloadedPath !=
            'Something went wrong, please report the issue https://www.github.com/incrediblezayed/file_saver/issues') {
          if (Platform.isAndroid) {
            String? path = await getDownloadPath();
            String filepath = '$path/${time}_table_data.csv';
            await File(downloadedPath).copy(filepath);
            await File(downloadedPath).delete();
            AwesomeNotifications().createNotification(
                content: NotificationContent(
              id: notificationId,
              channelKey: 'basic_channel',
              actionType: ActionType.Default,
              title: '파일이 저장되었습니다',
              body: filepath,
              payload: {'filepath': filepath},
            ));
            notificationId++;
          } else if (Platform.isIOS) {
            String? path = await getDownloadPath();
            AwesomeNotifications().createNotification(
                content: NotificationContent(
              id: notificationId,
              channelKey: 'basic_channel',
              actionType: ActionType.Default,
              title: '파일이 저장되었습니다',
              body: path,
              payload: {'filepath': path},
            ));
            notificationId++;
          }
          ScaffoldMessenger.of(cont!).showSnackBar(SnackBar(
            content: Text("저장되었습니다"),
          ));
        } else {
          ScaffoldMessenger.of(cont!).showSnackBar(SnackBar(
            content: Text("저장중 오류가 발생하였습니다"),
          ));
        }
      }
    }
  }

  Future<bool> _saveImage(String filename, String imgUrl) async {
    var response = await Dio()
        .get(imgUrl, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.data),
      quality: 60,
      name: filename,
    );
    print(result);
    if (!result['isSuccess']) {
      ScaffoldMessenger.of(cont!).showSnackBar(SnackBar(
        content: Text("$filename 저장중 오류가 발생하였습니다"),
      ));
      return false;
    }
    String? resultPath = result['filePath'];
    String path = resultPath!.split('content:')[1];
    print(path);

    if (path.contains('//media/external/')) {
      var directory = Directory('/storage/emulated/0/Pictures');
      if (await directory.exists()) {
        path = '${directory.path}/$filename.jpg';
      }
    }
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: notificationId,
      channelKey: 'basic_channel',
      actionType: ActionType.Default,
      title: '파일이 저장되었습니다',
      body: path,
      payload: {'filepath': path},
    ));
    notificationId++;

    return result['isSuccess'];
  }

  _saveResult() async {
    if (!kIsWeb) {
      await getPermission();
      if (downloadAllOption && imgUrlList != null) {
        List<String> resultImgs = imgUrlList![0];
        var imgcount = resultImgs.length;
        for (int i = 0; i < imgcount; i++) {
          var filename = '${time}_ResultImage${i + 1}';
          var result = await _saveImage(filename, resultImgs[i]);
          if (!result) {
            return;
          }
        }
        var filename = '${time}_Stereonet';
        var result = await _saveImage(filename, imgUrlList![1]);
        if (!result) {
          return;
        }
        _downloadCsv();
        return;
        // await _saveWidget(context);
      } else {
        var filename = '${time}_$title';
        var result = await _saveImage(filename, imgUrl!);

        if (!result) {
          return;
        }
      }
      ScaffoldMessenger.of(cont!).showSnackBar(SnackBar(
        content: Text("저장되었습니다"),
      ));
    } else {
      if (downloadAllOption && imgUrlList != null) {
        List<String> resultImgs = imgUrlList![0];
        for (int i = 0; i < resultImgs.length; i++) {
          await WebImageDownloader.downloadImageFromWeb(
            name: '${time}_ResultImage${i + 1}',
            resultImgs[i],
          );
        }

        await WebImageDownloader.downloadImageFromWeb(
          name: '${time}_Stereonet',
          imgUrlList![1],
        );
        _downloadCsv();
      } else {
        await WebImageDownloader.downloadImageFromWeb(
          name: '${time}_$title',
          imgUrl!,
        );
      }
    }
  }

  //권한 받는 부분 IOS도 권한이 필요하면 수정해주세요!!
  getPermission() async {
    Map<String, dynamic> deviceInfo = await _getDeviceInfo();
    int sdkVersion = Platform.isAndroid ? deviceInfo['version.sdkInt'] : 1;

    if (sdkVersion >= 30) {
      var status = await Permission.manageExternalStorage.status;
      if (status.isGranted) {
        print('isGranted');
      } else if (status.isDenied) {
        print('isDenied');
        await Permission.manageExternalStorage.request();
      }
      var imageStatus = await Permission.photos.status;
      if (imageStatus.isGranted) {
        print('isGranted');
      } else if (imageStatus.isDenied) {
        print('isDenied');
        await Permission.photos.request();
      }
    } else {
      print("under 30");
      var status = await Permission.storage.status;
      print(status);
      if (status == PermissionStatus.granted) {
        print('isGranted');
      } else if (status == PermissionStatus.denied) {
        print('isDenied');
        await Permission.storage.request();
      }
    }
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'displaySizeInches':
          ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
      'displayWidthPixels': build.displayMetrics.widthPx,
      'displayWidthInches': build.displayMetrics.widthInches,
      'displayHeightPixels': build.displayMetrics.heightPx,
      'displayHeightInches': build.displayMetrics.heightInches,
      'displayXDpi': build.displayMetrics.xDpi,
      'displayYDpi': build.displayMetrics.yDpi,
      'serialNumber': build.serialNumber,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    var deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } catch (error) {
      deviceData = {"Error": "Failed to get platform version."};
    }
    return deviceData;
  }

  @override
  Widget build(BuildContext context) {
    print(time);
    return AlertDialog(
      title: Text("이미지 저장"),
      content: Text("이미지를 저장하시겠습니까?"),
      actions: [
        TextButton(
          onPressed: () async {
            print("저장");
            if (imgUrl == null && imgUrlList == null) {
              _downloadCsv();
            } else {
              _saveResult();
            }
            Navigator.pop(context, 'save');
          },
          child: Text("저장"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
          child: Text("취소"),
        ),
      ],
    );
  }
}
