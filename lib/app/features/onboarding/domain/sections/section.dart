abstract class ISection{
  String get title;
}

class Section implements ISection{
  @override
  final String title;

  const Section({required this.title});
}