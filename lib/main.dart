/*
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as io;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize a new Firebase App instance
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Monit',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SharedPreferences prefs;
  FirebaseStorage storage = FirebaseStorage.instance;
  int mycount = 0;
  late Directory documentDirectory;
  String mypath = " ";
  var filelist;
  Map<String, String> map1 = {'13': 'YAHYA', '14': 'AHMED', '15': 'ADNAN'};
  Future<void> _upload(String inputSource) async {
    final picker = ImagePicker();
    XFile? pickedImage;
    final Directory _appDocDirFolder = Directory(
        '${documentDirectory.path}/images/');
    if (await _appDocDirFolder.exists()) {
    } else {
      await _appDocDirFolder.create(recursive: true);
    }
    // try {
    pickedImage = await picker.pickImage(
        source: inputSource == 'camera'
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1920);

    // final String fileName = path.basename(pickedImage!.path);
    String fileName = "$mycount";
    File imageFile = File(pickedImage!.path);
    await imageFile.copy('$mypath/images/$fileName.jpg');
    mycount++;
    await prefs.setInt('counter', mycount);
    downloadData();
    setState(() {

    });
    // try {
    //     // Uploading the selected image with some custom meta data
    //     await storage.ref(fileName).putFile(
    //         imageFile,
    //         SettableMetadata(customMetadata: {
    //           'uploaded_by': 'Monit',
    //           'description': 'Face Recognition'
    //         }));
    //
    //     // Refresh the UI
    //     setState(() {});
    //   } on FirebaseException catch (error) {
    //     if (kDebugMode) {
    //       print(error);
    //     }
    //   }
    // } catch (err) {
    //   if (kDebugMode) {
    //     print(err);
    //   }
    // }
  }

  // Retriew the uploaded images
  // This function is called when the app launches for the first time or when an image is uploaded or deleted
  // Future<List<Map<String, dynamic>>> _loadImages() async {
  //   List<Map<String, dynamic>> files = [];
  //
  //   final ListResult result = await storage.ref().list();
  //   final List<Reference> allFiles = result.items;
  //
  //   await Future.forEach<Reference>(allFiles, (file) async {
  //     final String fileUrl = await file.getDownloadURL();
  //     final FullMetadata fileMeta = await file.getMetadata();
  //     files.add({
  //       "url": fileUrl,
  //       "path": file.fullPath,
  //       "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
  //       "description":
  //       fileMeta.customMetadata?['description'] ?? 'No description'
  //     });
  //   });
  //
  //   return files;
  // }
  //  _loadImages(){
  //   return file;
  // }

  // Delete the selected image
  // This function is called when a trash icon is pressed
  Future<void> _delete(String ref) async {
    await storage.ref(ref).delete();
    // Rebuild the UI
    setState(() {});
  }

  Future<void> myinitials() async {
    prefs = await SharedPreferences.getInstance();
    documentDirectory = await getApplicationDocumentsDirectory();
    mypath = documentDirectory.path;
    downloadData();
    final int? counter = prefs.getInt('counter');
    if (counter != null) {
      mycount = counter;
    }
  }

  Future<List> downloadData() async {
    filelist = io.Directory("$mypath/images/")
        .listSync(); //use your folder name insted of resume.
    for (File s in filelist){
      print(s.path);

    }

    return filelist;
  }

  @override
  void initState() {
    myinitials();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.query_stats_sharp)),
              Tab(icon: Icon(Icons.electric_bolt_sharp)),

            ],
          ),
          title: const Text('Monit'),
        ),
        body: TabBarView(
            children: [
              Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                            onPressed: () => _upload('camera'),
                            icon: const Icon(Icons.camera),
                            label: const Text('camera')),
                        ElevatedButton.icon(
                            onPressed: () => _upload('gallery'),
                            icon: const Icon(Icons.library_add),
                            label: const Text('Gallery')),
                      ],
                    ),
                    FutureBuilder<List>(
                      future: downloadData(), // function where you call your api
                      builder: (BuildContext context, AsyncSnapshot<
                          List> snapshot) { // AsyncSnapshot<Your object type>
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: Text('Please wait its loading...'));
                        } else {
                          if (snapshot.hasError)
                            return Center(child: Text('Error: Loading'));
                          else {
                            return Center(child:
                            Container(
                              padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
                              height: 1000,
                              width: 1000,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    for (File s in filelist)...[
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blueAccent,width: 2)
                                        ),
                                        height: 800,
                                        width: 500,
                                        padding: EdgeInsets.all(5),
                                        child: Column(
                                          children: [
                                            Image.file(File((s.path))),
                                            Row(
                                              children: [
                                                Text(path.basename(s.path)),
                                                IconButton(onPressed: () async {
                                                  await File(s.path).delete();
                                                  downloadData();
                                                  setState(() {

                                                  });
                                                }, icon: Icon(Icons.delete_forever))
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                              ),
                            ),
                            );
                            // ); // snapshot.data  :- get your object which is pass from your downloadData() function
                          }
                        }
                      },
                    )
                  ],
                ),
              ),
              Container(
                child: Text("Hello"),

              )
            ],
        ),
      ),
    );
  }
 }

*/

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import './ChatPage.dart';
import './SelectBondedDevicePage.dart';
void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request().then((status) {
      runApp(ExampleApplication());
    });


  // Initialize a new Firebase App instance
  // await Firebase.initializeApp();
}

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainPage());
  }
}
class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  String _address = "...";
  String _name = "...";


  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;
  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state


    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Bluetooth Serial'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: ElevatedButton(
                child: const Text('Connect to paired device to chat'),
                onPressed: () async {
                  final BluetoothDevice? selectedDevice =
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SelectBondedDevicePage(checkAvailability: false);
                      },
                    ),
                  );

                  if (selectedDevice != null) {
                    print('Connect -> selected ' + selectedDevice.address);
                    _startChat(context, selectedDevice);
                  } else {
                    print('Connect -> no device selected');
                  }
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }
}


// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// import 'dart:async';
// import 'dart:io';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import 'widgets.dart';
//
// void main() {
//
//   if (Platform.isAndroid) {
//     WidgetsFlutterBinding.ensureInitialized();
//     [
//       Permission.location,
//       Permission.storage,
//       Permission.bluetooth,
//       Permission.bluetoothConnect,
//       Permission.bluetoothScan
//     ].request().then((status) {
//       runApp(const FlutterBlueApp());
//     });
//   } else {
//     runApp(const FlutterBlueApp());
//   }
// }
//
// class FlutterBlueApp extends StatelessWidget {
//   const FlutterBlueApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       color: Colors.lightBlue,
//       home: StreamBuilder<BluetoothState>(
//           stream: FlutterBluePlus.instance.state,
//           initialData: BluetoothState.unknown,
//           builder: (c, snapshot) {
//             final state = snapshot.data;
//             if (state == BluetoothState.on) {
//               return const FindDevicesScreen();
//             }
//             return BluetoothOffScreen(state: state);
//           }),
//     );
//   }
// }
//
// class BluetoothOffScreen extends StatelessWidget {
//   const BluetoothOffScreen({Key? key, this.state}) : super(key: key);
//
//   final BluetoothState? state;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.lightBlue,
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             const Icon(
//               Icons.bluetooth_disabled,
//               size: 200.0,
//               color: Colors.white54,
//             ),
//             Text(
//               'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
//               style: Theme.of(context)
//                   .primaryTextTheme
//                   .subtitle2
//                   ?.copyWith(color: Colors.white),
//             ),
//             ElevatedButton(
//               child: const Text('TURN ON'),
//               onPressed: Platform.isAndroid
//                   ? () => FlutterBluePlus.instance.turnOn()
//                   : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class FindDevicesScreen extends StatelessWidget {
//   const FindDevicesScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Find Devices'),
//         actions: [
//           ElevatedButton(
//             child: const Text('TURN OFF'),
//             style: ElevatedButton.styleFrom(
//               primary: Colors.black,
//               onPrimary: Colors.white,
//             ),
//             onPressed: Platform.isAndroid
//                 ? () => FlutterBluePlus.instance.turnOff()
//                 : null,
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () => FlutterBluePlus.instance
//             .startScan(timeout: const Duration(seconds: 4)),
//         child: SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//               StreamBuilder<List<BluetoothDevice>>(
//                 stream: Stream.periodic(const Duration(seconds: 2))
//                     .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
//                 initialData: const [],
//                 builder: (c, snapshot) => Column(
//                   children: snapshot.data!
//                       .map((d) => ListTile(
//                     title: Text(d.name),
//                     subtitle: Text(d.id.toString()),
//                     trailing: StreamBuilder<BluetoothDeviceState>(
//                       stream: d.state,
//                       initialData: BluetoothDeviceState.disconnected,
//                       builder: (c, snapshot) {
//                         if (snapshot.data ==
//                             BluetoothDeviceState.connected) {
//                           return ElevatedButton(
//                             child: const Text('OPEN'),
//                             onPressed: () => Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         DeviceScreen(device: d))),
//                           );
//                         }
//                         return Text(snapshot.data.toString());
//                       },
//                     ),
//                   ))
//                       .toList(),
//                 ),
//               ),
//               StreamBuilder<List<ScanResult>>(
//                 stream: FlutterBluePlus.instance.scanResults,
//                 initialData: const [],
//                 builder: (c, snapshot) => Column(
//                   children: snapshot.data!
//                       .map(
//                         (r) => ScanResultTile(
//                       result: r,
//                       onTap: () => Navigator.of(context)
//                           .push(MaterialPageRoute(builder: (context) {
//                         r.device.connect();
//                         return DeviceScreen(device: r.device);
//                       })),
//                     ),
//                   )
//                       .toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: StreamBuilder<bool>(
//         stream: FlutterBluePlus.instance.isScanning,
//         initialData: false,
//         builder: (c, snapshot) {
//           if (snapshot.data!) {
//             return FloatingActionButton(
//               child: const Icon(Icons.stop),
//               onPressed: () => FlutterBluePlus.instance.stopScan(),
//               backgroundColor: Colors.red,
//             );
//           } else {
//             return FloatingActionButton(
//                 child: const Icon(Icons.search),
//                 onPressed: () => FlutterBluePlus.instance
//                     .startScan(timeout: const Duration(seconds: 4)));
//           }
//         },
//       ),
//     );
//   }
// }
//
// class DeviceScreen extends StatelessWidget {
//   const DeviceScreen({Key? key, required this.device}) : super(key: key);
//
//   final BluetoothDevice device;
//
//   List<int> _getRandomBytes() {
//     final math = Random();
//     return [
//       math.nextInt(255),
//       math.nextInt(255),
//       math.nextInt(255),
//       math.nextInt(255)
//     ];
//   }
//
//   List<Widget> _buildServiceTiles(List<BluetoothService> services) {
//     return services
//         .map(
//           (s) => ServiceTile(
//         service: s,
//         characteristicTiles: s.characteristics
//             .map(
//               (c) => CharacteristicTile(
//             characteristic: c,
//             onReadPressed: () => c.read(),
//             onWritePressed: () async {
//               await c.write(_getRandomBytes(), withoutResponse: true);
//               await c.read();
//             },
//             onNotificationPressed: () async {
//               await c.setNotifyValue(!c.isNotifying);
//               await c.read();
//             },
//             descriptorTiles: c.descriptors
//                 .map(
//                   (d) => DescriptorTile(
//                 descriptor: d,
//                 onReadPressed: () => d.read(),
//                 onWritePressed: () => d.write(_getRandomBytes()),
//               ),
//             )
//                 .toList(),
//           ),
//         )
//             .toList(),
//       ),
//     )
//         .toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(device.name),
//         actions: <Widget>[
//           StreamBuilder<BluetoothDeviceState>(
//             stream: device.state,
//             initialData: BluetoothDeviceState.connecting,
//             builder: (c, snapshot) {
//               VoidCallback? onPressed;
//               String text;
//               switch (snapshot.data) {
//                 case BluetoothDeviceState.connected:
//                   onPressed = () => device.disconnect();
//                   text = 'DISCONNECT';
//                   break;
//                 case BluetoothDeviceState.disconnected:
//                   onPressed = () => device.connect();
//                   text = 'CONNECT';
//                   break;
//                 default:
//                   onPressed = null;
//                   text = snapshot.data.toString().substring(21).toUpperCase();
//                   break;
//               }
//               return TextButton(
//                   onPressed: onPressed,
//                   child: Text(
//                     text,
//                     style: Theme.of(context)
//                         .primaryTextTheme
//                         .button
//                         ?.copyWith(color: Colors.white),
//                   ));
//             },
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             StreamBuilder<BluetoothDeviceState>(
//               stream: device.state,
//               initialData: BluetoothDeviceState.connecting,
//               builder: (c, snapshot) => ListTile(
//                 leading: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     snapshot.data == BluetoothDeviceState.connected
//                         ? const Icon(Icons.bluetooth_connected)
//                         : const Icon(Icons.bluetooth_disabled),
//                     snapshot.data == BluetoothDeviceState.connected
//                         ? StreamBuilder<int>(
//                         stream: rssiStream(),
//                         builder: (context, snapshot) {
//                           return Text(snapshot.hasData ? '${snapshot.data}dBm' : '',
//                               style: Theme.of(context).textTheme.caption);
//                         })
//                         : Text('', style: Theme.of(context).textTheme.caption),
//                   ],
//                 ),
//                 title: Text(
//                     'Device is ${snapshot.data.toString().split('.')[1]}.'),
//                 subtitle: Text('${device.id}'),
//                 trailing: StreamBuilder<bool>(
//                   stream: device.isDiscoveringServices,
//                   initialData: false,
//                   builder: (c, snapshot) => IndexedStack(
//                     index: snapshot.data! ? 1 : 0,
//                     children: <Widget>[
//                       IconButton(
//                         icon: const Icon(Icons.refresh),
//                         onPressed: () => device.discoverServices(),
//                       ),
//                       const IconButton(
//                         icon: SizedBox(
//                           child: CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation(Colors.grey),
//                           ),
//                           width: 18.0,
//                           height: 18.0,
//                         ),
//                         onPressed: null,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             StreamBuilder<int>(
//               stream: device.mtu,
//               initialData: 0,
//               builder: (c, snapshot) => ListTile(
//                 title: const Text('MTU Size'),
//                 subtitle: Text('${snapshot.data} bytes'),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.edit),
//                   onPressed: () => device.requestMtu(223),
//                 ),
//               ),
//             ),
//             StreamBuilder<List<BluetoothService>>(
//               stream: device.services,
//               initialData: const [],
//               builder: (c, snapshot) {
//                 return Column(
//                   children: _buildServiceTiles(snapshot.data!),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Stream<int> rssiStream() async* {
//     var isConnected = true;
//     final subscription = device.state.listen((state) {
//       isConnected = state == BluetoothDeviceState.connected;
//     });
//     while (isConnected) {
//       yield await device.readRssi();
//       await Future.delayed(const Duration(seconds: 1));
//     }
//     subscription.cancel();
//     // Device disconnected, stopping RSSI stream
//   }
// }
