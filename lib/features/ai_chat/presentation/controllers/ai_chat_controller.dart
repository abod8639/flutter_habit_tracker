import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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
      final today = createDateTimeObject(todayStr);
      final int completedCount = habits.where((h) => h.isCompleted).length;
      final int totalCount = habits.length;
      
      final completionRate = totalCount == 0 ? 0 : (completedCount / totalCount * 100).toInt();

      String habitsContext = "User has no habits currently tracked.";
      if (habits.isNotEmpty) {
        habitsContext = habits.map((h) => "- ${h.name} (${h.isCompleted ? 'Completed' : 'Not completed'})").join("\n");
      }

      final systemInstruction = '''
You are a highly empathetic, encouraging, and psychological support coach integrated into a Habit Tracker app.
Your goal is to motivate the user to achieve their goals, build strong habits, and offer psychological support when they feel down or unmotivated.

Here is the context about the user's habits for today ($todayStr):
Total Habits: $totalCount
Completed: $completedCount ($completionRate%)
List of habits:
$habitsContext

Keep your responses concise, friendly, and highly motivating. Adapt your language to the user's input language (especially if they use Arabic, respond in fluent Arabic).
If the completion rate is low, encourage them to take a small step. If it's high, praise their consistency and discipline.
''';

      _chatSession = _geminiService.startChat(systemInstruction: systemInstruction);
      
      // Initial greeting from AI based on their progress
      // We send a hidden prompt to generate the first greeting
      _generateInitialGreeting();
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize chat: $e');
    }
  }

  Future<void> _generateInitialGreeting() async {
    isLoading.value = true;
    try {
      final isArabic = Get.locale?.languageCode == 'ar';
      final prompt = isArabic 
          ? "مرحباً. يرجى التعريف بنفسك باختصار كمدرب ذكاء اصطناعي خاص بي والتعليق على تقدم عاداتي اليوم."
          : "Hello. Please introduce yourself briefly as my AI coach and comment on my habit progress today.";
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
