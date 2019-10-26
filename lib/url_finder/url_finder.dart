import 'package:flutter/foundation.dart';

final _regex = RegExp(
  r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z0-9]{2,6}\b"
  r"([-a-zA-Z0-9@:%_\+.~#?&//=]*)",
);

Future<List<String>> findUrls(List<String> originalTexts) async {
  return await compute(_findUrls, originalTexts);
}

List<String> _findUrls(List<String> originalTexts) {
  var resultUrls = <String>[];

  for (var value in originalTexts) {
    if (value == null) {
      continue;
    }
    var urlMatches = _regex.allMatches(value);

    for (var urlMatch in urlMatches) {
      var url = urlMatch.group(0);
      if (!resultUrls.contains(url)) {
        resultUrls.add(url);
      }
    }
  }

  return resultUrls;
}
