import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linki/models/link.dart';
import 'package:linki/models/link_model.dart';
import 'package:linki/values/consts.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

const _tag = 'MainModel:';

class MainModel extends Model with LinkModel{
  MainModel() {
    getLinks();
  }
}


