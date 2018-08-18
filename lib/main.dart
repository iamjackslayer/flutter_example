import 'dart:async';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:geolocation/geolocation.dart' as geo;



void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Map View'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

const API_KEY = "AIzaSyCJXvgadNobevadeKKXvR-iqrCt87xmtpM";
class _MyHomePageState extends State<MyHomePage> {
  MapView mapView;
  StaticMapProvider staticMapProvider;
  Uri imageUri;
  geo.Location currentLocation;
  Location selectedLocation; // This Location is defined by map_view plugin.

  @override
  void initState() {
    super.initState();
    MapView.setApiKey(API_KEY);
    mapView = new MapView();

    staticMapProvider = new StaticMapProvider(API_KEY);
    imageUri = staticMapProvider.getStaticUri(Locations.portland, 14);

    _setCurrentLocation();
  }

  /// This method set selectedLocation to current location.
  Future<void> _setCurrentLocation() async {
    geo.Geolocation.currentLocation(accuracy: geo.LocationAccuracy.best).listen((result) {
      if (result.isSuccessful) {
        print("result is $result");
        setState(() {
          currentLocation = result.location;
        });

      }
    });
  }
  
  void _showMapView() {
    mapView.show(
        new MapOptions(
            mapViewType: MapViewType.normal,
            showUserLocation: true,
            initialCameraPosition: new CameraPosition(
              // if user hasn't selected a location, we show current location and vice versa.
              selectedLocation != null ?
                new Location(selectedLocation.latitude, selectedLocation.longitude)
              : new Location(currentLocation.latitude, currentLocation.longitude),
                14.0 // zoom level
            ),
            title: "Your location"),
        toolbarActions: [new ToolbarAction("Close", 1), new ToolbarAction("Confirm", 2)]);

    mapView.onMapReady.listen((Null _){
      if (selectedLocation != null) {
        mapView.setMarkers([new Marker("1", "selected",selectedLocation.latitude, selectedLocation.longitude)]);
      } else {
        mapView.setMarkers([new Marker("1", "selected",currentLocation.latitude, currentLocation.longitude)]);
      }
    });

    mapView.onMapTapped.listen((location) {
      print("tapped location is $location");
      mapView.setMarkers([new Marker("1", "selected",location.latitude, location.longitude)]);
      print(mapView.markers.length);
    });

    mapView.onToolbarAction.listen((id) {
      if (id == 1) {
        mapView.dismiss();
      } else if (id == 2) {
        print("len is: " + mapView.markers.length.toString());
        if (mapView.markers.isNotEmpty){
          setState(() {
            imageUri = staticMapProvider.getStaticUriWithMarkers(mapView.markers);
            selectedLocation = Location(mapView.markers[0].latitude, mapView.markers[0].longitude);
          });

          mapView.dismiss();
        }

      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: new Center(
                child: ClipRRect(
                  child: new Image.network(imageUri.toString()),
                  borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _showMapView,
        tooltip: 'show map',
        child: new Icon(Icons.map),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


}
