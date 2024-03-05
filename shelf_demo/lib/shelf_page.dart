import 'dart:io';

// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_flutter_asset/shelf_flutter_asset.dart';
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_router/shelf_router.dart' as shelf_router;

class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key, required this.title});

  final String title;

  @override
  State<ShelfPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ShelfPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  late final HttpServer server;

  void startServer() async {
    print("start server");
    var app = shelf_router.Router();

    app.post("/assets/upload", (Request request) async {
      if (request.isMultipartForm) {
        if (!request.isMultipart) {
          return Response.ok('Not a multipart request');
        } else if (request.isMultipartForm) {
          await for (final formData in request.multipartFormData) {
            if (formData.name == 'uploadfile') {
              var totalLength = 0;
              var filebytes = await formData.part.readBytes();
              var tempDir = await getTemporaryDirectory();
              var file = await File('${tempDir.path}/${formData.filename}');
              file.writeAsBytesSync(filebytes);
              print("${file.path}");
              totalLength += (filebytes).length;
              print("长度:${totalLength}");
            }
          }
          return Response.ok('ok');
        }
      }
    });

    final assetHandler = createAssetHandler();
    app.get('/assets/<ignored|.*>', (Request request) {
      return assetHandler(request.change(path: 'assets'));
    });
    const int port = 8080;
    server = await shelf_io.serve(
      app,
      '192.168.31.46',
      port,
      shared: true,
    );
    print('Serving at http://${server.address.host}:${server.port}');
  }

  @override
  void dispose() {
    server.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: TextButton(
            onPressed: () {
              startServer();
            },
            child: Text("start server")),
      ),
    );
  }
}
