//Flutter
export 'dart:isolate';
export 'dart:async';
export 'package:flutter/material.dart';
export 'package:google_maps_flutter/google_maps_flutter.dart';
export 'package:geolocator/geolocator.dart';
export 'package:flutter_boxicons/flutter_boxicons.dart';
export 'package:share_plus/share_plus.dart';
export 'package:flutter/services.dart';
export 'package:app_settings/app_settings.dart';
//import 'package:http/http.dart' as http;
//export 'package:google_geocoding/google_geocoding.dart'; // Importa el paquete de geocodificación
//import 'package:provider/provider.dart';

//Firebase
export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'firebase_options.dart';
export 'package:firebase_core/firebase_core.dart';

//Core
export 'package:moonhike/core/constans/colors.dart';
export 'package:moonhike/core/utils/location_utils.dart';
export 'package:moonhike/core/widgets/address_search_widget.dart';
export 'package:moonhike/core/widgets/bottom_navigation_bar.dart';
export 'core/constans/api_keys.dart';

//Data
export 'package:moonhike/data/services/route_service.dart';
export 'package:moonhike/data/services/user_service.dart';
export 'package:moonhike/data/services/reports_service.dart';
export 'package:moonhike/data/services/directions_service.dart';
export 'package:moonhike/data/repositories/route_repository.dart';
export 'package:moonhike/data/models/reports.dart';
export 'package:moonhike/data/models/news_article.dart';
export 'package:moonhike/data/services/news_service.dart';

//Domain
export 'package:moonhike/domain/entities/route_entity.dart';
export 'package:moonhike/domain/use_cases/calculate_distance_use_case.dart';
export 'package:moonhike/domain/use_cases/get_routes_use_case.dart';
export 'package:moonhike/domain/use_cases/route_risk_calculator.dart';
export 'package:moonhike/domain/use_cases/delete_expired_reports.dart';
export 'package:moonhike/domain/use_cases/generate_automated_report.dart';

//Presentation
export 'package:moonhike/presentation/screens/map_screen.dart';
export 'package:moonhike/presentation/screens/login_screen.dart';
export 'package:moonhike/controllers/map_controller.dart';
export 'package:moonhike/presentation/screens/profile_screens/profile_screen.dart';
export 'package:moonhike/presentation/screens/profile_screens/account_config_screen.dart';
export 'package:moonhike/presentation/screens/profile_screens/invite_friend_screen.dart';
export 'package:moonhike/presentation/screens/profile_screens/privacy_screen.dart';
export 'package:moonhike/presentation/screens/register_screen.dart';
export 'package:moonhike/presentation/widgets/floating_action_buttons.dart';
export 'package:moonhike/presentation/widgets/map_widget.dart';
export 'package:moonhike/presentation/widgets/report_dialog.dart';
export 'package:moonhike/presentation/widgets/map_ui_service.dart';
export 'package:moonhike/presentation/widgets/route_info_tab.dart';
export 'package:moonhike/presentation/widgets/select_route.dart';
export 'package:moonhike/presentation/utils/map_utils.dart';
export 'package:moonhike/presentation/screens/reports_screen.dart';
export 'package:moonhike/presentation/screens/settings_screen.dart';
export 'package:moonhike/presentation/screens/initial_screen.dart';
export 'package:moonhike/presentation/widgets/find_location.dart';
export 'package:moonhike/presentation/screens/custom_screen.dart';









