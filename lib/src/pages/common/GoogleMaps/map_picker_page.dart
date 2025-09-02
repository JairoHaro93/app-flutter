import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _selected;
  static const LatLng _fallback = LatLng(-0.9306, -78.6155);

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is LatLng) _selected = args;
  }

  Future<void> _centerOnMyLocation() async {
    try {
      final service = await Geolocator.isLocationServiceEnabled();
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied)
        perm = await Geolocator.requestPermission();
      if (!service ||
          perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        Get.snackbar('Ubicación', 'Activa el GPS y concede permisos');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 5),
      );
      final me = LatLng(pos.latitude, pos.longitude);
      setState(() => _selected = me);
      final c = await _controller.future;
      await c.animateCamera(CameraUpdate.newLatLngZoom(me, 16));
    } catch (_) {
      Get.snackbar('Ubicación', 'No se pudo obtener tu ubicación');
    }
  }

  void _confirmar() => Get.back(result: _selected);

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      if (_selected != null)
        Marker(
          markerId: const MarkerId('seleccion'),
          position: _selected!,
          draggable: true,
          onDragEnd: (p) => setState(() => _selected = p),
        ),
    };
    final initialCamera = CameraPosition(
      target: _selected ?? _fallback,
      zoom: _selected != null ? 16 : 14,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnMyLocation,
          ),
          IconButton(icon: const Icon(Icons.check), onPressed: _confirmar),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: initialCamera,
        mapType: MapType.satellite, // 👈 satélite por defecto
        onMapCreated: (c) => _controller.complete(c),
        onTap: (p) => setState(() => _selected = p),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: true,
      ),
      bottomNavigationBar: Material(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            _selected == null
                ? 'Toca el mapa para elegir un punto'
                : 'Lat: ${_selected!.latitude.toStringAsFixed(6)}, '
                    'Lng: ${_selected!.longitude.toStringAsFixed(6)}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirmar,
        icon: const Icon(Icons.check),
        label: const Text('Usar estas coordenadas'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
