import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:health_factory/constants/collections.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/screens/client/client_add_note.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:pdfx/pdfx.dart';
import 'package:internet_file/internet_file.dart';
import '../../../constants/colors.dart';
import '../../widgets/hf_dialog.dart';
import '../../widgets/hf_snackbar.dart';
import 'package:intl/intl.dart';

class ClientNote extends StatefulWidget {
  ClientNote({
    super.key,
    required this.clientEmail,
    required this.clientId,
    required this.noteId,
    required this.name,
    required this.description,
    required this.filepath,
    required this.date,
  });

  String clientEmail = '';
  String clientId = '';
  String noteId = '';
  String name = '';
  String description = '';
  String filepath = '';
  String date = '';

  @override
  State<ClientNote> createState() => _ClientNoteState();
}

class _ClientNoteState extends State<ClientNote> {
  static const int _initialPage = 0;
  late PdfController _pdfController;
  late String filepath;
  late String initialName;
  late String initialDescription;
  bool isTemp = false;

  @override
  void initState() {
    super.initState();
    filepath = '';

    setState(() {
      isTemp = widget.clientEmail == '';
      initialName = widget.name;
      initialDescription = widget.description;
    });

    HFFirebaseFunctions()
        .getFirebaseAuthUser(context)
        .collection(isTemp ? 'tempClients' : COLLECTION_CLIENTS)
        .doc(isTemp ? widget.clientId : widget.clientEmail)
        .collection(COLLECTION_NOTES)
        .doc(widget.noteId)
        .get()
        .then((value) {
      setState(() {
        filepath = value['filepath'];
      });

      if (filepath != '') {
        _pdfController = PdfController(
          document: PdfDocument.openData(
            InternetFile.get(
              filepath,
            ),
          ),
          initialPage: _initialPage,
        );
      }
    });
  }

  @override
  void dispose() {
    if (filepath != '') {
      _pdfController.dispose();
    }
    super.dispose();
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
            text: 'Note',
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                showAlertDialog(
                  context,
                  'Are you sure you want to delete note?',
                  () {
                    HFFirebaseFunctions()
                        .getFirebaseAuthUser(context)
                        .collection(isTemp ? 'tempClients' : COLLECTION_CLIENTS)
                        .doc(isTemp ? widget.clientId : widget.clientEmail)
                        .collection(COLLECTION_NOTES)
                        .doc(widget.noteId)
                        .delete()
                        .then((value) {
                      Navigator.pop(context);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        text: 'Document removed!',
                        color: HFColors().primaryColor(opacity: 1),
                      ));
                    });
                  },
                  'Yes',
                  () {
                    Navigator.pop(context);
                  },
                  'No',
                );
              },
              icon: Icon(
                CupertinoIcons.trash,
                color: HFColors().redColor(),
              ),
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.pen),
              onPressed: () {
                _navigateToAddNote(context, setState, filepath);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HFHeading(
                text: initialName,
                size: 8,
              ),
              HFParagrpah(
                text: DateFormat('EEE, d/M/y')
                    .format(DateTime.parse(widget.date)),
                size: 6,
              ),
              const SizedBox(
                height: 20,
              ),
              if (filepath != '')
                SizedBox(
                  height: 400,
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
                height: 20,
              ),
              HFParagrpah(
                text: initialDescription,
                size: 10,
              ),
            ],
          ),
        ));
  }

  Future<void> _navigateToAddNote(BuildContext context, setState, path) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientAddNote(
          filepath: widget.filepath,
          clientEmail: widget.clientEmail,
          clientId: widget.clientId,
          noteId: widget.noteId,
          title: widget.name,
          description: widget.description,
          date: widget.date,
          isEdit: true,
        ),
      ),
    );

    if (!mounted) return;

    HFFirebaseFunctions()
        .getFirebaseAuthUser(context)
        .collection(isTemp ? 'tempClients' : COLLECTION_CLIENTS)
        .doc(isTemp ? widget.clientId : widget.clientEmail)
        .collection(COLLECTION_NOTES)
        .doc(widget.noteId)
        .get()
        .then((value) {
      if (filepath == value['filepath']) {
        return;
      }

      setState(() {
        filepath = value['filepath'];
        initialName = value['name'];
        initialDescription = value['description'];
      });

      if (path != '') {
        _pdfController.loadDocument(PdfDocument.openData(
          InternetFile.get(
            value['filepath'],
          ),
        ));
      } else {
        _pdfController = PdfController(
          document: PdfDocument.openData(
            InternetFile.get(
              value['filepath'],
            ),
          ),
          initialPage: _initialPage,
        );
      }
    });
  }
}

PhotoViewGalleryPageOptions pageBuilder(
  BuildContext context,
  Future<PdfPageImage> pageImage,
  int index,
  PdfDocument document,
) {
  return PhotoViewGalleryPageOptions(
    imageProvider: PdfPageImageProvider(
      pageImage,
      index,
      document.id,
    ),
    minScale: PhotoViewComputedScale.contained * 1,
    maxScale: PhotoViewComputedScale.contained * 2,
    initialScale: PhotoViewComputedScale.contained * 1.0,
    heroAttributes: PhotoViewHeroAttributes(tag: '${document.id}-$index'),
  );
}
