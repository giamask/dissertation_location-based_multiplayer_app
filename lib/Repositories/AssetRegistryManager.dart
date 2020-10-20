import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class AssetRegistryManager{

  Future<String> retrieveAssetRegistry() async{
    final path=await localPath;
    File registry=File("$path\\asset_registry.json");
    try{
      return registry.readAsStringSync();
    }
    on FileSystemException catch(e){
      return "Cannot find asset registry.";
    }
  }

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<int> getVersionNumber() async{
    final path=await localPath;
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

  void replaceAssetRegistry(jsonFile) async{
    final path=await localPath;
    File registry=File("$path\\asset_registry.json");
    registry.writeAsStringSync(jsonFile);
  }

  Future<Map> teamFromUserId(String userId) async{
    String assetRegistry = await retrieveAssetRegistry();
    Map assetJSON = jsonDecode(assetRegistry);
    List teams= assetJSON['joumerka']['Teams'];
    return teams.firstWhere((element) {
      List playerIds = element['PlayerIds'];
      if (playerIds.contains(userId)) return true;
      return false;
    });
  }


}