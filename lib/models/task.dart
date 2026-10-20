class Task {
  final String id;
  String title;
  String notes;
  bool isStarred;
  bool isCompleted;
  String? dueDate;
  String? dueTime;
  String? repeatRule;
  int isSynced; // 0 = Not Synced, 1 = Synced

  Task({
    required this.id,
    required this.title,
    this.notes = '',
    this.isStarred = false,
    this.isCompleted = false,
    this.dueDate,
    this.dueTime,
    this.repeatRule,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'isStarred': isStarred ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'dueDate': dueDate ?? '',
      'dueTime': dueTime ?? '',
      'repeatRule': repeatRule ?? '',
      'isSynced': isSynced,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      notes: map['notes'] ?? '',
      isStarred: map['isStarred'] == 1,
      isCompleted: map['isCompleted'] == 1,
      dueDate: map['dueDate'],
      dueTime: map['dueTime'],
      repeatRule: map['repeatRule'],
      isSynced: map['isSynced'] ?? 0,
    );
  }

  Map<String, dynamic> toJsonForSheet() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'isStarred': isStarred,
      'isCompleted': isCompleted,
      'dueDate': dueDate ?? '',
      'dueTime': dueTime ?? '',
      'repeatRule': repeatRule ?? '',
    };
  }
}
