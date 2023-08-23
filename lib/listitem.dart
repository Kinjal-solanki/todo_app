
class ListItem {
  String title;
  bool isChecked;
  String dateOfCreation;

  ListItem({
    required this.title,
    this.isChecked = false,
    required this.dateOfCreation,
  });

  ListItem.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        isChecked = json['isChecked'],
        dateOfCreation = json['creationDate'];

  Map<String, dynamic> toJson() => {
    'title': title,
    'isChecked': isChecked,
    'creationDate': dateOfCreation,
  };
}