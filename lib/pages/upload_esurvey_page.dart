// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

class UploadEsurveyPage extends StatefulWidget {
  const UploadEsurveyPage({
    super.key,
  });

  @override
  State<UploadEsurveyPage> createState() => _UploadEsurveyPageState();
}

class _UploadEsurveyPageState extends State<UploadEsurveyPage> {
  List<XFile>? _mediaFileList;
  bool _isLoaded = false;
  bool _alreadyUpload = false;
  String? _tokenSecure;
  final storage = const FlutterSecureStorage();

  dynamic _pickImageError;
  bool isVideo = false;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  final TextEditingController limitController = TextEditingController();

  void _loadPreferences() async {
    final tokenSecure = await storage.read(key: 'tokenSecure') ?? "";
    setState(() {
      _tokenSecure = tokenSecure;
    });
    getDataUpload();
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _setImageFileListFromFile(XFile? value) {
    _mediaFileList = value == null ? null : <XFile>[value];
  }

  Future<void> getDataUpload() async {
    String apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/esurvey';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_tokenSecure',
      });

      if (response.statusCode == 200) {
        //mengabil data user
        final dataUpload = json.decode(response.body)['data'];
        // print(dataUpload);

        setState(() {
          if (dataUpload['alreadyUp'] == 1) {
            _alreadyUpload = true;
          }
        });
      } else {
        debugPrint(apiUrl);
        print(response.statusCode);
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      } else {}
    }
  }

  Future<void> uploadFile(XFile file) async {
    // File files = File(file.path);
    String apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/esurvey';
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers['authorization'] = 'Bearer $_tokenSecure';
    request.files.add(http.MultipartFile.fromBytes(
        'image',
        await file.readAsBytes().then((value) {
          return value.cast();
        }),
        filename: file.path.toString() + file.name));
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var resBody = jsonDecode(responseData.body);
      print(resBody);
    } else {
      print(response.statusCode);
    }
  }

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
    bool isMultiImage = false,
    bool isMedia = false,
  }) async {
    if (context.mounted) {
      if (isMedia) {
        await _displayPickImageDialog(context, false, (double? maxWidth,
            double? maxHeight, int? quality, int? limit) async {
          try {
            final List<XFile> pickedFileList = <XFile>[];
            final XFile? media = await _picker.pickMedia(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
              imageQuality: quality,
            );
            if (media != null) {
              pickedFileList.add(media);
              setState(() {
                _mediaFileList = pickedFileList;
              });
            }
          } catch (e) {
            setState(() {
              _pickImageError = e;
            });
          }
        });
      } else {
        await _displayPickImageDialog(context, false, (double? maxWidth,
            double? maxHeight, int? quality, int? limit) async {
          try {
            final XFile? pickedFile = await _picker.pickImage(
              source: source,
              maxWidth: maxWidth,
              maxHeight: maxHeight,
              imageQuality: quality,
            );
            setState(() {
              print(pickedFile?.path ?? 'path');
              _setImageFileListFromFile(pickedFile);
            });
          } catch (e) {
            setState(() {
              _pickImageError = e;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_mediaFileList != null) {
      setState(() {
        _isLoaded = true;
      });
      return Semantics(
        label: 'image_picker_example_picked_images',
        child: ListView.builder(
          key: UniqueKey(),
          itemBuilder: (BuildContext context, int index) {
            final String? mime = lookupMimeType(_mediaFileList![index].path);

            // Why network for web?
            // See https://pub.dev/packages/image_picker_for_web#limitations-on-the-web-platform
            return Semantics(
              label: 'image_picker_example_picked_image',
              child: kIsWeb
                  ? Image.network(_mediaFileList![index].path)
                  : Image.file(
                      File(_mediaFileList![index].path),
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return const Center(
                            child: Text('This image type is not supported'));
                      },
                    ),
            );
          },
          itemCount: _mediaFileList!.length,
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _handlePreview() {
    return _previewImages();
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      {
        setState(() {
          if (response.files == null) {
            _setImageFileListFromFile(response.file);
          } else {
            _mediaFileList = response.files;
          }
        });
      }
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload E-Survey"),
      ),
      body: Center(
        child: _alreadyUpload
            ? Image.network(
                "https://picsum.photos/200/300",
                fit: BoxFit.fill,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              )
            : !kIsWeb && defaultTargetPlatform == TargetPlatform.android
                ? FutureBuilder<void>(
                    future: retrieveLostData(),
                    builder:
                        (BuildContext context, AsyncSnapshot<void> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return const Text(
                            'You have not yet picked an image.',
                            textAlign: TextAlign.center,
                          );
                        case ConnectionState.done:
                          return _handlePreview();
                        case ConnectionState.active:
                          if (snapshot.hasError) {
                            return Text(
                              'Pick image error: ${snapshot.error}}',
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return const Text(
                              'You have not yet picked an image.',
                              textAlign: TextAlign.center,
                            );
                          }
                      }
                    },
                  )
                : _handlePreview(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (_isLoaded)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Semantics(
                label: 'image_picker_example_from_gallery',
                child: FloatingActionButton(
                  onPressed: () {
                    uploadFile(_mediaFileList![0]);
                  },
                  heroTag: 'image0',
                  tooltip: 'Kirim',
                  child: const Icon(Icons.send),
                ),
              ),
            ),
          if (!_alreadyUpload)
            Semantics(
              label: 'image_picker_example_from_gallery',
              child: FloatingActionButton(
                onPressed: () {
                  isVideo = false;
                  _onImageButtonPressed(ImageSource.gallery, context: context);
                },
                heroTag: 'image0',
                tooltip: 'Pick Image from gallery',
                child: const Icon(Icons.photo),
              ),
            ),
        ],
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, bool isMulti, OnPickImageCallback onPick) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Silahkan Upload'),
            actions: <Widget>[
              TextButton(
                child: const Text('Batal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: const Text('Pilih'),
                  onPressed: () {
                    onPick(null, null, null, null);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality, int? limit);
