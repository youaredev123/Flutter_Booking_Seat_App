import 'dart:io';

String getExtension(File file) {
  String path = file.path;
  var splits = path.split('.');
  return splits.last;
}

List<int> getListFromString(String str) {
  int len = str.length;
  if (str == '[]') return [0, 0];
  String _str = str.substring(1, len - 1);

  List<String> splitted_array = _str.split(',');
  return [int.parse(splitted_array[0]), int.parse(splitted_array[1])];
}
