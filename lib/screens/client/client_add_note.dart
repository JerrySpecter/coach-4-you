import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';
import 'package:health_factory/constants/collections.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/screens/client/client_meal_plan.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import 'package:pdfx/pdfx.dart';
import 'package:uuid/uuid.dart';
import '../../../constants/colors.dart';
import 'package:internet_file/internet_file.dart';
import 'package:file_picker/file_picker.dart';

import '../../widgets/hf_input_field.dart';

final cloudinarySdk = Cloudinary.full(
  apiKey: '735651249342712',
  apiSecret: '-bHnS3Hz7ValwMez15sJRBMH2po',
  cloudName: 'jerryspecter',
);

class ClientAddNote extends StatefulWidget {
  ClientAddNote({
    super.key,
    required this.clientEmail,
    required this.clientId,
    this.filepath = '',
    this.noteId = '',
    this.title = '',
    this.date = '',
    this.description = '',
    this.isEdit = false,
  });

  String clientEmail;
  String clientId;
  String noteId;
  String title;
  String date;
  String description;
  String filepath;
  bool isEdit;

  @override
  State<ClientAddNote> createState() => _ClientAddNoteState();
}

class _ClientAddNoteState extends State<ClientAddNote> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _isLoading = false;
  String _directoryPath = '';
  late PdfController _pdfController;
  final noteTitleController = TextEditingController();
  final noteDocumentController = TextEditingController();
  final noteDescriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _initialName = '';
  String _initialDescription = '';
  bool isTemp = false;

  @override
  void initState() {
    super.initState();

    isTemp = widget.clientEmail == '';

    if (widget.isEdit) {
      setState(() {
        _directoryPath = widget.filepath;
        _initialName = widget.title;
        _initialDescription = widget.description;

        noteTitleController.text = widget.title;
        noteDescriptionController.text = widget.description;
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
    }
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
          noteDocumentController.text = file.name;
        });

        if (file.path != '') {
          if (widget.filepath.isNotEmpty) {
            _pdfController.loadDocument(PdfDocument.openFile(file.path!));
          } else {
            if (_directoryPath.isEmpty) {
              _pdfController = PdfController(
                document: PdfDocument.openFile(file.path!),
                initialPage: 0,
              );
            } else {
              _pdfController.loadDocument(PdfDocument.openFile(file.path!));
            }
          }
        }

        setState(() {
          _directoryPath = file.path!;
        });
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
        title: HFHeading(
          text: widget.isEdit ? 'Edit note' : 'Add note',
          size: 5,
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HFInput(
                  hintText: 'Note title',
                  controller: noteTitleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title.';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
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
                            size: 8,
                            text: 'Wrong format. Please select a PDF document.',
                          );
                        },
                      ),
                      controller: _pdfController,
                    ),
                  ),
                if (_directoryPath.isNotEmpty)
                  const SizedBox(
                    height: 10,
                  ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      child: HFInput(
                        hintText: 'PDF document',
                        readOnly: true,
                        showCursor: false,
                        controller: noteDocumentController,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    if (_directoryPath.isEmpty)
                      InkWell(
                        child: Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                              color: HFColors().primaryColor(),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.add,
                              size: 18,
                            ),
                          ),
                        ),
                        onTap: () => _pickFiles(),
                      )
                    else
                      InkWell(
                        child: Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                              color: HFColors().redColor(),
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.trash,
                              color: HFColors().whiteColor(),
                              size: 18,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _directoryPath = '';
                            noteDocumentController.text = '';
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                HFInput(
                  hintText: 'Note description',
                  controller: noteDescriptionController,
                  minLines: 15,
                  maxLines: 15,
                ),
                const SizedBox(
                  height: 20,
                ),
                HFButton(
                  padding: const EdgeInsets.all(16),
                  text: _isLoading
                      ? 'Loading...'
                      : widget.isEdit
                          ? 'Update note'
                          : 'Add note',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      var newId = const Uuid().v4();
                      var noteId = widget.isEdit ? widget.noteId : newId;
                      var date =
                          widget.isEdit ? widget.date : '${DateTime.now()}';

                      setState(() {
                        _isLoading = true;
                      });

                      var editedData = {
                        'name': noteTitleController.text,
                        'description': noteDescriptionController.text,
                        'filepath': _directoryPath,
                      };

                      var filepath = '';

                      if (_directoryPath != widget.filepath) {
                        if (_directoryPath == '') {
                          filepath = '';
                        } else {
                          setState(() {});

                          var uploadValue = await cloudinarySdk.uploadResource(
                            CloudinaryUploadResource(
                              filePath: _directoryPath,
                              folder:
                                  'clients/${widget.clientId}/notes/$noteId',
                              fileName: '${noteId}_document',
                              progressCallback: (count, total) {
                                setState(() {});
                              },
                            ),
                          );

                          filepath = uploadValue.secureUrl as String;
                        }
                      } else {
                        filepath = widget.filepath;
                      }

                      if (widget.isEdit) {
                        editedData.update('filepath', (v) => filepath);

                        if (_initialName != noteTitleController.text) {
                          editedData.update(
                              'name', (value) => noteTitleController.text);
                        }

                        if (_initialDescription !=
                            noteDescriptionController.text) {
                          editedData.update('description',
                              (value) => noteDescriptionController.text);
                        }

                        await HFFirebaseFunctions()
                            .getFirebaseAuthUser(context)
                            .collection(
                                isTemp ? 'tempClients' : COLLECTION_CLIENTS)
                            .doc(isTemp ? widget.clientId : widget.clientEmail)
                            .collection(COLLECTION_NOTES)
                            .doc(noteId)
                            .update(editedData);
                      } else {
                        HFFirebaseFunctions()
                            .getFirebaseAuthUser(context)
                            .collection(
                                isTemp ? 'tempClients' : COLLECTION_CLIENTS)
                            .doc(isTemp ? widget.clientId : widget.clientEmail)
                            .collection(COLLECTION_NOTES)
                            .doc(noteId)
                            .set({
                          'name': noteTitleController.text,
                          'description': noteDescriptionController.text,
                          'id': noteId,
                          'filepath': filepath,
                          'date': date
                        }).then((value) {
                          setState(() {
                            _isLoading = false;
                          });
                        });
                      }

                      ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        text: widget.isEdit ? 'Note updated' : 'Note added',
                        color: HFColors().primaryColor(opacity: 1),
                      ));

                      Navigator.pop(context);

                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ),
                const SizedBox(
                  height: 60,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
