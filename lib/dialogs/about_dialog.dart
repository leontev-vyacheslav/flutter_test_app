import 'package:eta_regulator_board_admin_toolbox/components/app_elevated_button.dart';
import 'package:eta_regulator_board_admin_toolbox/constants/app_colors.dart';
import 'package:eta_regulator_board_admin_toolbox/constants/app_strings.dart';
import 'package:eta_regulator_board_admin_toolbox/dialogs/app_base_dialog.dart';
import 'package:flutter/material.dart';

class AboutDialog extends AppBaseDialog {
  const AboutDialog({super.key, required super.context, required super.titleText});

  @override
  List<Widget> get actions => [
        AppElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const AppElevatedButtonLabel(
            label: AppStrings.buttonClose,
            icon: Icons.close,
          ),
        )
      ];

  @override
  Widget get content => SizedBox(
        width: 460,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset('assets/images/icon.ico'),
            const SizedBox(width: 10),
            const Flexible(
                child: Text(
              maxLines: 2,
              overflow: TextOverflow.clip,
              '${AppStrings.appTitle} ${AppStrings.appVersion}',
              style: TextStyle(color: AppColors.textAccent),
            ))
          ],
        ),
      );
}
