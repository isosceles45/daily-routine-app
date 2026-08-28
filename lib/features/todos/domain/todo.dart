/// Todo importance. Stored as an int so the column stays trivially portable.
enum TodoPriority {
  low(0, 'Low'),
  normal(1, 'Normal'),
  high(2, 'High');

  const TodoPriority(this.value, this.label);

  final int value;
  final String label;

  static TodoPriority fromValue(int value) => TodoPriority.values.firstWhere(
    (p) => p.value == value,
    orElse: () => TodoPriority.normal,
  );
}

/// Which group a todo appears under on the Todos tab.
///
/// The canvas has four sections; the written spec listed three. Following the
/// canvas, since "Upcoming" is what makes a due date worth setting.
enum TodoSection { today, upcoming, overdue, completed }
