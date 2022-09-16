class Task {
  int? id;
  String? title;
  String? note;
  String? date;
  String? startTime;
  String? endTime;
  String? repeat;
  int? isCompleted;
  int? color;

  Task({
    this.id,
    this.title,
    this.note,
    this.date,
    this.startTime,
    this.endTime,
    this.repeat,
    this.isCompleted,
    this.color,
  });

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    note = json['note'];
    date = json['date'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    repeat = json['repeat'];
    isCompleted = json['isCompleted'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['note'] = this.note;
    data['date'] = this.date;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    data['repeat'] = this.repeat;
    data['isCompleted'] = this.isCompleted;
    data['color'] = this.color;

    return data;
  }
}
