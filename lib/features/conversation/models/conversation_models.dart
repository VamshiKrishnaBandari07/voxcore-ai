class ConversationScenario {
  const ConversationScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.friendName,
    required this.turns,
  });

  final String id;
  final String title;
  final String description;
  final String iconName;
  final String friendName;
  final List<ConversationTurn> turns;
}

class ConversationTurn {
  const ConversationTurn({
    required this.friendOpens,
    required this.friendAfterUser,
    this.coachingHint,
  });

  /// What the co-friend says before the user speaks.
  final String friendOpens;

  /// Friendly reply after the user finishes their turn.
  final String friendAfterUser;

  final String? coachingHint;
}

class ChatMessage {
  const ChatMessage({
    required this.isFriend,
    required this.text,
    this.isRecording = false,
    this.durationLabel,
    this.sessionId,
  });

  final bool isFriend;
  final String text;
  final bool isRecording;
  final String? durationLabel;
  final int? sessionId;

  ChatMessage copyWith({
    bool? isFriend,
    String? text,
    bool? isRecording,
    String? durationLabel,
    int? sessionId,
  }) {
    return ChatMessage(
      isFriend: isFriend ?? this.isFriend,
      text: text ?? this.text,
      isRecording: isRecording ?? this.isRecording,
      durationLabel: durationLabel ?? this.durationLabel,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}
