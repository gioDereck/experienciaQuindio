import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travel_hour/services/location_service.dart';

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> {
  StreamSubscription? gpsServiceSubscription;

  GpsBloc()
      : super(GpsState(isGpsEnabled: false, isGpsPermissionGranted: false)) {
    on<GpsAndPermissionEvent>((event, emit) => emit(state.copyWith(
        isGpsEnabled: event.isGpsEnabled,
        isGpsPermissionGranted: event.isGpsPermissionGranted)));

    _init();
  }

  Future<void> _init() async {
    final gpsInitStatus = await Future.wait([
      _checkGpsStatus(),
      _isPermissionGranted(),
    ]);

    add(GpsAndPermissionEvent(
      isGpsEnabled: gpsInitStatus[0],
      isGpsPermissionGranted: gpsInitStatus[1],
    ));
  }

  Future<bool> _isPermissionGranted() async {
    // Verificar permisos de ubicación
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        //print('44 Location permissions are denied');
        // Aquí puedes mostrar un diálogo o notificación al usuario
        return false; // Permiso denegado
      }
    }

    if (permission == LocationPermission.deniedForever) {
      //print('51 Location permissions are permanently denied');
      // Mostrar configuración para que el usuario habilite los permisos
      if (!kIsWeb) {
        openAppSettings(); // Abre la configuración de la aplicación
      }

      return false; // Permiso denegado permanentemente
    }

    // Si llegamos aquí, los permisos son concedidos
    getLocation(); // Llama a tu función para obtener la ubicación

    return true; // Permiso concedido y servicios habilitados
  }

  Future<bool> _checkGpsStatus() async {
    // Verificar si los servicios de ubicación están habilitados
    if (!await Geolocator.isLocationServiceEnabled()) {
      //print('69 Location services are disabled.');
      return false; // Los servicios de ubicación no están habilitados
    }

    // Desde movil se escuchan los cambios de la ubicación
    if (!kIsWeb) {
      gpsServiceSubscription =
          Geolocator.getServiceStatusStream().listen((event) {
        final isEnabled = (event.index == 1) ? true : false;
        //print('78 Service Status $isEnabled');
        add(GpsAndPermissionEvent(
            isGpsEnabled: isEnabled,
            isGpsPermissionGranted: state.isGpsPermissionGranted));
      });
    }

    return true;
  }

  Future<void> getLocation() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Position position =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);

    // Guardar la ubicación usando el servicio location
    await LocationService().saveLocation(position.latitude, position.longitude);
  }

  @override
  Future<void> close() {
    gpsServiceSubscription?.cancel();
    return super.close();
  }
}
