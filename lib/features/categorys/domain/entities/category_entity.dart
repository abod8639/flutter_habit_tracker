import 'package:flutter/material.dart';

enum PlanCategory {
  sports,
  nutrition,
  study,
  learning;

  String get displayName {
    switch (this) {
      case PlanCategory.sports:
        return 'Sports & Fitness';
      case PlanCategory.nutrition:
        return 'Nutrition';
      case PlanCategory.study:
        return 'Study';
      case PlanCategory.learning:
        return 'Learn a New Skill';
    }
  }

  String get description {
    switch (this) {
      case PlanCategory.sports:
        return 'Build a consistent fitness routine';
      case PlanCategory.nutrition:
        return 'Improve your diet and reach your health goals';
      case PlanCategory.study:
        return 'Boost your academic performance';
      case PlanCategory.learning:
        return 'Master any skill step by step';
    }
  }

  IconData get icon {
    switch (this) {
      case PlanCategory.sports:
        return Icons.fitness_center_rounded;
      case PlanCategory.nutrition:
        return Icons.restaurant_rounded;
      case PlanCategory.study:
        return Icons.menu_book_rounded;
      case PlanCategory.learning:
        return Icons.lightbulb_rounded;
    }
  }

  Color get color {
    switch (this) {
      case PlanCategory.sports:
        return const Color(0xFF3B82F6);
      case PlanCategory.nutrition:
        return const Color(0xFF10B981);
      case PlanCategory.study:
        return const Color(0xFF8B5CF6);
      case PlanCategory.learning:
        return const Color(0xFFF59E0B);
    }
  }

  /// Used in AI prompt construction
  String get coachRole {
    switch (this) {
      case PlanCategory.sports:
        return 'certified personal trainer and fitness coach';
      case PlanCategory.nutrition:
        return 'registered dietitian and nutrition coach';
      case PlanCategory.study:
        return 'expert academic coach and learning strategist';
      case PlanCategory.learning:
        return 'professional skill development coach';
    }
  }
}
