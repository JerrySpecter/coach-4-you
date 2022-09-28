import 'package:flutter/material.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/screens/admin/add_trainer.dart';
import 'package:health_factory/screens/admin/add_videos.dart';
import 'package:health_factory/screens/admin/admin.dart';
import 'package:health_factory/screens/admin/single_videos.dart';
import 'package:health_factory/screens/admin/trainers.dart';
import 'package:health_factory/screens/admin/videos.dart';
import 'package:health_factory/screens/client/client_arm.dart';
import 'package:health_factory/screens/client/client_profile.dart';
import 'package:health_factory/screens/client/client_shoulders.dart';
import 'package:health_factory/screens/client/client_thigh.dart';
import 'package:health_factory/screens/client/client_waist.dart';
import 'package:health_factory/screens/client/client_weight.dart';
import 'package:health_factory/screens/news/add_news.dart';
import 'package:health_factory/screens/events/single_event.dart';
import 'package:health_factory/screens/news/news.dart';
import 'package:health_factory/screens/requests/requests.dart';
import 'package:health_factory/screens/requests/single_request.dart';
import 'package:health_factory/screens/root.dart';
import 'package:health_factory/screens/news/single_news.dart';
import 'package:health_factory/screens/trainer_profile.dart';
import 'package:health_factory/screens/trainer_profile_logged_in.dart';
import 'package:health_factory/screens/trainings/single_trainings.dart';
import 'package:health_factory/screens/trainings/trainings.dart';
import 'package:health_factory/utils/event.dart';

import '../screens/admin/add_exercise.dart';
import '../screens/admin/add_location.dart';
import '../screens/admin/exercise.dart';
import '../screens/admin/locations.dart';
import '../screens/admin/single_exercise.dart';
import '../screens/client/client_add_measurement.dart';
import '../screens/client/client_chest.dart';
import '../screens/client/client_completed_trainings.dart';
import '../screens/clients/clients.dart';
import '../screens/clients/single_client.dart';
import '../screens/events/add_event.dart';
import '../screens/trainings/add_trainings.dart';

Route<dynamic>? genRoute(RouteSettings settings) {
  switch (settings.name) {
    case rootRoute:
      return MaterialPageRoute(builder: (_) => const RootPage());
    case eventRoute:
      var data = settings.arguments as Event;

      return MaterialPageRoute(
        builder: (_) => EventScreen(
          title: data.title,
          id: data.id,
          date: data.date,
          startTime: data.startTime,
          endTime: data.endTime,
          client: data.client,
          exercises: data.exercises,
          location: data.location,
          notes: data.notes,
          isDone: data.isDone,
        ),
      );
    case completedEventRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => EventScreen(
          title: data['title'],
          id: data['id'],
          date: DateTime.parse(data['date']),
          startTime: data['startTime'],
          endTime: data['endTime'],
          client: data['client'],
          exercises: data['exercises'],
          location: data['location'],
          notes: data['notes'],
          isDone: true,
        ),
      );
    case addEventRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => AddEventScreen(
          date: data['date'],
        ),
      );
    case addNewsRoute:
      return MaterialPageRoute(
        builder: (_) => const AddNewsScreen(),
      );
    case newsRoute:
      return MaterialPageRoute(
        builder: (_) => const NewsPage(),
      );
    case trainingsRoute:
      return MaterialPageRoute(
        builder: (_) => Trainings(),
      );
    case addTrainingRoute:
      return MaterialPageRoute(
        builder: (context) => AddTraining(
          parentContext: context,
        ),
      );
    case singleTrainingRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => SingleTraining(
          name: data['name'],
          id: data['id'],
          note: data['note'],
          exercises: data['exercises'],
        ),
      );
    case editTrainingRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (context) => AddTraining(
          parentContext: context,
          name: data['name'],
          id: data['id'],
          note: data['note'],
          exercises: data['exercises'],
          isEdit: data['isEdit'],
          isDuplicate: data['isDuplicate'],
        ),
      );
    case singleNewsRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => SingleNews(
            id: data['id'],
            title: data['title'],
            imageUrl: data['imageUrl'],
            content: data['excerpt'],
            date: data['date']),
      );
    // case addClientsRoute:
    //   return MaterialPageRoute(
    //     builder: (_) => const AddClientsScreen(),
    //   );
    case clientsRoute:
      return MaterialPageRoute(
        builder: (_) => const ClientsPage(),
      );
    case clientCompletedTrainingsRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => ClientsCompletedTrainings(
          id: data['id'],
        ),
      );
    case singleClientsRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => SingleClient(
            id: data['id'],
            name: data['name'],
            imageUrl: data['imageUrl'],
            email: data['email']),
      );
    case requestsRoute:
      return MaterialPageRoute(
        builder: (_) => const RequestsPage(),
      );
    case singleRequestRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => SingleRequest(
            name: data['name'],
            content: data['content'],
            email: data['email'],
            dateCreated: data['dateCreated']),
      );
    case trainerProfileRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => TrainerProfile(
          id: data['id'],
          name: data['name'],
          imageUrl: data['imageUrl'],
          email: data['email'],
          locations: data['locations'],
          birthday: data['birthday'],
          intro: data['intro'],
          available: data['available'],
          education: data['education'],
          profileBackgroundImageUrl: data['profileBackgroundImageUrl'],
        ),
      );
    case clientProfileRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => ClientProfile(
          id: data['id'],
          name: data['name'],
          imageUrl: data['imageUrl'],
          email: data['email'],
          weight: data['weight'],
          height: data['height'],
          profileBackgroundImageUrl: data['profileBackgroundImageUrl'],
          asTrainer: data['asTrainer'],
        ),
      );
    case trainerProfileLoggedInRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => TrainerProfileLoggedIn(
          id: data['id'],
          name: data['name'],
          imageUrl: data['imageUrl'],
          email: data['email'],
          locations: data['locations'],
          birthday: data['birthday'],
          intro: data['intro'],
          available: data['available'],
          education: data['education'],
          profileBackgroundImageUrl: data['profileBackgroundImageUrl'],
        ),
      );
    case adminRoute:
      return MaterialPageRoute(
        builder: (_) => const Admin(),
      );
    case adminTrainersRoute:
      return MaterialPageRoute(
        builder: (_) => const Trainers(),
      );
    case adminTrainersAddRoute:
      return MaterialPageRoute(
        builder: (_) => const AddTrainers(),
      );
    case adminLocationsRoute:
      return MaterialPageRoute(
        builder: (_) => const Locations(),
      );
    case adminLocationsAddRoute:
      return MaterialPageRoute(
        builder: (_) => const AddLocations(),
      );
    case adminVideosRoute:
      var data = settings.arguments as Map;
      return MaterialPageRoute(
        builder: (_) => Videos(isCoach: data['isCoach']),
      );
    case adminVideosAddRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (context) =>
            AddVideos(parentContext: context, isCoach: data['isCoach']),
      );
    case adminVideosSingle:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => SingleVideos(
          name: data['name'],
          thumbnail: data['thumbnail'],
          url: data['url'],
          description: data['description'],
          id: data['id'],
          author: data['author'],
        ),
      );
    case adminVideosEdit:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (context) => AddVideos(
          parentContext: context,
          name: data['name'],
          thumbnail: data['thumbnail'],
          url: data['url'],
          description: data['description'],
          id: data['id'],
          isEdit: true,
        ),
      );
    case adminExerciseRoute:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => Exercise(isCoach: data['isCoach']),
      );
    case adminExerciseAddRoute:
      var data = settings.arguments as Map;
      return MaterialPageRoute(
        builder: (context) =>
            AddExercise(parentContext: context, isCoach: data['isCoach']),
      );
    case adminExerciseSingle:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (_) => SingleExercise(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          note: data['note'],
          author: data['author'],
          video: data['video'],
          thumbnail: data['videoThumbnail'],
          types: data['types'],
          repetitionType: data['repetitionType'],
        ),
      );
    case adminExerciseEdit:
      var data = settings.arguments as Map;

      return MaterialPageRoute(
        builder: (context) => AddExercise(
          parentContext: context,
          id: data['id'],
          name: data['name'],
          description: data['description'],
          author: data['author'],
          video: data['video'],
          thumbnail: data['videoThumbnail'],
          types: data['types'],
          repetitionType: data['repetitionType'],
          isEdit: true,
        ),
      );
    case clientWeightRoute:
      return MaterialPageRoute(
        builder: (_) => ClientWeight(),
      );
    case clientAddWeightRoute:
      return MaterialPageRoute(
        builder: (_) => ClientAddMeasurement(
          collection: 'weight',
          hintText: 'Weight',
        ),
      );
    case clientChestRoute:
      return MaterialPageRoute(
        builder: (_) => ClientChest(),
      );
    case clientAddChestRoute:
      return MaterialPageRoute(
        builder: (_) => ClientAddMeasurement(
          collection: 'chest',
          hintText: 'Chest circumference',
        ),
      );
    case clientShouldersRoute:
      return MaterialPageRoute(
        builder: (_) => const ClientShoulders(),
      );
    case clientAddShouldersRoute:
      return MaterialPageRoute(
        builder: (_) => ClientAddMeasurement(
          collection: 'shoulders',
          hintText: 'Shoulders circumference',
        ),
      );
    case clientUpperArmRoute:
      return MaterialPageRoute(
        builder: (_) => ClientArm(),
      );
    case clientAddUpperArmRoute:
      return MaterialPageRoute(
        builder: (_) => ClientAddMeasurement(
          collection: 'arm',
          hintText: 'Upper arm circumference',
        ),
      );
    case clientWaistRoute:
      return MaterialPageRoute(
        builder: (_) => ClientWaist(),
      );
    case clientAddWaistRoute:
      return MaterialPageRoute(
        builder: (_) => ClientAddMeasurement(
          collection: 'waist',
          hintText: 'Waist circumference',
        ),
      );
    case clientMidThighRoute:
      return MaterialPageRoute(
        builder: (_) => ClientThigh(),
      );
    case clientAddMidThighRoute:
      return MaterialPageRoute(
        builder: (_) => ClientAddMeasurement(
          collection: 'thigh',
          hintText: 'Mid thigh circumference',
        ),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        ),
      );
  }
}
