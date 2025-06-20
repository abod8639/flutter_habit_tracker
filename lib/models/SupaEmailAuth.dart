import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class SupaEmailAuthWidget extends StatefulWidget {
  const SupaEmailAuthWidget({super.key});

  @override
  State<SupaEmailAuthWidget> createState() => _SupaEmailAuthWidgetState();
}

class _SupaEmailAuthWidgetState extends State<SupaEmailAuthWidget> {
  @override
  Widget build(BuildContext context) {
    return SupaEmailAuth(
      redirectTo: kIsWeb ? null : 'io.mydomain.myapp://callback',
      onSignInComplete: (response) {},
      onSignUpComplete: (response) {},
      metadataFields: [
        MetaDataField(
          prefixIcon: const Icon(Icons.person),
          label: 'Username',
          key: 'username',
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Please enter something';
            }
            return null;
          },
        ),
      ],
    );
  }
}
