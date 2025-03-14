import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeController extends GetxController {
  // Constants for Hive storage
  static const String themeBox = "Theme_db";
  static const String themeNameKey = "current_theme";
  static const String themeModeKey = "theme_mode";
  static const String useCustomBgKey = "use_custom_bg";
  static const String customBgColorKey = "custom_bg_color";
  
  // Default theme
  static const String defaultTheme = 'github_dark_green';

  // ثوابت الألوان للثيمات المختلفة
  static const Map<String, Map<String, Color>> themeColors = {
    'github_dark_green': {
      'primary': Color(0xFF3FB950), 
      'secondary': Color(0xFF161B22), 
      'background': Color(0xFF0D1117),
      'surface': Color(0xFF161B22), 
      'error': Color(0xFFFA4549), 
      'onPrimary': Color(0xFF0D1117),
      'onSecondary': Color(0xFFFFFFFF),
    },
    'github': {
      'primary': Color.fromARGB(255, 0, 102, 220), 
      'secondary': Color.fromARGB(255, 92, 140, 182),
      'background': Color(0xFFFFFFFF),
      'surface': Color(0xFFFFFFFF), 
      'error': Color(0xFFD73A49), 
      'onPrimary': Color(0xFFFFFFFF),
      'onSecondary': Color(0xFF000000),
    },
    'github_dark': {
      'primary': Color.fromARGB(255, 0, 109, 233), 
      'secondary': Color(0xFF161B22),
      'background': Color(0xFF0D1117),
      'surface': Color(0xFF161B22), 
      'error': Color(0xFFFA4549), 
      'onPrimary': Color(0xFF0D1117),
      'onSecondary': Color(0xFFFFFFFF),
    },
    'aquarium': {
      'primary': Color(0xFF1A73E8),
      'secondary': Color(0xFF03DAC6),
      'background': Color(0xFFE0F7FA),
      'surface': Color(0xFFFFFFFF),
      'error': Color(0xFFB00020),
      'onPrimary': Color(0xFFFFFFFF),
      'onSecondary': Color(0xFF000000),
    },
    'midnight': {
      'primary': Color(0xFF6200EE),
      'secondary': Color(0xFF03DAC6),
      'background': Color(0xFF121212),
      'surface': Color(0xFF1E1E1E),
      'error': Color(0xFFCF6679),
      'onPrimary': Color.fromARGB(255, 173, 173, 173),
      'onSecondary': Color(0xFF000000),
    },
    // Other themes remain unchanged
    'forest': {
      'primary': Color(0xFF2E7D32),
      'secondary': Color(0xFF81C784),
      'background': Color(0xFFE8F5E9),
      'surface': Color(0xFFFFFFFF),
      'error': Color(0xFFB00020),
      'onPrimary': Color.fromARGB(255, 135, 135, 135),
      'onSecondary': Color(0xFF000000),
    },
    'sunset': {
      'primary': Color(0xFFFF9800),
      'secondary': Color(0xFFFF5722),
      'background': Color(0xFFFFF3E0),
      'surface': Color(0xFFFFFFFF),
      'error': Color(0xFFB00020),
      'onPrimary': Color(0xFF000000),
      'onSecondary': Color(0xFFFFFFFF),
    },
    'lavender': {
      'primary': Color(0xFF7E57C2),
      'secondary': Color(0xFFB39DDB),
      'background': Color(0xFFEDE7F6),
      'surface': Color(0xFFFFFFFF),
      'error': Color(0xFFB00020),
      'onPrimary': Color(0xFFFFFFFF),
      'onSecondary': Color(0xFF000000),
    },
    'ruby': {
      'primary': Color(0xFFC2185B),
      'secondary': Color(0xFFF48FB1),
      'background': Color(0xFFFCE4EC),
      'surface': Color(0xFFFFFFFF),
      'error': Color(0xFFB00020),
      'onPrimary': Color(0xFFFFFFFF),
      'onSecondary': Color(0xFF000000),
    },
    'mint': {
      'primary': Color(0xFF009688),
      'secondary': Color(0xFF80CBC4),
      'background': Color(0xFFE0F2F1),
      'surface': Color(0xFFFFFFFF),
      'error': Color(0xFFB00020),
      'onPrimary': Color(0xFFFFFFFF),
      'onSecondary': Color(0xFF000000),
    },
    'gold': {
      'primary': Color(0xFFFFC107),
      'secondary': Color(0xFFFFD54F),
      'background': Color(0xFFFFF8E1),
      'surface': Color(0xFFFFFFFF),
      'error': Color(0xFFB00020),
      'onPrimary': Color(0xFF000000),
      'onSecondary': Color(0xFF000000),
    },
    'carbon': {
      'primary': Color(0xFF424242),
      'secondary': Color(0xFF757575),
      'background': Color(0xFF303030),
      'surface': Color(0xFF424242),
      'error': Color(0xFFCF6679),
      'onPrimary': Color(0xFFFFFFFF),
      'onSecondary': Color(0xFFFFFFFF),
    },
    'catppuccin': {
      'primary': Color.fromARGB(255, 142, 201, 250), 
      'secondary': Color.fromARGB(255, 201, 158, 254),
      'background': Color(0xFF1E1E2E), 
      'surface': Color(0xFF313244), 
      'error': Color(0xFFF28FAD), 
      'onPrimary': Color(0xFF1E1E2E),
      'onSecondary': Color(0xFFFFFFFF),
    },
    'catppuccin_latte': { 
      'primary': Color(0xFF7287FD), 
      'secondary': Color.fromARGB(255, 156, 170, 250),
      'background': Color(0xFFEFF1F5), 
      'surface': Color(0xFFDCE0E8), 
      'error': Color(0xFFD20F39), 
      'onPrimary': Color(0xFFFFFFFF), 
      'onSecondary': Color(0xFF000000), 
    },
    'catppuccin_frappe': { 
      'primary': Color.fromARGB(255, 122, 157, 239), // أزرق سماوي
      'secondary': Color(0xFFEF9F76), // برتقالي دافئ
      'background': Color(0xFF303446), // رمادي داكن
      'surface': Color(0xFF414559), // رمادي أفتح قليلاً
      'error': Color(0xFFE78284), // أحمر دافئ
      'onPrimary': Color(0xFF1E1E2E), // داكن على الأساسي
      'onSecondary': Color(0xFFFFFFFF), // أبيض على الثانوي
    },
    'catppuccin_macchiato': { // داكن مائل للأرجواني
      'primary': Color.fromARGB(255, 147, 158, 252), // أزرق بنفسجي
      'secondary': Color(0xFFF5BDE6), // وردي ناعم
      'background': Color(0xFF24273A), // بنفسجي غامق
      'surface': Color(0xFF363A4F), // سطح أفتح
      'error': Color(0xFFED8796), // أحمر ناعم
      'onPrimary': Color(0xFF1E1E2E), // داكن على الأساسي
      'onSecondary': Color(0xFFFFFFFF), // أبيض على الثانوي
    },
    'catppuccin_mocha': { // داكن عميق
      'primary': Color.fromARGB(255, 114, 189, 251), 
      'secondary': Color.fromARGB(255, 188, 133, 255), 
      'background': Color(0xFF1E1E2E), 
      'surface': Color(0xFF313244), 
      'error': Color(0xFFF28FAD), 
      'onPrimary': Color(0xFF1E1E2E), 
      'onSecondary': Color(0xFFFFFFFF), 
    },
    'dracula': {
      'primary': Color.fromARGB(255, 174, 118, 252), 
      'secondary': Color.fromARGB(255, 177, 162, 252), 
      'background': Color(0xFF282A36), 
      'surface': Color(0xFF44475A), 
      'error': Color(0xFFFF5555), 
      'onPrimary': Color(0xFF1E1E2E), 
      'onSecondary': Color(0xFFFFFFFF), 
    },
    'nord': {
      'primary': Color.fromARGB(255, 108, 187, 209),
      'secondary': Color(0xFF81A1C1), 
      'background': Color(0xFF2E3440), 
      'surface': Color(0xFF3B4252), 
      'error': Color(0xFFD08770), 
      'onPrimary': Color(0xFF2E3440), 
      'onSecondary': Color(0xFFFFFFFF), 
    },
    'tokyo_night': {
      'primary': Color(0xFF7AA2F7), 
      'secondary': Color.fromARGB(255, 106, 206, 173), 
      'background': Color(0xFF1A1B26), 
      'surface': Color(0xFF2E3440), 
      'error': Color(0xFFF7768E), 
      'onPrimary': Color(0xFF1A1B26), 
      'onSecondary': Color(0xFFFFFFFF), 
    },
    'one_dark': {
      'primary': Color(0xFFE06C75), 
      'secondary': Color.fromARGB(255, 109, 197, 178), 
      'background': Color(0xFF282C34), 
      'surface': Color(0xFF3E4451), 
      'error': Color(0xFFBE5046), 
      'onPrimary': Color(0xFF282C34), 
      'onSecondary': Color(0xFFFFFFFF), 
    },
  'sunset_theme': {
  'primary': Color(0xFFFF6B6B), 
  'secondary': Color.fromARGB(255, 252, 162, 45), 
  'background': Color(0xFF2E1A47),
  'surface': Color(0xFF3B2F5C), 
  'error': Color(0xFFD72638), 
  'onPrimary': Color(0xFF2E1A47),
  'onSecondary': Color(0xFFFFFFFF),
},
'cyberpunk_neon': {
  'primary': Color(0xFFFF007F), // وردي نيون
  'secondary': Color.fromARGB(255, 123, 0, 255), // أزرق سماوي نيون
  'background': Color(0xFF050A30), // كحلي داكن جدًا
  'surface': Color(0xFF0A0F48), // كحلي فاتح
  'error': Color(0xFFFF1744), // أحمر نيون
  'onPrimary': Color(0xFF050A30), // داكن للتباين
  'onSecondary': Color(0xFFFFFFFF), // أبيض للوضوح
},
  'hologram': {
  'primary': Color(0xFF29B6F6), // أزرق سماوي فاتح  
  'secondary': Color.fromARGB(255, 135, 71, 188), // بنفسجي فاتح  
  'background': Color(0xFF0F172A), // أزرق داكن جدًا  
  'surface': Color(0xFF1E293B), // رمادي مزرق  
  'error': Color(0xFFFF5252), // أحمر ساطع  
  'onPrimary': Color(0xFFFFFFFF), // أبيض للوضوح  
  'onSecondary': Color(0xFF0F172A), // داكن للتباين  
},
'cyber_grid': {
  'primary': Color(0xFF8A2BE2), // بنفسجي كهربائي
  'secondary': Color.fromARGB(255, 0, 238, 255), // أخضر نيون
  'background': Color(0xFF050A30), // كحلي غامق
  'surface': Color(0xFF0A0F48), // أزرق داكن  
  'error': Color(0xFFFF1744), // أحمر ساطع
  'onPrimary': Color(0xFF050A30), // داكن للتباين
  'onSecondary': Color(0xFFFFFFFF), // أبيض للوضوح
},
'neo_tokyo': {
  'primary': Color(0xFF00FFFF), // سماوي نيون
  'secondary': Color.fromARGB(255, 162, 0, 255), // بنفسجي نيون
  'background': Color(0xFF0D0D0D), // أسود داكن جدًا
  'surface': Color(0xFF1A1A1A), // رمادي داكن
  'error': Color(0xFFFF1744), // أحمر نيون
  'onPrimary': Color(0xFF0D0D0D), // أسود للتباين
  'onSecondary': Color(0xFFFFFFFF), // أبيض للوضوح
},
'neon_circuit': {
  'primary': Color(0xFF00FFAA), // أخضر تركواز نيون  
  'secondary': Color.fromARGB(255, 68, 215, 255), // أصفر نيون  
  'background': Color(0xFF101820), // أزرق داكن جدًا  
  'surface': Color(0xFF1A2930), // رمادي مائل للأزرق  
  'error': Color(0xFFFF1744), // أحمر نيون  
  'onPrimary': Color(0xFF101820), // داكن للتباين  
  'onSecondary': Color(0xFFFFFFFF), // أبيض للوضوح  
},
'futuristic_space': {
  'primary': Color(0xFF3D5AFE), // أزرق نيوني  
  'secondary': Color.fromARGB(255, 201, 64, 255), // وردي نيون  
  'background': Color(0xFF000014), // أسود مائل للكحلي  
  'surface': Color(0xFF1A237E), // أزرق ملكي  
  'error': Color(0xFFD50000), // أحمر غامق  
  'onPrimary': Color(0xFFFFFFFF), // أبيض  
  'onSecondary': Color(0xFF000014), // داكن للتباين  
},
  
  };

  // متغير لتخزين وضع الثيم الحالي
  var themeMode = ThemeMode.light.obs;

  // متغير لتخزين السمة المخصصة الحالية
  var currentTheme = defaultTheme.obs;

  // متغير لتخزين لون الخلفية المخصص الحالي
  var customBackgroundColor = Colors.transparent.obs;

  // متغير لتحديد إذا كان يتم استخدام لون خلفية مخصص
  var useCustomBackground = false.obs;

  // متغير لتخزين الثيم الفاتح والداكن
  var lightTheme = Rx<ThemeData>(ThemeData.light());
  var darkTheme = Rx<ThemeData>(ThemeData.dark());

  // Hive box reference
  Box? _themeBox;

  // الحصول على قائمة أسماء الثيمات المتاحة
  List<String> get availableThemes => themeColors.keys.toList();

  @override
  void onInit() {
    super.onInit();
    _initializeTheme();
  }

  // Initialize theme from storage
  Future<void> _initializeTheme() async {
    // Get or create the theme box
    if (!Hive.isBoxOpen(themeBox)) {
      try {
        _themeBox = await Hive.openBox(themeBox);
      } catch (e) {
        print("Error opening theme box: $e");
        // If error occurs, just use default values
        _setDefaultTheme();
        return;
      }
    } else {
      _themeBox = Hive.box(themeBox);
    }

    // Load saved theme settings or use defaults
    _loadSavedTheme();
  }

  // Load the theme from Hive storage
  void _loadSavedTheme() {
    try {
      // Get theme name or use default
      String savedTheme = _themeBox?.get(themeNameKey, defaultValue: defaultTheme) ?? defaultTheme;
      
      // Make sure the saved theme exists in our color maps
      if (!themeColors.containsKey(savedTheme)) {
        savedTheme = defaultTheme;
      }
      
      // Set the theme values
      currentTheme.value = savedTheme;
      
      // Get theme mode
      String? themeModeStr = _themeBox?.get(themeModeKey);
      // if (themeModeStr == "ThemeMode.dark") {
      //   themeMode.value = ThemeMode.dark;
    themeModeStr == "ThemeMode.light" ;
        themeMode.value = ThemeMode.light;
      // } else {
      //   themeMode.value = ThemeMode.system;
      // }
      
      // Get custom background settings
      useCustomBackground.value = _themeBox?.get(useCustomBgKey, defaultValue: false) ?? false;
      
      if (useCustomBackground.value) {
        int? bgColor = _themeBox?.get(customBgColorKey);
        if (bgColor != null) {
          customBackgroundColor.value = Color(bgColor);
        }
        update();
      }
      
      // Build and apply the theme
      _buildBothThemes();
      _applyTheme();
    } catch (e) {
      print("Error loading saved theme: $e");
      _setDefaultTheme();
    }
  }

  // Set default theme values
  void _setDefaultTheme() {
    currentTheme.value = defaultTheme;
    themeMode.value = ThemeMode.system;
    useCustomBackground.value = false;
    _buildBothThemes();
    _applyTheme();
    update();
  }

  // Save theme settings to Hive
  void _saveThemeSettings() {
    try {
      if (_themeBox != null) {
        _themeBox!.put(themeNameKey, currentTheme.value);
        _themeBox!.put(themeModeKey, themeMode.value.toString());
        _themeBox!.put(useCustomBgKey, useCustomBackground.value);
        
        if (useCustomBackground.value) {
          _themeBox!.put(customBgColorKey, customBackgroundColor.value.value);
        }
        
      }
    } catch (e) {
      print("Error saving theme settings: $e");
    }
    update();
  }

  // دالة لتغيير وضع الثيم
  void changeThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _buildBothThemes(); // تأكد من إعادة بناء الثيمات عند تغيير الوضع
    _applyTheme();
    _saveThemeSettings(); // Save to Hive
    update();
  }

  void changeCustomTheme(String themeName) {
    if (themeColors.containsKey(themeName)) {
      currentTheme.value = themeName;
      _buildBothThemes();
      _applyTheme();
      _saveThemeSettings(); // Save to Hive
      update();
    } else {
      Get.snackbar('Error', 'Theme not found');
      update();
    }
  }

  // دالة لتغيير لون الخلفية
  void changeBackgroundColor(Color color) {
    customBackgroundColor.value = color;
    useCustomBackground.value = true;
    _buildBothThemes();
    _applyTheme();
    _saveThemeSettings(); // Save to Hive
    update();
  }

  // دالة لإعادة ضبط لون الخلفية إلى القيمة الافتراضية للثيم
  void resetBackgroundColor() {
    useCustomBackground.value = false;
    _buildBothThemes();
    _applyTheme();
    _saveThemeSettings(); // Save to Hive
    update();
  }

  // تطبيق الثيم الحالي
  void _applyTheme() {
    Get.changeThemeMode(themeMode.value);

    // قم بالتحديث بشكل صحيح عند التبديل بين الفاتح والداكن
    final newTheme = themeMode.value == ThemeMode.system ? darkTheme.value : lightTheme.value;
    Get.changeTheme(newTheme);

    print("Applied Theme: ${themeMode.value}, ${currentTheme.value}");
    update();
  }

  // بناء كلا النوعين من الثيمات (الفاتح والداكن)
  void _buildBothThemes() {
    lightTheme.value = _buildThemeData(forceDark: false);
    
    darkTheme.value = _buildThemeData(forceDark: false);
    update();
  }

  // بناء الثيم بناءً على المعلمات المقدمة
  ThemeData _buildThemeData({required bool forceDark}) {
    // التحقق من وجود الثيم المحدد
    final themeName = themeColors.containsKey(currentTheme.value)
        ? currentTheme.value
        : defaultTheme;
    
    // الحصول على ألوان الثيم
    final colors = themeColors[themeName]!;
    
    // تحديد سطوع الثيم
    final brightness = forceDark ? Brightness.dark : Brightness.light;
    
    // تحديد لون الخلفية النهائي
    Color backgroundColor;
    if (useCustomBackground.value) {
      backgroundColor = customBackgroundColor.value;
    } else if (forceDark) {
      // إذا كان الوضع داكن، استخدم لون خلفية مناسب للوضع الداكن
      if (themeName == 'midnight' || themeName == 'carbon') {
        // استخدم الألوان الداكنة المحددة مسبقًا للثيمات الداكنة
        backgroundColor = colors['background']!;
      } else {
        // للثيمات الفاتحة الأخرى، استخدم نسخة داكنة من اللون
        backgroundColor = colors['background']!.withBrightness(0.2);
      }
    } else {
      // الوضع الفاتح، استخدم لون الخلفية المحدد
      backgroundColor = colors['background']!;
    }
    
    // تحديد لون السطح المناسب للوضع
    Color surfaceColor;
    if (forceDark) {
      if (themeName == 'midnight' || themeName == 'carbon') {
        // استخدم الألوان الداكنة المحددة مسبقًا للثيمات الداكنة
        surfaceColor = colors['surface']!;
      } else {
        // للثيمات الفاتحة الأخرى، استخدم نسخة داكنة من اللون
        surfaceColor = colors['surface']!.withBrightness(0.2);
      }
    } else {
      // الوضع الفاتح، استخدم لون السطح المحدد
      surfaceColor = colors['surface']!;
    }
    
    // حدد اللون المقابل للنص بناءً على لون الخلفية
    final onSurfaceColor = _contrastColorFor(surfaceColor);
    final onBackgroundColor = _contrastColorFor(backgroundColor);
    
    return ThemeData(
      brightness: brightness,
      primaryColor: colors['primary'],
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors['primary']!,
        onPrimary: colors['onPrimary']!,
        secondary: colors['secondary']!,
        onSecondary: colors['onSecondary']!,
        error: colors['error']!,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors['primary'],
        foregroundColor: colors['onPrimary'],
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        shadowColor: colors['primary']!.withOpacity(0.3),
        elevation: 3,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors['secondary'],
        foregroundColor: colors['onSecondary'],
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colors['onPrimary'],
          backgroundColor: colors['primary'],
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return colors['primary']!;
          }
          return Colors.grey;
        }),
        checkColor: WidgetStateProperty.all(colors['onPrimary']),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: backgroundColor.withOpacity(0.8),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors['primary']!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors['primary']!, width: 2),
        ),
      ),
      textTheme: _createTextTheme(brightness, onBackgroundColor),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        titleTextStyle: TextStyle(color: onSurfaceColor, fontSize: 20, fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(color: onSurfaceColor, fontSize: 16),
      ),
      // إضافة سمات إضافية للتأكد من تطبيق الألوان بشكل صحيح في الوضع الداكن
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: colors['primary'],
        unselectedItemColor: onSurfaceColor.withOpacity(0.6),
      ),
      iconTheme: IconThemeData(
        color: onBackgroundColor,
      ),
      primaryIconTheme: IconThemeData(
        color: colors['onPrimary'],
      ),
    );
  }

  // إنشاء سمة النص المناسبة
  TextTheme _createTextTheme(Brightness brightness, Color textColor) {
    final baseTextTheme = brightness == Brightness.dark 
        ? ThemeData.dark().textTheme 
        : ThemeData.light().textTheme;
    
    return baseTextTheme.apply(
      bodyColor: textColor,
      displayColor: textColor,
    );
  }

  // الحصول على لون متباين للنص بناءً على لون الخلفية
  Color _contrastColorFor(Color backgroundColor) {
    return _shouldUseDarkTheme(backgroundColor) ? Colors.white : Colors.black;
    
  }

  // تحديد ما إذا كان ينبغي استخدام ثيم داكن بناءً على لون الخلفية
  bool _shouldUseDarkTheme(Color backgroundColor) {
    // حساب متوسط مكونات RGB للون
    double brightness = (backgroundColor.red * 299 +
            backgroundColor.green * 587 +
            backgroundColor.blue * 114) /
        1000;
    // إذا كان متوسط السطوع أقل من 128، نستخدم ثيم داكن
    return brightness < 138;
  }

  // الحصول على بيانات الثيم الحالي
  Map<String, dynamic> getCurrentThemeInfo() {
    final themeName = currentTheme.value;
    final themeColors = ThemeController.themeColors[themeName];
    if (themeColors == null) return {};
    
    return {
      'name': themeName,
      'mode': themeMode.value.toString(),
      'primaryColor': themeColors['primary'].toString(),
      'secondaryColor': themeColors['secondary'].toString(),
      'backgroundColor': useCustomBackground.value
          ? customBackgroundColor.value.toString()
          : themeColors['background'].toString(),
      'isDarkMode': themeMode.value == ThemeMode.dark || 
        (themeMode.value == ThemeMode.system && 
         WidgetsBinding.instance.window.platformBrightness == Brightness.dark),
    };
  }
}

// إضافة امتداد للون لتغيير سطوعه
extension ColorBrightness on Color {
  Color withBrightness(double brightness) {
    assert(brightness >= 0 && brightness <= 1, 'Brightness must be between 0 and 1');
    return HSLColor.fromColor(this)
        .withLightness(brightness)
        .toColor();
  }
}
