class GradeModel {
  final int id;
  final String name;

  GradeModel({
    required this.id,
    required this.name,
  });

  factory GradeModel.fromJson( Map<String, dynamic> json, ) {
    return GradeModel(
      id: json['id'],
      name: json['name'],
    );
  }
}