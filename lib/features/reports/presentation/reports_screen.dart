import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ReportsScreen
    extends StatelessWidget {
  const ReportsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;
    final scaffoldBg = isDark
        ? AppColors
              .darkBackground
        : const Color(
            0xffF6F8FB,
          );
    final cardBg = isDark
        ? AppColors.darkCard
        : Colors.white;
    final cardBorder = isDark
        ? AppColors.darkBorder
        : const Color(
            0xffE5E7EB,
          );

    return Scaffold(
      backgroundColor:
          scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Reports',
        ),
        backgroundColor:
            scaffoldBg,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(
                  20,
                ),
            child: Container(
              width: double
                  .infinity,
              padding:
                  const EdgeInsets.all(
                    24,
                  ),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius:
                    BorderRadius.circular(
                      24,
                    ),
                border: Border.all(
                  color:
                      cardBorder,
                ),
                boxShadow:
                    isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(
                            10,
                          ),
                          blurRadius:
                              18,
                          offset: const Offset(
                            0,
                            8,
                          ),
                        ),
                      ],
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize
                        .min,
                children: [
                  Container(
                    width: 62,
                    height:
                        62,
                    decoration: BoxDecoration(
                      color: AppColors
                          .primary
                          .withAlpha(
                            24,
                          ),
                      shape: BoxShape
                          .circle,
                    ),
                    child: const Icon(
                      Icons
                          .bar_chart_rounded,
                      color: AppColors
                          .primary,
                      size:
                          34,
                    ),
                  ),
                  const SizedBox(
                    height:
                        16,
                  ),
                  Text(
                    'Reports',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w900,
                        ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Reports and analytics will be available here soon.',
                    textAlign:
                        TextAlign
                            .center,
                    style: TextStyle(
                      color:
                          isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.littleGrey,
                      height:
                          1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
