import 'dart:io';
import 'package:flutter/rendering.dart';
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
  late final LocalNotificationService service;
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

  SaveFile(BuildContext context, String filename, final response) async {
    final bytes = response.bodyBytes;
    if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      final originalFile = File('${directory.path}/$filename');
      if (await originalFile.exists()) {
        int version = 1;
        String newFilename;

        // Szukaj unikalnej nazwy pliku z numerem wersji
        do {
          newFilename = '${directory.path}/$filename ($version)';
          version++;
        } while (await File(newFilename).exists());
        await originalFile.copy(newFilename);
      }

      // Zapisz nowy plik
      await originalFile.writeAsBytes(bytes);
      // final file = File('${directory.path}/$filename');
      // await file.writeAsBytes(bytes);
    } else {
      final directory = Directory('/storage/emulated/0/Download');
      // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
      if (!await directory.exists()) {
        final directory2 = await getExternalStorageDirectory();
        final originalFile = File('${directory2}/$filename');
        if (await originalFile.exists()) {
          int version = 1;
          String newFilename;

          // Szukaj unikalnej nazwy pliku z numerem wersji
          do {
            newFilename = '${directory2}/$filename ($version)';
            version++;
          } while (await File(newFilename).exists());
          await originalFile.copy(newFilename);
        }

        // Zapisz nowy plik
        await originalFile.writeAsBytes(bytes);
        // final file = File('${directory.path}/$filename');
        // await file.writeAsBytes(bytes);
      } else {
        final file = File('${directory.path}/$filename');
        final originalFile = File('${directory.path}/$filename');
        if (await originalFile.exists()) {
          int version = 1;
          String newFilename;

          // Szukaj unikalnej nazwy pliku z numerem wersji
          do {
            newFilename = '${directory.path}/$filename ($version)';
            version++;
          } while (await File(newFilename).exists());
          await originalFile.copy(newFilename);
        }

        // Zapisz nowy plik
        await originalFile.writeAsBytes(bytes);
        // final file = File('${directory.path}/$filename');
        // await file.writeAsBytes(bytes);
      }
    }
    // Notification
    await service.showNotification(
        id: 0,
        body: "Downloading file $filename is completed",
        title: "Download completed");
    print('Plik został pobrany i zapisany pomyślnie.');
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
      await SaveFile(context, Filename, response);
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
    service = LocalNotificationService();
    service.intialize();
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
              // nazwa storage z danymi
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
              // reszta
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      // path with back button
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
                      // creating dir
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 75,
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return FractionallySizedBox(
                                    widthFactor: 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25),
                                        ),
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: 16.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () {},
                                                child: Container(
                                                  height: 100,
                                                  width: 60,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(Icons
                                                              .upload_file_outlined),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                      Text(
                                                        "Upload file",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 12,
                                              ),
                                              InkWell(
                                                onTap: () {},
                                                child: Container(
                                                  height: 100,
                                                  width: 60,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(Icons
                                                              .create_new_folder_rounded),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                      Text(
                                                        "create dir",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // ElevatedButton(
                                          //   onPressed: () {
                                          //     // Kod obsługujący upload pliku
                                          //     Navigator.pop(context);
                                          //   },
                                          //   child: Text('Wybierz plik'),
                                          // ),
                                          SizedBox(height: 8.0),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Kod obsługujący upload zdjęcia
                                              Navigator.pop(context);
                                            },
                                            child: Text('anuluj'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 40,
                              width: 75,
                              child: Text("New",
                                  style: TextStyle(color: Colors.black)),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.cyan.shade600,
                                  border: Border.all(
                                      color: Colors.blueGrey.shade700),
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      // content list
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
