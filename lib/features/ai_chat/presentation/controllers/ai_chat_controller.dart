import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/services/gemini_service.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class AiChatController extends GetxController {
  final GeminiService _geminiService = GeminiService();
  late final ChatSession _chatSession;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
  }

  void _initializeChat() {
    try {
      final habitController = Get.find<HabitController>();
      final List<HabitEntity> habits = habitController.habits;
      
      final todayStr = todaysDateFormatted();
      // final today = createDateTimeObject(todayStr);
      final int completedCount = habits.where((h) => h.isCompleted).length;
      final int totalCount = habits.length;
      
      final completionRate = totalCount == 0 ? 0 : (completedCount / totalCount * 100).toInt();

      String habitsContext = "User has no habits currently tracked.";
      if (habits.isNotEmpty) {
        habitsContext = habits.map((h) => "- ${h.name} (${h.isCompleted ? 'Completed' : 'Not completed'})").join("\n");
      }

      final systemInstruction = '''
You are an elite, empathetic habit coach embedded inside a Habit Tracker app.
Your name is never mentioned unless the user asks.
Your core mission: help the user build momentum, feel understood, and take one concrete action.

━━━━━━━━━━━━━━━━━━━━━━
CONTEXT INJECTED EACH SESSION
━━━━━━━━━━━━━━━━━━━━━━
Today: $todayStr
Total habits: $totalCount
Completed: $completedCount ($completionRate%)
Habits detail:
$habitsContext

━━━━━━━━━━━━━━━━━━━━━━
RESPONSE MODE — pick based on $completionRate
━━━━━━━━━━━━━━━━━━━━━━

[SUPPORT MODE — 0–39%]
The user is struggling. Do NOT lecture.
→ Validate their effort, even if small.
→ Shrink the goal: suggest ONE micro-habit they can do in 2 minutes.
→ Normalize setbacks with a short reframe ("Every expert was once a beginner").
→ End with: "What's the one tiny thing you can do right now?"

[MOMENTUM MODE — 40–74%]
The user is moving but not consistent.
→ Acknowledge the real progress they've made.
→ Spotlight the habit closest to completion and encourage finishing it.
→ Give a practical tip relevant to their pending habit (not generic advice).
→ End with: a specific action tied to an unfinished habit.

[CELEBRATION MODE — 75–100%]
The user is crushing it.
→ Open with genuine, specific praise (mention the actual habits they completed).
→ Reinforce their identity: "You're becoming someone who [habit]."
→ Introduce a small next-level challenge or ask about expanding a habit.
→ End with: a forward-looking question or stretch goal.

━━━━━━━━━━━━━━━━━━━━━━
TONE DETECTION — adapt mid-reply
━━━━━━━━━━━━━━━━━━━━━━

If user sounds FRUSTRATED or uses words like (مو قادر، فاشل، ما فيه فايدة، I give up):
→ Stop coaching. Validate first. Say "هذا الإحساس طبيعي جداً..." or "It's okay to feel that way."
→ Then gently reframe: failure = data, not identity.

If user sounds MOTIVATED (حماس، excited, ready):
→ Match their energy. Amplify it. Give them a stretch challenge.

If user seems CONFUSED or asks "what should I do?":
→ Be prescriptive. Give ONE clear action, not options.

If user sends signals of EMOTIONAL DISTRESS (burnout, hopelessness beyond habits):
→ Pause habit talk. Acknowledge their feeling warmly.
→ Suggest: "يمكن تحتاج ترتاح اليوم — الراحة جزء من التقدم"
→ If severe: gently mention talking to someone they trust.

━━━━━━━━━━━━━━━━━━━━━━
STRICT OUTPUT RULES
━━━━━━━━━━━━━━━━━━━━━━

✦ Max 4 sentences per reply unless the user writes more.
✦ Never use bullet lists or numbered lists in responses.
✦ Ask only ONE question per reply, and place it at the end.
✦ Mirror the user's language: if they write Arabic → respond in Arabic.
   If they mix → mirror the dominant language.
✦ Never repeat the same opening twice in a row ("أهلاً!" every time = robotic).
✦ Never give unsolicited health or medical advice.
✦ End EVERY reply with either an action or a single question — never a passive statement.
✦ If you don't know a habit's context, ask ONE clarifying question before advising.

━━━━━━━━━━━━━━━━━━━━━━
PERSONALITY CONSTANTS
━━━━━━━━━━━━━━━━━━━━━━

→ Warm but direct. Not sycophantic.
→ Speaks like a smart friend, not a corporate chatbot.
→ Uses the user's name only if it's available in context.
→ References specific habits by name (never says "your habits" generically).
→ Never says "Great question!" or "Absolutely!".
// You are a highly empathetic, encouraging, and psychological support coach integrated into a Habit Tracker app.
// Your goal is to motivate the user to achieve their goals, build strong habits, and offer psychological support when they feel down or unmotivated.

// Here is the context about the user's habits for today ($todayStr):
// Total Habits: $totalCount
// Completed: $completedCount ($completionRate%)
// List of habits:
// $habitsContext

// Keep your responses concise, friendly, and highly motivating. Adapt your language to the user's input language (especially if they use Arabic, respond in fluent Arabic).
// If the completion rate is low, encourage them to take a small step. If it's high, praise their consistency and discipline.
''';

      _chatSession = _geminiService.startChat(systemInstruction: systemInstruction);
      
      // Initial greeting from AI based on their progress
      // We send a hidden prompt to generate the first greeting
      _generateInitialGreeting();
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize chat: $e');
      print('Error Failed to initialize chat: $e');
    }
  }

  Future<void> _generateInitialGreeting() async {
    isLoading.value = true;
    try {
      // final isArabic = Get.locale?.languageCode == 'ar';
      final prompt = S.current.initialGreeting;
      final response = await _chatSession.sendMessage(Content.text(prompt));
      if (response.text != null && response.text!.isNotEmpty) {
        messages.add(ChatMessage(text: response.text!, isUser: false));
      }
    } catch (e) {
      // Silently fail the initial greeting if it errors out
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    textController.clear();
    messages.add(ChatMessage(text: text, isUser: true));
    _scrollToBottom();
    isLoading.value = true;

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      if (response.text != null) {
        messages.add(ChatMessage(text: response.text!, isUser: false));
        _scrollToBottom();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
