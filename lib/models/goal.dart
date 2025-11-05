class Goal {
  final String id;
  final String title;
  final int triesCompleted;
  final int totalTries;
  final String imageUrl;
  final List<Try> tries;

  Goal({
    required this.id,
    required this.title,
    required this.triesCompleted,
    required this.totalTries,
    required this.imageUrl,
    required this.tries,
  });

  int get triesLeft => totalTries - triesCompleted;
}

class Try {
  final String id;
  final String title;
  final String date;
  final String summary;
  final String imageUrl;
  final String? videoUrl;

  Try({
    required this.id,
    required this.title,
    required this.date,
    required this.summary,
    required this.imageUrl,
    this.videoUrl,
  });
}
