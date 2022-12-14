import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:health_factory/screens/root.dart';
import 'package:provider/provider.dart';
import '../utils/event.dart';
import 'global_state.dart';

class HFFirebaseFunctions {
  updateUserChangedDate(BuildContext context) {
    var newDate = DateTime.now();
    FirebaseFirestore.instance
        .collection('trainers')
        .doc(context.read<HFGlobalState>().userId)
        .update({
      'changed': '$newDate',
    }).then((value) {
      context.read<HFGlobalState>().setCalendarLastUpdated('$newDate');
    }).catchError((error) => print('Update user failed: $error'));
  }

  DocumentReference<Map<String, dynamic>> getFirebaseAuthUser(
      BuildContext context) {
    var collectionName = 'trainers';

    if (context.read<HFGlobalState>().userAccessLevel == accessLevels.client) {
      collectionName = 'clients';
    }

    return FirebaseFirestore.instance
        .collection(collectionName)
        .doc(FirebaseAuth.instance.currentUser?.uid);
  }

  DocumentReference<Map<String, dynamic>> getTrainersUser([String id = '']) {
    var collectionName = 'trainers';
    var userId = id != '' ? id : FirebaseAuth.instance.currentUser?.uid;

    return FirebaseFirestore.instance.collection(collectionName).doc(userId);
  }

  DocumentReference<Map<String, dynamic>> getClientsUser(id) {
    var collectionName = 'clients';
    var userId = id;

    return FirebaseFirestore.instance.collection(collectionName).doc(userId);
  }

  getUserDays(BuildContext context) {
    FirebaseFirestore.instance
        .collection('trainers')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('days')
        .get()
        .then((value) {
      var data = value.docs;

      var newMap = <DateTime, List<Event>>{};

      var count = 0;
      data.asMap().forEach((index, day) {
        FirebaseFirestore.instance
            .collection('trainers')
            .doc(FirebaseAuth.instance.currentUser?.email)
            .collection('days')
            .doc('${day.id}')
            .collection('events')
            .orderBy('startTime')
            .get()
            .then(
          (value) {
            List<Event> events = [];

            value.docs.forEach((event) {
              var query = event;

              events.add(Event(
                title: query['title'],
                id: query['id'],
                startTime: query['startTime'],
                endTime: query['endTime'],
                date: DateTime.parse(query['date']),
                client: query['client'],
                color: query['color'],
                exercises: query['exercises'],
                location: query['location'],
                notes: query['notes'],
                isDone: query['isDone'],
              ));
            });

            newMap[DateTime.parse(day.id)] = events;

            if (data.length == count + 1) {}
          },
        ).then((value) => count++);
      });
    });
  }

  initClientData(userId, BuildContext context) {
    FirebaseFirestore.instance
        .collection('clients')
        .doc(userId)
        .get()
        .then((client) async {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      client.reference.update({'notificationToken': fcmToken});
      context.read<HFGlobalState>().setUserFirstName(client['firstName']);
      context.read<HFGlobalState>().setUserLastName(client['lastName']);
      context.read<HFGlobalState>().setUserImage(client['imageUrl']);
      context
          .read<HFGlobalState>()
          .setUserBackgroundImage(client['profileBackgroundImageUrl']);
      context.read<HFGlobalState>().setUserHeight(client['height']);

      context.read<HFGlobalState>().setUserEmail(client['email']);
      context.read<HFGlobalState>().setUserName(client['name']);
      context.read<HFGlobalState>().setUserId(userId);
      context.read<HFGlobalState>().setUserTrainerId(client['trainerId']);
      context.read<HFGlobalState>().setUserNewAccount(client['newAccount']);

      HFFirebaseFunctions().getFirebaseAuthUser(context).snapshots().listen(
            ((event) => fetchCalendarEvents(context, event)),
            onError: (error) => print("Listen failed: $error"),
          );
    }).then((value) {
      if (context.read<HFGlobalState>().userNewAccount &&
          context.read<HFGlobalState>().rootScreenState !=
              RootScreens.welcome) {
        context.read<HFGlobalState>().setUserFirstName(
            context.read<HFGlobalState>().userName.split(' ')[0]);
        context.read<HFGlobalState>().setRootScreenState(RootScreens.welcome);
      } else {
        if (context.read<HFGlobalState>().rootScreenState !=
            RootScreens.welcome) {
          context.read<HFGlobalState>().setRootScreenState(RootScreens.home);
        }
      }
    }).catchError((error) => print(error));
  }

  initTrainerData(userId, BuildContext context) {
    FirebaseFirestore.instance
        .collection('trainers')
        .doc(userId)
        .get()
        .then((trainer) async {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      trainer.reference.update({'notificationToken': fcmToken});

      context.read<HFGlobalState>().setUserAvailable(trainer['available']);
      context.read<HFGlobalState>().setUserBirthday(trainer['birthday']);
      context.read<HFGlobalState>().setUserEducation(trainer['education']);
      context.read<HFGlobalState>().setUserEmail(trainer['email']);
      context.read<HFGlobalState>().setUserFirstName(trainer['firstName']);
      context.read<HFGlobalState>().setUserId(trainer['id']);
      context.read<HFGlobalState>().setUserImage(trainer['imageUrl']);
      context.read<HFGlobalState>().setUserIntro(trainer['intro']);
      context.read<HFGlobalState>().setUserIsAdmin(trainer['isAdmin']);
      context.read<HFGlobalState>().setUserLastName(trainer['lastName']);
      context.read<HFGlobalState>().setUserLocations(trainer['locations']);
      context.read<HFGlobalState>().setUserDisplayName(trainer['name']);
      context.read<HFGlobalState>().setUserNewAccount(trainer['newAccount']);
      context
          .read<HFGlobalState>()
          .setUserBackgroundImage(trainer['profileBackgroundImageUrl']);

      context.read<HFGlobalState>().setUserName(trainer['name']);

      HFFirebaseFunctions().getFirebaseAuthUser(context).snapshots().listen(
            ((event) => fetchCalendarEvents(context, event)),
            onError: (error) => print("Listen failed: $error"),
          );
    }).then((value) {
      if (context.read<HFGlobalState>().userNewAccount &&
          context.read<HFGlobalState>().rootScreenState !=
              RootScreens.welcome) {
        context.read<HFGlobalState>().setRootScreenState(RootScreens.welcome);
      } else {
        if (context.read<HFGlobalState>().rootScreenState !=
            RootScreens.welcome) {
          context.read<HFGlobalState>().setRootScreenState(RootScreens.home);
        }
      }
    }).catchError((error) => print(error));
  }

  addTrainerFields(context, Map<String, dynamic> fields) {
    FirebaseFirestore.instance
        .collection('trainers')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((trainer) {
        trainer.reference.update(fields);
      });
    });
  }

  addClientFields(context, Map<String, dynamic> fields) {
    FirebaseFirestore.instance
        .collection('clients')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((client) {
        client.reference.update(fields);
      });
    }).onError((error, stackTrace) {
      print(error);
    }).catchError((onError) {
      print(onError);
    });
  }
}
