class RecommendedSearchModel {
  String? id;
  String? name;

  RecommendedSearchModel({this.id, this.name});

  RecommendedSearchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
