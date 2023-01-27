// import 'dart:html';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audiobook Generator',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _fileName;
  String? _filePath;
  late PlatformFile file2;
  late File file;
  List<PlatformFile>? _paths;
  String? _directoryPath;

  bool _loadingPath = false;

  Future<int> upload(File file, String fileName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://18.222.192.28:5000"),
      );
      Map<String, String> headers = {"Content-type": "multipart/form-data"};
      request.files.add(
        http.MultipartFile(
          "file",
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: fileName,
          contentType: MediaType('file', 'pdf'),
        ),
      );
      request.headers.addAll(headers);
      var res = await request.send();
      print("response" + res.toString());
      var out = await http.Response.fromStream(res);
      print('out.body ' + out.body.toString());
      print(out);
      // print("This is response:" + res.toString());
      return res.statusCode;
    } catch (E) {
      throw (E);
    }
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _directoryPath = null;
      // _paths = (await FilePicker.platform.pickFiles(
      //         type: FileType.custom,
      //         allowMultiple: false,
      //         allowedExtensions: ['pdf']))
      //     ?.files;
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        file = File(result.files.single.path.toString());
        file2 = result.files.first;
        _fileName = file2.name;
        _filePath = file2.path;
        print(
            "filepath and name" + _filePath.toString() + _fileName.toString());
        var c = await upload(file, _fileName.toString());
        print('printing output' + c.toString());
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      file = file;
      _fileName = file2.name;
      _filePath = file2.path;
      // print(_paths!.first.extension);

      // _fileName =
      //     _paths != null ? _paths!.map((e) => e.name).toString() : '...';
    });
  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles().then((result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: result! ? Colors.green : Colors.red,
          content: Text((result
              ? 'Temporary files removed with success.'
              : 'Failed to clean temporary files')),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Audiobook",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 50),
                ),
                Text(
                  "generator.",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 50),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                Text(
                  "Please pick the file you want to convert",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextButton(
                  onPressed: () => _openFileExplorer(),
                  child: Text(
                    "Pick and Upload",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.blue.shade900),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
