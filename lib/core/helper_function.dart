import 'package:share_plus/share_plus.dart';

class HelperFunction{


  static void shareContent(String content)async{
     await  Share.share(content);
  }
}