
   final _regex = RegExp(
    r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z0-9]{2,6}\b"
    r"([-a-zA-Z0-9@:%_\+.~#?&//=]*)",
  );
// final _regex = RegExp(
//  r"(www|http:|https:)+[^\s]+[\w]",
//);

Future<List<String>> findUrls(List<String> originalTexts) async {
  var resultUrls = <String>[];

  // TODO: improve performance with isolates
  for (var value in originalTexts) {
    if(value == null) {
      continue;
    }
    var urlMatches  = _regex.allMatches(value);

    for (var urlMatch in urlMatches) {
      var url = urlMatch.group(0);
      if (!resultUrls.contains(url)) {
        resultUrls.add(url);
      }
    }

  }

  return resultUrls;
}
