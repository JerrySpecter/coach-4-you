import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';
import 'package:health_factory/constants/collections.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/screens/client/client_meal_plan.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import 'package:internet_file/internet_file.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants/routes.dart';

final cloudinarySdk = Cloudinary.full(
  apiKey: '735651249342712',
  apiSecret: '-bHnS3Hz7ValwMez15sJRBMH2po',
  cloudName: 'jerryspecter',
);

class ClientAddMealPlan extends StatefulWidget {
  ClientAddMealPlan(
      {super.key, required this.clientId, required this.filepath});

  String clientId = '';
  String filepath = '';

  @override
  State<ClientAddMealPlan> createState() => _ClientAddMealPlanState();
}

class _ClientAddMealPlanState extends State<ClientAddMealPlan> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  String _fileName = '';
  bool _isLoading = false;

  double _uploadingPercentage = 0;
  String _directoryPath = '';
  late PdfController _pdfController;

  @override
  void initState() {
    setState(() {
      _directoryPath = widget.filepath;
    });

    if (_directoryPath != '') {
      _pdfController = PdfController(
        document: PdfDocument.openData(
          InternetFile.get(
            _directoryPath,
          ),
        ),
        initialPage: 0,
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    if (_directoryPath != '') {
      _pdfController.dispose();
    }
    super.dispose();
  }

  void _pickFiles() async {
    _isLoading = true;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        PlatformFile file = result.files.first;

        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _fileName = file.name;
          _directoryPath = file.path!;
        });

        if (_directoryPath.isNotEmpty) {
          if (widget.filepath.isNotEmpty) {
            _pdfController.loadDocument(PdfDocument.openFile(_directoryPath));
          } else {
            _pdfController = PdfController(
              document: PdfDocument.openFile(_directoryPath),
              initialPage: 0,
            );
          }
        }
      } else {
        _isLoading = false;
        // User canceled the picker
      }
    } on PlatformException catch (e) {
      _isLoading = false;
      _logException('Unsupported operation' + e.toString());
    } catch (e) {
      _isLoading = false;
      _logException(e.toString());
    }
  }

  void _logException(String message) {
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HFColors().backgroundColor(),
      appBar: AppBar(
        backgroundColor: HFColors().backgroundColor(),
        foregroundColor: HFColors().primaryColor(),
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const HFHeading(
          text: 'Meal plan:',
          size: 5,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_directoryPath.isNotEmpty)
              SizedBox(
                width: MediaQuery.of(context).size.width - 16,
                height: MediaQuery.of(context).size.height * 0.5,
                child: PdfView(
                  builders: PdfViewBuilders<DefaultBuilderOptions>(
                    options: const DefaultBuilderOptions(),
                    documentLoaderBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    pageLoaderBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    pageBuilder: pageBuilder,
                    errorBuilder: (p0, error) {
                      return const HFParagrpah(
                        text: 'Error. Please reload.',
                      );
                    },
                  ),
                  controller: _pdfController,
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            if (_fileName.isNotEmpty)
              HFParagrpah(
                text: _fileName,
                size: 8,
                textAlign: TextAlign.center,
              ),
            const SizedBox(
              height: 10,
            ),
            HFButton(
              padding: const EdgeInsets.all(16),
              text: 'Select a meal plan',
              onPressed: () => _pickFiles(),
            ),
            const SizedBox(
              height: 20,
            ),
            HFButton(
              padding: const EdgeInsets.all(16),
              text: _isLoading ? 'Loading...' : 'Upload',
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });

                cloudinarySdk
                    .uploadResource(
                  CloudinaryUploadResource(
                    filePath: _directoryPath,
                    resourceType: CloudinaryResourceType.auto,
                    folder: 'clients/${widget.clientId}',
                    fileName: 'meal_plan',
                  ),
                )
                    .then((value) {
                  FirebaseFirestore.instance
                      .collection(COLLECTION_CLIENTS)
                      .doc(widget.clientId)
                      .update({'mealPlanUrl': value.url}).then((value) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        text: 'Meal plan added!',
                        color: HFColors().primaryColor()));
                  });

                  setState(() {
                    _isLoading = false;
                  });
                }).onError((error, stackTrace) {
                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                      text: 'There was an error.',
                      color: HFColors().redColor()));
                  setState(() {
                    _isLoading = false;
                  });
                }).catchError((onError) {
                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                      text: 'There was an error.',
                      color: HFColors().redColor()));
                  setState(() {
                    _isLoading = false;
                  });
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
