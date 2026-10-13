class FitnessPlan {
  final String title, summary;
  final List<WorkoutDay> weeklySchedule;
  final List<String> habits, safetyNotes;
  const FitnessPlan({required this.title, required this.summary, required this.weeklySchedule, required this.habits, required this.safetyNotes});
  factory FitnessPlan.fromJson(Map<String, dynamic> j) => FitnessPlan(
    title: j['title']?.toString() ?? 'Your fitness plan',
    summary: j['summary']?.toString() ?? '',
    weeklySchedule: (j['weeklySchedule'] as List? ?? []).whereType<Map>().map((e) => WorkoutDay.fromJson(Map<String,dynamic>.from(e))).toList(),
    habits: (j['habits'] as List? ?? []).map((e) => e.toString()).toList(),
    safetyNotes: (j['safetyNotes'] as List? ?? []).map((e) => e.toString()).toList(),
  );
}
class WorkoutDay {
  final String day, focus;
  final List<Exercise> workout;
  const WorkoutDay({required this.day, required this.focus, required this.workout});
  factory WorkoutDay.fromJson(Map<String,dynamic> j) => WorkoutDay(
    day: j['day']?.toString() ?? 'Training day', focus: j['focus']?.toString() ?? '',
    workout: (j['workout'] as List? ?? []).whereType<Map>().map((e) => Exercise.fromJson(Map<String,dynamic>.from(e))).toList(),
  );
}
class Exercise {
  final String exercise, sets, reps, rest, notes;
  const Exercise({required this.exercise, required this.sets, required this.reps, required this.rest, required this.notes});
  factory Exercise.fromJson(Map<String,dynamic> j) => Exercise(
    exercise: j['exercise']?.toString() ?? 'Exercise', sets: j['sets']?.toString() ?? '',
    reps: j['reps']?.toString() ?? '', rest: j['rest']?.toString() ?? '', notes: j['notes']?.toString() ?? '',
  );
}
