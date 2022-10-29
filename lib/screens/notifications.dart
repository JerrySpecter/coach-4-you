import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/utils/event.dart';
import 'package:health_factory/widgets/hf_appbar.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:health_factory/widgets/hf_snackbar.dart';
import '../constants/firebase_functions.dart';
import '../main.dart';
import '../widgets/hf_notification_tile.dart';

class Notifications extends StatefulWidget {
  Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    super.initState();

    HFFirebaseFunctions()
        .getFirebaseAuthUser(context)
        .update({'unreadNotifications': 0});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar('Notifications', []),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: HFFirebaseFunctions()
                      .getFirebaseAuthUser(context)
                      .collection('notifications')
                      .limit(30)
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: ((context, snapshot) {
                    if (!snapshot.hasData || snapshot.hasError) {
                      return const HFParagrpah(
                        text: 'No new notifications',
                        size: 8,
                      );
                    }

                    var data = snapshot.data as QuerySnapshot;

                    if (data.docs.isEmpty) {
                      if (!snapshot.hasData || snapshot.hasError) {
                        return const HFParagrpah(
                          text: 'No new notifications',
                          size: 8,
                        );
                      }
                    }

                    return Column(
                      children: [
                        ...data.docs.map((notification) {
                          return HFNotificationTile(
                            title: getNotificationHeading(notification),
                            imageUrl: notification['type'] == 'new-news'
                                ? notification['data']['imageUrl'] == ''
                                    ? notification['trainerImage']
                                    : notification['data']['imageUrl']
                                : notification['trainerImage'],
                            date: notification['date'],
                            isRead: notification['read'],
                            text: getNotificationText(notification),
                            onTap: () {
                              notification.reference.update({'read': true});
                              handleNotificationTap(context,
                                  notification['type'], notification['data']);
                            },
                          );
                        })
                      ],
                    );
                  })),
              const SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String getNotificationHeading(notification) {
  switch (notification['type']) {
    case 'new-workout':
      return 'New workout';
    case 'completed-workout':
      return 'Workout completed';
    case 'new-message':
      return '${notification['trainerName']}';
    case 'new-news':
      return 'New post';
    default:
      return '';
  }
}

String getNotificationText(notification) {
  switch (notification['type']) {
    case 'new-workout':
      return 'Coach ${notification['trainerName']} created a new workout for you. Click to see it.';
    case 'completed-workout':
      return '${notification['trainerName']} completed a workout. Click to see it.';
    case 'new-message':
      return '${notification['data']['message']}';
    case 'new-news':
      return '${notification['trainerName']} published a new post. Click to see it.';
    default:
      return '';
  }
}

void handleNotificationTap(context, type, data) {
  switch (type) {
    case 'new-workout':
    case 'completed-workout':
      HFFirebaseFunctions()
          .getFirebaseAuthUser(context)
          .collection('days')
          .doc(data['date'])
          .collection('events')
          .doc(data['id'])
          .get()
          .then((value) {
        var event = Event(
          title: value['title'],
          id: value['id'],
          date: DateTime.parse(value['date']),
          startTime: value['startTime'],
          endTime: value['endTime'],
          client: value['client'],
          color: value['color'],
          exercises: value['exercises'],
          location: value['location'],
          notes: value['notes'],
          isDone: value['isDone'],
        );

        navigatorKey.currentState?.pushNamed(eventRoute, arguments: event);
        // Navigator.pushNamed(context, eventRoute, arguments: event);
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
            text: 'Workout no longer available', color: HFColors().redColor()));
      }).catchError((onError) {
        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
            text: 'Workout no longer available', color: HFColors().redColor()));
      });

      break;
    case 'new-message':
      navigatorKey.currentState?.pushNamed(chatScreen, arguments: {
        'id': data['senderId'],
        'email': data['senderEmail'],
        'name': data['senderName'],
        'imageUrl': data['senderImageUrl']
      });
      // Navigator.pushNamed(context, chatScreen, arguments: {
      //   'id': data['senderId'],
      //   'email': data['senderEmail'],
      //   'name': data['senderName'],
      //   'imageUrl': data['senderImageUrl']
      // });
      break;
    case 'new-news':
      navigatorKey.currentState?.pushNamed(singleNewsRoute, arguments: {
        'title': data['title'],
        'excerpt': data['excerpt'],
        'date': data['date'],
        'imageUrl': data['imageUrl'],
        'id': data['id'],
      });
      // Navigator.pushNamed(context, singleNewsRoute, arguments: {
      //   'title': data['title'],
      //   'excerpt': data['excerpt'],
      //   'date': data['date'],
      //   'imageUrl': data['imageUrl'],
      //   'id': data['id'],
      // });
      break;
    default:
      return print('handleNotificationTap');
  }
}
