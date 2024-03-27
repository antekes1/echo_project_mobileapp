import 'dart:ffi';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:echo/screens/storages/storage_settings.dart';
import 'package:echo/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../utils/myGlobals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:echo/utils/routes.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/CustomFABRow.dart';
import '../../utils/convertions_funtions.dart';
import '../../utils/api//notifications_api.dart';

class StoragePage extends StatefulWidget {
  final int storageId;

  // StoragePage({required this.storageId});
  StoragePage({Key? key, required this.storageId}) : super(key: key);

  @override
  State<StoragePage> createState() => _CreateStoragesPageState();
}

class _CreateStoragesPageState extends State<StoragePage> {
  String atoken = globals.token;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String username = globals.username;
  final server_ip = globals.server_ip;

  String name_storage = "";
  int max_size = 0;
  int actual_size = 0;
  String owner_name = "";

  bool changeButton = false;
  bool isClicked = false;

  String actualPath = "/";
  List actualFiles = [];

  Get_data(BuildContext context) async {
    Map data = {'token': globals.token, 'storage_id': widget.storageId};
    var body = json.encode(data);
    var response = await http.post(
        Uri.parse(server_ip +
            '/storage/info'), // Tutaj przekształcamy ciąg znaków na Uri
        headers: {"Content-Type": "application/json"},
        body: body);

    if (response.statusCode == 200) {
      // Odpowiedź jest poprawna
      final responseBody = jsonDecode(response.body);
      // Zalogowano pomyślnie
      setState(() {
        name_storage = responseBody['name'];
        max_size = responseBody['max_size'];
        actual_size = responseBody['actual_size'];
        owner_name = responseBody['owner_username'];
      });
      Get_fiels_names(context);
    } else {
      // Obsłuż błąd HTTP
      print('Błąd HTTP: ${response.statusCode}');
      print('Treść odpowiedzi: ${response.body}');
    }
  }

  Get_fiels_names(BuildContext context) async {
    Map data = {
      'token': globals.token,
      'storage_id': widget.storageId,
      'path': actualPath
    };
    var body = json.encode(data);
    var response = await http.post(
        Uri.parse(server_ip +
            '/storage/files'), // Tutaj przekształcamy ciąg znaków na Uri
        headers: {"Content-Type": "application/json"},
        body: body);

    if (response.statusCode == 200) {
      // Odpowiedź jest poprawna
      final hej = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(hej);
      // Zalogowano pomyślnie
      setState(() {
        actualFiles = responseBody;
      });
    } else {
      // Obsłuż błąd HTTP
      print('Błąd HTTP: ${response.statusCode}');
      print('Treść odpowiedzi: ${response.body}');
    }
  }

  Download_file(BuildContext context, String Filename) async {
    Map data = {
      'token': globals.token,
      'database_id': widget.storageId,
      'file_path': actualPath + Filename,
      "filename": Filename,
    };
    var body = json.encode(data);
    var response = await http.post(
        Uri.parse(server_ip +
            '/storage/get_file'), // Tutaj przekształcamy ciąg znaków na Uri
        headers: {"Content-Type": "application/json"},
        body: body);

    if (response.statusCode == 200) {
      // Odpowiedź jest poprawna
      // final hej = utf8.decode(response.bodyBytes);
      // final responseBody = jsonDecode(hej);
      final bytes = response.bodyBytes;
      if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        print(directory);
        final file = File('${directory.path}/$Filename');
        await file.writeAsBytes(bytes);
      } else {
        final directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          final directory2 = await getExternalStorageDirectory();
          print(directory2);
          final file = File('${directory2}/$Filename');
          await file.writeAsBytes(bytes);
        } else {
          final file = File('${directory.path}/$Filename');
          await file.writeAsBytes(bytes);
        }
      }
      NotificationService().showNotification(
          title: "Downloaded compleated",
          body: "downloading file $Filename is compleated");
      print('Plik został pobrany i zapisany pomyślnie.');
    } else {
      // Obsłuż błąd HTTP
      print('Błąd HTTP: ${response.statusCode}');
      print('Treść odpowiedzi: ${response.body}');
    }
  }

  String goBackOneFolder(String path) {
    List<String> pathParts = path.split('');
    if (pathParts.length > 1) {
      pathParts.removeLast();
      for (int i = pathParts.length - 1; i >= 0; i--) {
        if (pathParts[i] != "/") {
          pathParts.removeAt(i);
        } else {
          break;
        }
      }
    }
    String haha = pathParts.join('');
    return haha;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Get_data(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          padding: Vx.m32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isClicked = !isClicked;
                  });
                  Future.delayed(Duration(milliseconds: 10), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StorageSettingsPage(storageId: widget.storageId),
                      ),
                    );
                  });
                },
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Ustawienie wyrównania do lewej
                    children: [
                      "${name_storage} storage:"
                          .text
                          .xl2
                          .make(), // Zmiana: Dodanie dwukropka po nazwie
                      Text("${actual_size / 1000}GB of ${max_size}GB"),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(17)),
                    border: Border.all(
                        color: isClicked
                            ? Colors.deepPurple.shade700
                            : Colors.grey),
                  ),
                  padding: EdgeInsets.all(9),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  actualPath = goBackOneFolder(actualPath);
                                });
                                Get_fiels_names(context);
                              },
                              onLongPress: () {
                                setState(() {
                                  actualPath = "/";
                                });
                                Get_fiels_names(context);
                              },
                              child: Container(
                                child: Icon(Icons.arrow_back_ios_new_rounded),
                                alignment: Alignment.topCenter,
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color:
                                            Colors.deepPurpleAccent.shade700)),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Container(
                                child: Text(actualPath),
                                alignment: Alignment.topCenter,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color:
                                            Colors.deepPurpleAccent.shade700)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        constraints: const BoxConstraints.expand(height: 500),
                        alignment: Alignment.centerLeft,
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: actualFiles.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  if (actualFiles[index][1] == 'dir') {
                                    setState(() {
                                      actualPath = actualPath +
                                          actualFiles[index][0] +
                                          '/';
                                    });
                                    Get_fiels_names(context);
                                  }
                                  if (actualFiles[index][0] == 'file') {}
                                },
                                child: Container(
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Color.fromARGB(
                                                      98, 179, 156, 232))),
                                          child: Row(
                                            children: [
                                              actualFiles[index][1] == 'dir'
                                                  ? Icon(Icons.folder_outlined)
                                                  : Icon(Icons
                                                      .insert_drive_file_outlined),
                                              SizedBox(
                                                width: 2,
                                              ),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(actualFiles[index][0]),
                                                    if (actualFiles[index][1] ==
                                                        'file')
                                                      InkWell(
                                                          onTap: () {
                                                            Download_file(
                                                                context,
                                                                actualFiles[
                                                                    index][0]);
                                                          },
                                                          child: Icon(
                                                              Icons.download)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ))),
                                  margin: EdgeInsets.all(3),
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: MyDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Builder(
        builder: (context) => CustomFABRow(),
      ),
    );
  }
}
