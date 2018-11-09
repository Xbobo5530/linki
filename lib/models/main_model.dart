import 'package:linki/models/link_model.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'MainModel:';

class MainModel extends Model with LinkModel {
  MainModel() {
    print('$_tag at MainModel');
    getLinks();
  }
}
