import '../models/calendar_event_model.dart';
import '../providers/storage_provider.dart';

class EventRepository {
  static const _key = 'calendar_events';
  final StorageProvider _storage;

  EventRepository(this._storage);

  List<CalendarEventModel> getAll() {
    return _storage.readList(_key).map(CalendarEventModel.fromJson).toList();
  }

  Future<void> saveAll(List<CalendarEventModel> events) {
    return _storage.writeList(_key, events.map((e) => e.toJson()).toList());
  }
}
