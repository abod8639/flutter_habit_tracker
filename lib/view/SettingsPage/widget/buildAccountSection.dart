
  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/auth_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/SettingsPage/SettingsPage.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSectionHeader.dart';
import 'package:habit_tracker/view/SettingsPage/widget/buildAnimatedSettingTile.dart';

Widget buildAccountSection(AuthController authController , AnimationController _animationController) {
    return Builder(
      builder: (context) {
        return Obx(() {
          final user = authController.currentUser;
          if (user != null) {
            return Column(
              children: [
                buildAnimatedSectionHeader(
                  _animationController,
                  context,
                  S.current.account,
                  0,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ?? S.current.user,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email ?? '',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.8),
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                buildAnimatedSettingTile(
                  animationController: _animationController,
                  context,
                  index: 1,
                  icon: Icons.logout_rounded,
                  title: S.current.logout,
                  subtitle: S.current.logoutFromAccount,
                  textColor: Colors.red,
                  onTap: () => showLogoutDialog(authController),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                buildAnimatedSectionHeader(
                  _animationController,
                  context,
                  S.current.account,
                  0,
                ),
                buildAnimatedSettingTile(
                  animationController: _animationController,
                  context,
                  index: 1,
                  icon: Icons.login_rounded,
                  title: S.current.loginToAccount,
                  subtitle: S.current.loginToEnableSync,
                  onTap: () => navigateToLogin(),
                ),
              ],
            );
          }
        });
      }
    );
  }
