import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../story/models.dart';
import 'router.dart';

class Nav {
  const Nav._();

  static void toRegister(BuildContext context) {
    context.pushNamed(AppRouteName.register);
  }

  static void toForgotPassword(BuildContext context) {
    context.pushNamed(AppRouteName.forgotPassword);
  }

  static void toResetSent(BuildContext context) {
    context.pushNamed(AppRouteName.resetSent);
  }

  static void toSetup(BuildContext context) {
    context.pushNamed(AppRouteName.setup);
  }

  static void toMyStories(BuildContext context) {
    context.pushNamed(AppRouteName.myStories);
  }

  static void toStoryPreferences(BuildContext context) {
    context.pushNamed(AppRouteName.storyPreferences);
  }

  static void toSettings(BuildContext context) {
    context.pushNamed(AppRouteName.settings);
  }

  static void toAccount(BuildContext context) {
    context.pushNamed(AppRouteName.account);
  }

  static void toStoryReader(BuildContext context, StoryRecord story) {
    context.pushNamed(AppRouteName.storyReader, extra: story);
  }

  static void resetToHome(BuildContext context) {
    context.goNamed(AppRouteName.home);
  }

  static void resetToLogin(BuildContext context) {
    context.goNamed(AppRouteName.login);
  }

  static void backOrLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    resetToLogin(context);
  }
}
