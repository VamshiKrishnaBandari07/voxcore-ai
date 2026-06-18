import '../models/conversation_models.dart';

/// Generates warm, co-friend style replies between turns.
class ConversationPartner {
  String openingMessage(ConversationScenario scenario) {
    return "Hi, I'm ${scenario.friendName}. ${scenario.turns.first.friendOpens}";
  }

  String afterUserTurn({
    required ConversationScenario scenario,
    required int completedTurnIndex,
    required int durationSec,
  }) {
    final turn = scenario.turns[completedTurnIndex];
    final durationNote = durationSec < 8
        ? 'Try a bit more detail next time — '
        : durationSec > 90
            ? 'Nice depth — maybe tighten slightly next time. '
            : 'Good length — ';

    return '$durationNote${turn.friendAfterUser}';
  }

  String? nextPrompt(ConversationScenario scenario, int nextTurnIndex) {
    if (nextTurnIndex >= scenario.turns.length) return null;
    return scenario.turns[nextTurnIndex].friendOpens;
  }

  String sessionComplete(ConversationScenario scenario) {
    return "${scenario.friendName}: That was a great practice session together. "
        "Check History for your recordings and scores.";
  }
}
