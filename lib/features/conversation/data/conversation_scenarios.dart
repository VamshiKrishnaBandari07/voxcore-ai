import '../models/conversation_models.dart';

const conversationScenarios = <ConversationScenario>[
  ConversationScenario(
    id: 'daily_catchup',
    title: 'Daily catch-up',
    description: 'Chat about your day like two friends over tea.',
    iconName: 'chat',
    friendName: 'Alex',
    turns: [
      ConversationTurn(
        friendOpens:
            "Hey! Good to see you. How was your day? Tell me one thing that went well.",
        friendAfterUser:
            "That sounds great — I can hear the energy in your voice. What was the hardest part of today?",
        coachingHint: 'Share one clear story. Use past tense.',
      ),
      ConversationTurn(
        friendOpens:
            "What was the hardest part of today?",
        friendAfterUser:
            "Thanks for being honest. That takes confidence. What will you do differently tomorrow?",
      ),
      ConversationTurn(
        friendOpens: "What will you do differently tomorrow?",
        friendAfterUser:
            "Solid plan. I like how direct you are. Last one — what are you looking forward to this week?",
      ),
      ConversationTurn(
        friendOpens: "What are you looking forward to this week?",
        friendAfterUser:
            "Love it. You spoke clearly and stayed on topic. Same time tomorrow?",
      ),
    ],
  ),
  ConversationScenario(
    id: 'job_interview',
    title: 'Friendly interview',
    description: 'Practice answers with a supportive mock interviewer.',
    iconName: 'work',
    friendName: 'Jordan',
    turns: [
      ConversationTurn(
        friendOpens:
            "Hi, thanks for joining. Tell me about yourself in about one minute.",
        friendAfterUser:
            "Good introduction. Now — describe a challenge you solved at work or school.",
      ),
      ConversationTurn(
        friendOpens: "Describe a challenge you solved recently.",
        friendAfterUser:
            "Nice structure. What is your biggest strength for this role?",
      ),
      ConversationTurn(
        friendOpens: "What is your biggest strength?",
        friendAfterUser:
            "Strong answer. Why do you want this opportunity?",
      ),
      ConversationTurn(
        friendOpens: "Why do you want this opportunity?",
        friendAfterUser:
            "Thank you. You stayed calm and professional. Keep that pace.",
      ),
    ],
  ),
  ConversationScenario(
    id: 'coffee_chat',
    title: 'Coffee shop chat',
    description: 'Light small talk — weather, hobbies, weekend plans.',
    iconName: 'coffee',
    friendName: 'Sam',
    turns: [
      ConversationTurn(
        friendOpens: "Hey! Fancy a coffee? What did you get up to last weekend?",
        friendAfterUser:
            "Fun! I went hiking. Do you prefer busy weekends or quiet ones?",
      ),
      ConversationTurn(
        friendOpens: "Do you prefer busy weekends or quiet ones?",
        friendAfterUser:
            "Same here sometimes. Have you picked up any new hobbies lately?",
      ),
      ConversationTurn(
        friendOpens: "Any new hobbies lately?",
        friendAfterUser:
            "Cool. If you could travel anywhere next month, where would you go?",
      ),
      ConversationTurn(
        friendOpens: "If you could travel anywhere next month, where would you go?",
        friendAfterUser:
            "I'd join you. You kept the conversation flowing naturally. Great job.",
      ),
    ],
  ),
  ConversationScenario(
    id: 'presentation',
    title: 'Presentation Q&A',
    description: 'Explain an idea; your co-friend asks follow-up questions.',
    iconName: 'present',
    friendName: 'Alex',
    turns: [
      ConversationTurn(
        friendOpens:
            "Imagine I'm your audience. Explain your main idea in 45 seconds.",
        friendAfterUser:
            "Clear start. Can you give one real example?",
      ),
      ConversationTurn(
        friendOpens: "Can you give one real example?",
        friendAfterUser:
            "Good example. What problem does this solve for people?",
      ),
      ConversationTurn(
        friendOpens: "What problem does this solve for people?",
        friendAfterUser:
            "Makes sense. What is the one thing you want us to remember?",
      ),
      ConversationTurn(
        friendOpens: "What is the one thing you want us to remember?",
        friendAfterUser:
            "Strong close. Your pacing was steady. Ready for the real stage.",
      ),
    ],
  ),
];

ConversationScenario scenarioById(String id) {
  return conversationScenarios.firstWhere(
    (s) => s.id == id,
    orElse: () => conversationScenarios.first,
  );
}
