class Classification {
  String courseName;
  String courseStatus;
  String language;
  String uk;
  String akts;
  String grade;
  String points;
  String comment;

  Classification({this.courseName = "", this.courseStatus = "", this.language = "", this.uk = "",
      this.akts = "", this.grade = "", this.points = "", this.comment = ""});

  void fillValues(String text) {
    Match match;
    final RegExp pattern = RegExp(r"(\d+)\s+(\d+)\s+([A-Z]{2})\s+(\d+(\.\d+)?)\s+([A-Z]{1,2})");
    for (match in pattern.allMatches(text)) {
      uk = match.group(1) ?? "null";
      akts = match.group(2) ?? "null";
      grade = match.group(3) ?? "null";
      points = match.group(4) ?? "null";
      comment = match.group(5) ?? "null";
    }

  }
}
