import 'package:flutter/material.dart';
import 'package:pora/core/features/tutorial/presentation/screen/steps/add_step.dart';
import 'package:pora/core/features/tutorial/presentation/screen/steps/connect_step.dart';
import 'package:pora/core/features/tutorial/presentation/screen/steps/delete_step.dart';
import 'package:pora/core/features/tutorial/presentation/screen/steps/edit_step.dart';
import 'package:pora/core/features/tutorial/presentation/screen/steps/invite_step.dart';
import 'package:pora/core/features/tutorial/presentation/screen/steps/notify_step.dart';
import 'package:pora/core/features/tutorial/presentation/screen/steps/outro_step.dart';
import 'package:pora/core/features/tutorial/presentation/screen/steps/recipe_step.dart';
import 'package:pora/core/features/tutorial/presentation/screen/steps/settings_step.dart';

/// Диспетчер шагов. Индекс должен совпадать с порядком в
/// `TutorialPage._steps` (текст title/body для того же индекса).
class TutorialIllustration extends StatelessWidget {
  const TutorialIllustration({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: switch (step) {
        0 => const InviteStep(),
        1 => const ConnectStep(),
        2 => const AddStep(),
        3 => const EditStep(),
        4 => const NotifyStep(),
        5 => const DeleteStep(),
        6 => const RecipeStep(),
        7 => const SettingsStep(),
        _ => const OutroStep(),
      },
    );
  }
}
