import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';
import 'package:health_factory/constants/collections.dart';
import 'package:health_factory/constants/firebase_functions.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/screens/client/client_add_meal_plan.dart';
import 'package:health_factory/widgets/hf_button.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import 'package:internet_file/internet_file.dart';

import '../../constants/routes.dart';
import '../../widgets/hf_dialog.dart';
import '../../widgets/hf_snackbar.dart';

class ClientMealPlan extends StatefulWidget {
  ClientMealPlan({super.key, required this.clientId});

  String clientId = '';

  @override
  State<ClientMealPlan> createState() => _ClientMealPlanState();
}

class _ClientMealPlanState extends State<ClientMealPlan> {
  static const int _initialPage = 0;
  late PdfController _pdfController;
  late String filepath;

  @override
  void initState() {
    super.initState();
    filepath = '';

    FirebaseFirestore.instance
        .collection(COLLECTION_CLIENTS)
        .doc(widget.clientId)
        .get()
        .then((value) {
      setState(() {
        filepath = value['mealPlanUrl'];
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
          text: 'Meal plan',
        ),
        actions: <Widget>[
          // IconButton(
          //   icon: const Icon(Icons.navigate_before),
          //   onPressed: () {
          //     _pdfController.previousPage(
          //       curve: Curves.ease,
          //       duration: const Duration(milliseconds: 100),
          //     );
          //   },
          // ),
          // PdfPageNumber(
          //   controller: _pdfController,
          //   builder: (_, loadingState, page, pagesCount) => Container(
          //     alignment: Alignment.center,
          //     child: Text(
          //       '$page/${pagesCount ?? 0}',
          //       style: const TextStyle(fontSize: 22),
          //     ),
          //   ),
          // ),
          // IconButton(
          //   icon: const Icon(Icons.navigate_next),
          //   onPressed: () {
          //     _pdfController.nextPage(
          //       curve: Curves.ease,
          //       duration: const Duration(milliseconds: 100),
          //     );
          //   },
          // ),
          if (context.read<HFGlobalState>().userAccessLevel ==
                  accessLevels.trainer &&
              filepath != '')
            IconButton(
              onPressed: () {
                showAlertDialog(
                  context,
                  'Are you sure you want to delete meal plan?',
                  () {
                    FirebaseFirestore.instance
                        .collection(COLLECTION_CLIENTS)
                        .doc(widget.clientId)
                        .update({'mealPlanUrl': ''}).then((value) {
                      Navigator.pop(context);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        text: 'Meal plan removed!',
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

          if (context.read<HFGlobalState>().userAccessLevel ==
                  accessLevels.trainer &&
              filepath != '')
            IconButton(
              icon: const Icon(CupertinoIcons.pen),
              onPressed: () {
                _navigateToAddMealPlan(context, setState, filepath);
              },
            ),
          if (filepath != '')
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _pdfController.loadDocument(PdfDocument.openData(
                  InternetFile.get(
                    filepath,
                  ),
                ));
              },
            ),
        ],
      ),
      body: filepath != ''
          ? PdfView(
              builders: PdfViewBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(),
                documentLoaderBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                pageLoaderBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                pageBuilder: pageBuilder,
                errorBuilder: (p0, error) {
                  return HFParagrpah(
                    text: 'Error. Please reload.',
                  );
                },
              ),
              controller: _pdfController,
            )
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HFHeading(
                    text: 'There is no meal plan yet.',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    'assets/meal-plan-icon.png',
                    width: MediaQuery.of(context).size.width * 0.3,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  if (context.read<HFGlobalState>().userAccessLevel ==
                      accessLevels.trainer)
                    HFButton(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      text: 'Add a meal plan',
                      onPressed: (() {
                        _navigateToAddMealPlan(context, setState, filepath);
                      }),
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _navigateToAddMealPlan(
      BuildContext context, setState, path) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientAddMealPlan(
          filepath: path,
          clientId: widget.clientId,
        ),
      ),
    );

    if (!mounted) return;

    FirebaseFirestore.instance
        .collection(COLLECTION_CLIENTS)
        .doc(widget.clientId)
        .get()
        .then((value) {
      if (filepath == value['mealPlanUrl']) {
        return;
      }

      setState(() {
        filepath = value['mealPlanUrl'];
      });

      if (path != '') {
        _pdfController.loadDocument(PdfDocument.openData(
          InternetFile.get(
            value['mealPlanUrl'],
          ),
        ));
      } else {
        _pdfController = PdfController(
          document: PdfDocument.openData(
            InternetFile.get(
              value['mealPlanUrl'],
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
