import 'package:get_it/get_it.dart';
import 'package:school_trip_track_driver/connection/all_apis.dart';
import 'package:school_trip_track_driver/utils/auth.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';

// Using GetIt is a convenient way to provide services and view models
// anywhere we need them in the app.
GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // data base
  //serviceLocator.registerLazySingleton<DAO>(() => DAO());

  // API
  serviceLocator.registerLazySingleton<AllApis>(() => AllApis());

  // view models
  serviceLocator.registerLazySingleton<ThisApplicationViewModel>(() =>
      ThisApplicationViewModel());

  serviceLocator.registerLazySingleton<Auth>(() => Auth());

}
