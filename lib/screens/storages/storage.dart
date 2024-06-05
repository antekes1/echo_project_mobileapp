import 'dart:ffi';
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
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import '../../utils/CustomFABRow.dart';
import '../../utils/custom_funtions.dart';
import '../../utils/api//notifications_api.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/custom_funtions.dart';

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
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String username = globals.username;
  final server_ip = globals.server_ip;

  String name_storage = "";
  int max_size = 0;
  double actual_size = 0;
  String owner_name = "";

  bool changeButton = false;
  bool isClicked = false;

  List dirs_errors = [];
  String newDirName = "";
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
      final hej = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(hej);
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

  Add_dir_remote(BuildContext context, String dir_name) async {
    Map data = {
      'token': globals.token,
      'storage_id': widget.storageId,
      'path': actualPath + dir_name,
    };
    var body = json.encode(data);
    var response = await http.post(
        Uri.parse(server_ip +
            '/storage/create_dir'), // Tutaj przekształcamy ciąg znaków na Uri
        headers: {"Content-Type": "application/json"},
        body: body);

    if (response.statusCode == 201) {
      // Odpowiedź jest poprawna
      final hej = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(hej);
      if (responseBody.containsKey("msg")) {
        final snackBar = SnackBar(
          content: Text(
            "folder created succesful",
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.black,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.deepPurple, width: 2)),
          behavior: SnackBarBehavior.floating,
        );
        //ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      await Get_fiels_names(context);
    } else {
      // Obsłuż błąd HTTP
      print('Błąd HTTP: ${response.statusCode}');
      print('Treść odpowiedzi: ${response.body}');
      final hej = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(hej);
      final scaffoldState = scaffoldKey.currentState;

      final snackBar = SnackBar(
        content: Text(
          responseBody["detail"],
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.deepPurple, width: 2)),
        behavior: SnackBarBehavior.floating,
      );
      final error = responseBody["detail"];
      setState(() {
        dirs_errors.add(error);
      });

      //ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        List parts = filename.split('.');
        if (parts.length > 1) {
          String name = parts
              .sublist(0, parts.length - 1)
              .join('.'); // Uzyskaj nazwę pliku bez rozszerzenia
          String extension = parts.last; // Uzyskaj rozszerzenie pliku

          // Szukaj unikalnej nazwy pliku z numerem wersji
          do {
            newFilename = '${directory.path}/$name ($version).$extension';
            version++;
          } while (await File(newFilename).exists());
          await originalFile.copy(newFilename);
        }
      }

      // Zapisz nowy plik
      await originalFile.writeAsBytes(bytes);
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
          List parts = filename.split('.');
          if (parts.length > 1) {
            String name = parts
                .sublist(0, parts.length - 1)
                .join('.'); // Uzyskaj nazwę pliku bez rozszerzenia
            String extension = parts.last; // Uzyskaj rozszerzenie pliku

            // Szukaj unikalnej nazwy pliku z numerem wersji
            do {
              newFilename = '${directory2}/$name ($version).$extension';
              version++;
            } while (await File(newFilename).exists());
            await originalFile.copy(newFilename);
          }
        }

        // Zapisz nowy plik
        await originalFile.writeAsBytes(bytes);
      } else {
        final file = File('${directory.path}/$filename');
        final originalFile = File('${directory.path}/$filename');
        if (await originalFile.exists()) {
          int version = 1;
          String newFilename;

          // Szukaj unikalnej nazwy pliku z numerem wersji
          List parts = filename.split('.');
          if (parts.length > 1) {
            String name = parts
                .sublist(0, parts.length - 1)
                .join('.'); // Uzyskaj nazwę pliku bez rozszerzenia
            String extension = parts.last; // Uzyskaj rozszerzenie pliku

            // Szukaj unikalnej nazwy pliku z numerem wersji
            do {
              newFilename = '${directory.path}/$name ($version).$extension';
              version++;
            } while (await File(newFilename).exists());
            await originalFile.copy(newFilename);
          }
        }
        // Zapisz nowy plik
        await originalFile.writeAsBytes(bytes);
      }
    }
  }

  Download_file(BuildContext context, String Filename) async {
    await get_online(context);
    Map data = {
      'token': globals.token,
      'database_id': widget.storageId,
      'file_path': actualPath + Filename,
      "filename": Filename,
    };
    var body = json.encode(data);
    var response = await http.post(Uri.parse(server_ip + '/storage/get_file'),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 200) {
      // Odpowiedź jest poprawna
      // final hej = utf8.decode(response.bodyBytes);
      // final responseBody = jsonDecode(hej)
      final bytes = response.bodyBytes;
      await SaveFile(context, Filename, response);
      await service.showNotification(
          id: 0,
          body: "Downloading file $Filename is completed",
          title: "Download completed");
      print('Plik został pobrany i zapisany pomyślnie.');
    } else {
      // Obsłuż błąd HTTP
      print('Błąd HTTP: ${response.statusCode}');
      print('Treść odpowiedzi: ${response.body}');
      final hej = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(hej);
      final snackBar = SnackBar(
        content: Text(
          responseBody["detail"],
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.deepPurple, width: 2)),
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  TextEditingController _controller = TextEditingController();

  UploadFile(BuildContext context) async {
    await get_online(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      String fileName = file.name;
      String filePath = file.path!;

      var url = Uri.parse(
          server_ip + '/storage/upload_file'); // Zmień na odpowiedni adres URL
      var request = http.MultipartRequest('POST', url);
      request.fields['token'] = globals.token; // Dodaj pola formularza
      request.fields['dir_path'] = actualPath;
      request.fields['database_id'] = widget.storageId.toString();

      // Dodaj wybrany plik do requesta
      request.files.add(http.MultipartFile(
        'file', // Nazwa pola w formularzu
        File(filePath).readAsBytes().asStream(), // Strumień danych pliku
        File(filePath).lengthSync(), // Rozmiar pliku
        filename: fileName, // Nazwa pliku
        contentType: MediaType('application', 'octet-stream'), // Typ zawartości
      ));

      var response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        // Odpowiedź jest poprawna
        final hej = utf8.decode(response.bodyBytes);
        final responseBody = jsonDecode(hej);
        // Zalogowano pomyślnie
        print(responseBody);
        final snackBar = SnackBar(
          content: Text(
            responseBody["msg"],
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.black,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.deepPurple, width: 2)),
          behavior: SnackBarBehavior.floating,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        await service.showNotification(
            id: 0, body: "file is completed", title: "Upload completed");
        Get_fiels_names(context);
        Get_data(context);
      } else {
        // Obsłuż błąd HTTP
        print('Błąd HTTP: ${response.statusCode}');
        print('Treść odpowiedzi: ${response.body}');
        final hej = utf8.decode(response.bodyBytes);
        final responseBody = jsonDecode(hej);
        setState(() {
          dirs_errors.add(responseBody["detail"]);
        });
      }
    } else {
      // Użytkownik anulował wybór pliku
    }
  }

  DeleteItem(BuildContext context, String filename) async {
    Map data = {
      'token': globals.token,
      'storage_id': widget.storageId,
      'path': actualPath + filename,
    };
    var body = json.encode(data);
    var response = await http.delete(
        Uri.parse(server_ip +
            '/storage/del_item'), // Tutaj przekształcamy ciąg znaków na Uri
        headers: {"Content-Type": "application/json"},
        body: body);

    if (response.statusCode == 200) {
      final hej = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(hej);
      final snackBar = SnackBar(
        content: Text(
          responseBody["msg"],
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.deepPurple, width: 2)),
        behavior: SnackBarBehavior.floating,
      );
      await Get_fiels_names(context);
      await Get_data(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print('Błąd HTTP: ${response.statusCode}');
      print('Treść odpowiedzi: ${response.body}');
      final hej = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(hej);
      final snackBar = SnackBar(
        content: Text(
          responseBody["detail"],
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.deepPurple, width: 2)),
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    get_online(context);
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
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Ustawienie wyrównania do lewej
                          children: [
                            "${name_storage} storage:"
                                .text
                                .xl2
                                .make(), // Zmiana: Dodanie dwukropka po nazwie
                            Text(
                                "${(actual_size / 1073741824).toStringAsFixed(2)}GB of ${max_size}GB"),
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
                    SizedBox(
                      width: 3,
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(17)),
                        border: Border.all(
                            color: isClicked
                                ? Colors.deepPurple.shade700
                                : Colors.grey),
                      ),
                      padding: EdgeInsets.all(9),
                      alignment: Alignment.center,
                      child: Icon(Icons.settings),
                    ),
                  ],
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
                      // creating dir upload
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
                                                onTap: () async {
                                                  await UploadFile(context);
                                                  Navigator.pop(context);
                                                },
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
                                              GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Create folder'),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                  "Enter folder name"),
                                                              Form(
                                                                key: _formKey,
                                                                child:
                                                                    TextFormField(
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'name',
                                                                  ),
                                                                  validator:
                                                                      (value) {
                                                                    if (value
                                                                            ?.isEmpty ??
                                                                        true) {
                                                                      return "That can't be empty :)";
                                                                    }
                                                                    return null;
                                                                  },
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      newDirName =
                                                                          value;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                if (_formKey
                                                                        .currentState
                                                                        ?.validate() ==
                                                                    true) {
                                                                  Add_dir_remote(
                                                                      context,
                                                                      newDirName);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                }
                                                              },
                                                              child: Text(
                                                                  'Create'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child:
                                                                  Text('Close'),
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                },
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
                      if (dirs_errors.isNotEmpty)
                        for (String error in dirs_errors)
                          Text(
                            error,
                            style: TextStyle(color: Colors.red),
                          ),
                      SizedBox(
                        height: 4,
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
                                                    Expanded(
                                                      child: Container(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              actualFiles[index]
                                                                  [0],
                                                              style:
                                                                  TextStyle(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            DeleteItem(
                                                                context,
                                                                actualFiles[
                                                                    index][0]);
                                                          },
                                                          child: Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                        if (actualFiles[index]
                                                                [1] ==
                                                            'file')
                                                          InkWell(
                                                              onTap: () async {
                                                                await Download_file(
                                                                    context,
                                                                    actualFiles[
                                                                            index]
                                                                        [0]);
                                                              },
                                                              child: Icon(
                                                                Icons.download,
                                                                color: Colors
                                                                    .green
                                                                    .shade300,
                                                              )),
                                                      ],
                                                    ),
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
