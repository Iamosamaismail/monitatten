import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as io;

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  var tList = List.generate(100, (i) => List.filled(5, "", growable: true),
      growable: true);

  // List<String> attendance = ['13', '14', '15', '16'];
  List<String> attendance = ['0', '1', '2', '3'];

  // List<String> attendance = [];
  bool isValid = true;
  static final clientID = 0;
  BluetoothConnection? connection;
  List<int> buffer = [];
  int last = 0;
  int latest = 0;
  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';
  bool isConnecting = true;

  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;

  // late final SharedPreferences prefs;
  // FirebaseStorage storage = FirebaseStorage.instance;
  int mycount = 0;
  late Directory documentDirectory;
  String mypath = " ";
  var filelist;
  Map<String, String> map1 = {'13': 'YAHYA', '14': 'AHMED', '15': 'ADNAN'};

  Future<void> _upload(String inputSource) async {
    final picker = ImagePicker();
    XFile? pickedImage;
    final Directory _appDocDirFolder =
        Directory('${documentDirectory.path}/images/');
    if (await _appDocDirFolder.exists()) {
    } else {
      await _appDocDirFolder.create(recursive: true);
    }
    // try {
    pickedImage = await picker.pickImage(
        source:
            inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920);

    // final String fileName = path.basename(pickedImage!.path);
    String fileName = "$mycount";
    File imageFile = File(pickedImage!.path);
    await imageFile.copy('$mypath/images/$fileName.jpg');
    mycount++;
    // await prefs.setInt('counter', mycount);
    downloadData();
    setState(() {});
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
    // await storage.ref(ref).delete();
    setState(() {});
  }

  Future<void> myinitials() async {
    tList[0][0] = "YAHYA";
    tList[0][1] = "ND";
    tList[1][0] = "AHMED";
    tList[1][1] = "ND";
    tList[2][0] = "ADNAN";
    tList[2][1] = "ND";
    tList[3][0] = "NONE";
    tList[3][1] = "ND";
    tList[0][2] = "JAFFERI";
    tList[1][2] = "ZAHEER";
    tList[2][2] = "ISMAIL";

    // tList[15][2] = "ASIF";
    // tList[16][2] = "NONE";
    // tList[17][2] = "NONE";
    // tList[13][0] = "YAHYA";
    // tList[13][1] = "ND";
    // tList[14][0] = "AHMED";
    // tList[14][1] = "ND";
    // tList[15][0] = "ADNAN";
    // tList[15][1] = "ND";
    // tList[16][0] = "NONE";
    // tList[16][1] = "ND";
    // tList[13][2] = "JAFFERI";
    // tList[14][2] = "ZAHEER";
    // tList[15][2] = "ASIF";
    // tList[16][2] = "NONE";
    // tList[17][2] = "NONE";
    // prefs = await SharedPreferences.getInstance();
    documentDirectory = await getApplicationDocumentsDirectory();
    mypath = documentDirectory.path;
    downloadData();
    // final int? counter = prefs.getInt('counter');
    // if (counter != null) {
    //   mycount = counter;
    // }
  }

  Future<List> downloadData() async {
    filelist = io.Directory("$mypath/images/")
        .listSync(); //use your folder name insted of resume.
    for (File s in filelist) {
      print(s.path);
    }

    return filelist;
  }

  @override
  void initState() {
    super.initState();
    myinitials();
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverName = widget.server.name ?? "Unknown";
    print(tList[13][0]);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: (isConnecting
              ? Text('Connecting chat to ' + serverName + '...')
              : isConnected
                  ? Text('Live chat with ' + serverName)
                  : Text('Chat log with ' + serverName)),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.query_stats_sharp)),
              Tab(icon: Icon(Icons.electric_bolt_sharp)),
            ],
          ),
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
                    builder:
                        (BuildContext context, AsyncSnapshot<List> snapshot) {
                      // AsyncSnapshot<Your object type>
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: Text('Please wait its loading...'));
                      } else {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error: Loading'));
                        } else {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
                              height: 1000,
                              width: 1000,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    for (File s in filelist) ...[
                                      Container(
                                        height: 300,
                                        padding: const EdgeInsets.only(
                                            top: 30, right: 20, left: 20),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.94,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          color: Colors.white70,
                                          elevation: 10,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.30,
                                                      maxHeight:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.35,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                      child: Image.file(
                                                          File((s.path))),
                                                    ),
                                                  )),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.35,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 10, 0, 0),
                                                      child: Text(
                                                        tList[int.parse(path
                                                            .basename(s.path)
                                                            .substring(
                                                                0,
                                                                path
                                                                        .basename(
                                                                            s.path)
                                                                        .length -
                                                                    4))][0],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.35,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          5, 10, 0, 0),
                                                      child: Text(
                                                        'ss',
                                                        // tList[int.parse(x.substring(0,x.length - 4))][1] = "VERIFIED";

                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Transform.scale(
                                                        scale: 2,
                                                        child: Switch(
                                                          onChanged: (value) {
                                                            String x =
                                                                path.basename(
                                                                    s.path);
                                                            print(x.substring(0,
                                                                x.length - 4));

                                                            setState(() {
                                                              if (value) {
                                                                tList[int.parse(x.substring(
                                                                        0,
                                                                        x.length -
                                                                            4))]
                                                                    [
                                                                    1] = "VERIFIED";
                                                              } else {
                                                                tList[int.parse(x.substring(
                                                                        0,
                                                                        x.length -
                                                                            4))][1] =
                                                                    "DEFAULTER";
                                                              }
                                                            });
                                                            // setState(() => isValid = value);
                                                          },
                                                          value: tList[int.parse(path
                                                                      .basename(s
                                                                          .path)
                                                                      .substring(
                                                                          0,
                                                                          path.basename(s.path).length -
                                                                              4))][1] ==
                                                                  "VERIFIED"
                                                              ? true
                                                              : false,
                                                          activeColor:
                                                              Colors.green,
                                                          activeTrackColor:
                                                              Colors
                                                                  .greenAccent,
                                                          inactiveThumbColor:
                                                              Colors.red,
                                                          inactiveTrackColor:
                                                              Colors.redAccent,
                                                        )),
                                                    tList[int.parse(path
                                                                .basename(
                                                                    s.path)
                                                                .substring(
                                                                    0,
                                                                    path.basename(s.path).length -
                                                                        4))][1] ==
                                                            "VERIFIED"
                                                        ? Text(
                                                            'VERIFIED',
                                                            style: TextStyle(
                                                                fontSize: 20),
                                                          )
                                                        : Text(
                                                            'DEFAULTER',
                                                            style: TextStyle(
                                                                fontSize: 20),
                                                          )
                                                  ]),
                                            ],
                                          ),
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  )
                ],
              ),
            ),
            SizedBox(
              width: 500,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: attendance.length,
                  itemBuilder: (BuildContext context, int index) {
                    return UnconstrainedBox(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        color: Colors.white70,
                        elevation: 10,
                        child: Stack(
                            children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 190,
                                width: 500,
                              ),
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(20)),
                                ),
                                color: Colors.red,
                                child: Text(
                                  "${tList[int.parse(attendance[index])][1]}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.30,
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.175,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Image.file(File(
                                          ('/data/user/0/com.example.untitled2/app_flutter/images/${attendance[index]}.jpg'))),
                                    ),
                                  )),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.25,
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(10, 10, 0, 0),
                                          child: Text(
                                            "Student ID:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.2,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 0, 0),
                                          child: Text(
                                            "${attendance[index]}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.25,
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(10, 10, 0, 0),
                                          child: Text(
                                            "Student Name:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.2,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 0, 0),
                                          child: Text(
                                            "${tList[int.parse(attendance[index])][0]}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.25,
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(10, 10, 0, 0),
                                          child: Text(
                                            "Father/Guardian:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.2,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 0, 0),
                                          child: Text(
                                            "${tList[int.parse(attendance[index])][2]}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.25,
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(10, 10, 0, 0),
                                          child: Text(
                                            "Class:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.2,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 0, 0),
                                          child: Text(
                                            "5A",
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Column(
                              //   children: <Widget>[
                              //     Padding(
                              //       padding: const EdgeInsets.fromLTRB(5, 40, 0, 0),
                              //       child: Text(
                              //         '\$ 24.00',
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ]),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    print(data);
    data.forEach((byte) {
      if (byte == 10) {
        _messageBuffer = utf8.decode(buffer);
        latest = int.parse(_messageBuffer);
        if (latest != last) {
          attendance.insert(0, _messageBuffer);
          if (attendance.length > 10) {
            attendance.removeAt(attendance.length - 1);
          }
          last = latest;
        }
        print(_messageBuffer);
        buffer.clear();
        setState(() {});
      } else {
        buffer.add(byte);
      }
    });
  }
}
