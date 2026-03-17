extension ListStringManager on List {
  String toCommaSeparatedString() {
    if (isEmpty) return ""; // Handle empty list to avoid errors
    return map((e) => e.toString()).join(", ");
  }
}
