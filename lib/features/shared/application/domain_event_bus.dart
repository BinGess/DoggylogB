import 'dart:async';

import 'package:doggylog/features/shared/domain/models.dart';

sealed class DomainEvent {
  const DomainEvent();
}

class TaskChangedEvent extends DomainEvent {
  const TaskChangedEvent(this.item);

  final CalendarItem item;
}

class TaskCompletedEvent extends DomainEvent {
  const TaskCompletedEvent(this.item);

  final CalendarItem item;
}

class PetStateChangedEvent extends DomainEvent {
  const PetStateChangedEvent(this.petId);

  final String petId;
}

class SyncStateChangedEvent extends DomainEvent {
  const SyncStateChangedEvent(this.description);

  final String description;
}

class DomainEventBus {
  final StreamController<DomainEvent> _controller =
      StreamController<DomainEvent>.broadcast();

  Stream<DomainEvent> get stream => _controller.stream;

  void fire(DomainEvent event) {
    _controller.add(event);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
