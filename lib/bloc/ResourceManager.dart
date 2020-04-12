import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/*
Για την χρήση αυτής της κλάσης χρειάζεται ο ορισμός ενός server (hardcoded σε local host) και η χρήση συγκεκριμένου formatting στα αρχεία. Συγκεκριμένα:
asset_registry.json που να περιέχει το version (int).
assets/$imageName.jpg
Επισης προσοχή στα paths του server.
*/
enum Status{
  none,
  initialized,
  error
}

class ResourceManager{
  // Singleton
  static final ResourceManager _resourceManager= ResourceManager._internal();
  factory ResourceManager(){
    return _resourceManager;
  }
  ResourceManager._internal(){}

  Status status=Status.none;
  //Initialization
  Future<void> init() async{
    int version = await _recoverVersionNumber();
    http.Response response= await  _postRequest("{\"type\":\"asset_registry\",\"version\":\"$version\"}");
    if (response==null){
      status=Status.error;
      return;
    }
    await createAssetDirectory();
    if(response.body.contains("\"type\":\"update\"")) _replaceAssetRegistry(response.body);
    status = Status.initialized;
  }

  Future<String> retrieveAssetRegistry() async{
    final path=await _localPath;
    File registry=File("$path\\asset_registry.json");
    try{
      return registry.readAsStringSync();
    }
    on FileSystemException catch(e){
      return "Cannot find asset registry.";
    }
  }

  //ImageRetrieval (example: 01.jpg)
  Future<Image> retrieveImage(String imageName) async{
    final String path = await _localPath;
    File imageFile=File("$path/assets/$imageName");
    try{
      imageFile.readAsBytesSync();
      return Image.file(imageFile);
    }
    on FileSystemException catch(e){
      http.Response response= await  _postRequest("{\"type\":\"image_request\",\"name\":\"$imageName\"}");
      imageFile.writeAsBytesSync(response.bodyBytes);
      return Image.file(imageFile);
    }

  }


// get local path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //send post request
  Future<http.Response> _postRequest(String json) async {
    var url = 'http://192.168.2.2/serving_json/jsonserver.php'; //server hardcode here
    var body = json;
    var responseBody;
    print(json);
    http.Response response = await http
        .post(url, headers: {"Content-Type": "application/json"}, body: body);
    print(response);
    return response;
  }

  //get version number from the asset registry
  Future<int> _recoverVersionNumber() async{
    final path=await _localPath;
    File registry=File("$path\\asset_registry.json");
    try {
      String registryContents = registry.readAsStringSync();
      if (registryContents==null) return 0;
      Map parsedJson = json.decode(registryContents);
      return parsedJson['version'];
    }
    on FileSystemException catch(e){
      return 0;
    }


  }


  //delete previous registry and save current
  void _replaceAssetRegistry(jsonFile) async{
    final path=await _localPath;
    File registry=File("$path\\asset_registry.json");
    registry.writeAsStringSync(jsonFile);
  }

  void debugPrint(String path) async{
    File file=File(path);
    String contents=file.readAsStringSync();
    print("Debug Print:" + contents);
  }

  //asset directory creator function
  Future<void> createAssetDirectory() async{
    final path=await _localPath;
    Directory(path +"/assets").create();
  }


}