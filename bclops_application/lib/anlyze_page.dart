import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'image_confirm_page.dart';

var ios = foundation.defaultTargetPlatform == foundation.TargetPlatform.iOS;
var android =
    foundation.defaultTargetPlatform == foundation.TargetPlatform.android;

class AnalyzePage extends StatelessWidget {
  AnalyzePage({super.key});

  BuildContext? cont;

  Future<XFile?> _cropImage(XFile? pickedFile) async {
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '이미지 자르기',
            toolbarColor: Colors.blue[300],
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: '이미지 자르기',
          ),
          WebUiSettings(
            context: cont!,
            presentStyle: CropperPresentStyle.page,
            boundary: const CroppieBoundary(
              width: 500,
              height: 500,
            ),
            enableResize: true,
            enableOrientation: true,
            mouseWheelZoom: true,
            enableExif: false,
            enableZoom: true,
            showZoomer: false,
          ),
        ],
      );
      if (croppedFile != null) {
        return XFile(croppedFile.path);
      }
    }
    return null;
  }

  Future _pickImage(ImageSource imageSource) async {
    final ImagePicker picker = ImagePicker();
    if (ios) {
      var requestStatus = await Permission.camera.request();
      var status = await Permission.camera.status;
      print('camera: $requestStatus');
      print('camera: $status');
      if (status.isPermanentlyDenied) {
        // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
        print("not isGranted");
        openAppSettings();
      }

      requestStatus = await Permission.photos.request();
      status = await Permission.photos.status;
      print('photos: $requestStatus');
      print('photos: ${status.isLimited}');
      if (!status.isGranted) {
        print('not isGranted');
        openAppSettings();
      }
    }
    final pickedFile = await picker.pickImage(source: imageSource);
    XFile? croppedFile;
    if (pickedFile != null) {
      croppedFile = await _cropImage(pickedFile);
    }
    if (croppedFile != null) {
      //이미지 촬영, 선택 후 이미지 확인 페이지 호출.
      //동작하는지 테스트 할 겸 async안에서 호출했는데 동작함. 안정성이 떨어질 것 같아 추후 async에서 뺄 수 있다.

      if (!kIsWeb) {
        Navigator.push(
          cont!,
          MaterialPageRoute(
              builder: (context) => ImageConfirmPage(croppedFile!)),
        );
      } else {
        print("path : ${croppedFile.path}");
        var webImg = await croppedFile.readAsBytes();
        Navigator.push(
          cont!,
          MaterialPageRoute(
              builder: (context) =>
                  ImageConfirmPage(croppedFile!, webImage: webImg)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    cont = context;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              "사진 가져오기",
              style: TextStyle(
                fontSize: 25.0,
              ),
            ),
          ),
          if (!kIsWeb)
            IconButton(
              padding: EdgeInsets.symmetric(vertical: 7),
              onPressed: () async {
                print("Camera");
                _pickImage(ImageSource.camera);
              },
              iconSize: 200,
              icon: Icon(CupertinoIcons.camera_fill),
            ),
          !kIsWeb
              ? Divider(
                  height: 20,
                  color: Colors.black45,
                  indent: 40.0,
                  endIndent: 40.0,
                )
              : SizedBox(
                  width: double.infinity,
                ),
          IconButton(
            padding: EdgeInsets.symmetric(vertical: 7),
            onPressed: () async {
              print("gallery");
              _pickImage(ImageSource.gallery);
            },
            iconSize: 200,
            icon: Icon(CupertinoIcons.photo),
          ),
          SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }
}
