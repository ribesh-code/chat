class TypingEvent {
  final String from;
  final String to;
  final Typing event;
  String? _id;

  String get id => _id!;

  TypingEvent({required this.from, required this.to, required this.event});

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'event': event.value(),
      };

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    var event = TypingEvent(
      from: json['from'],
      to: json['to'],
      event: TypingParse.fromString(json['event']),
    );
    event._id = json['id'];
    return event;
  }
}

enum Typing { start, stop }

extension TypingParse on Typing {
  String value() {
    return toString().split('.').last;
  }

  static Typing fromString(String event) {
    return Typing.values.firstWhere((ele) => ele.value() == event);
  }
}
