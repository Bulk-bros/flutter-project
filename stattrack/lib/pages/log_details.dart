import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stattrack/components/buttons/secondary_button.dart';
import 'package:stattrack/components/app/custom_app_bar.dart';
import 'package:stattrack/components/buttons/main_button.dart';
import 'package:stattrack/components/cards/clickable_card.dart';
import 'package:stattrack/components/cards/single_stat_card.dart';
import 'package:stattrack/components/forms/form_fields/image_picker_input.dart';
import 'package:stattrack/components/meals/meal_card.dart';
import 'package:stattrack/components/stats/single_stat_layout.dart';
import 'package:stattrack/pages/settings_pages/change_password_page.dart';
import 'package:stattrack/pages/user_profile_page.dart';
import 'package:stattrack/providers/repository_provider.dart';
import 'package:stattrack/services/auth.dart';
import 'package:stattrack/services/repository.dart';
import 'package:stattrack/styles/font_styles.dart';
import 'package:stattrack/styles/palette.dart';

import '../models/consumed_meal.dart';

class LogDetails extends StatelessWidget {
  LogDetails({Key? key, required this.meals, required this.time})
      : super(key: key);

  List<ConsumedMeal> meals;
  String time;

  final spacing = const SizedBox(
    height: 5,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          headerTitle: time,
        ),
        body: _buildBody());
  }

  Widget _buildBody() {
    num calories = 0;
    num fat = 0;
    num proteins = 0;
    num carbs = 0;

    for (ConsumedMeal meal in meals) {
      calories += meal.calories;
      proteins += meal.proteins;
      carbs += meal.carbs;
      fat += meal.fat;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      // Column separating all settings from logout button
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderText("Overview"),
                spacing,
                SingleStatCard(
                  color: Palette.accent[400],
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SingleStatLayout(
                        color: Colors.white,
                        categoryText: "Calories",
                        amountText: "${calories}g",
                      ),
                      SingleStatLayout(
                        color: Colors.white,
                        categoryText: "proteins",
                        amountText: "${proteins}g",
                      ),
                      SingleStatLayout(
                        color: Colors.white,
                        categoryText: "fat",
                        amountText: "${fat}g",
                      ),
                      SingleStatLayout(
                        color: Colors.white,
                        categoryText: "carbs",
                        amountText: "${carbs}g",
                      ),
                    ],
                  ),
                  size: 75,
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderText("Meals"),
                spacing,
                ...meals.map(
                  (meal) => Column(
                    children: [
                      MealCard(
                          meal: meal,
                          timeValue:
                              " ${meal.time.day}.${meal.time.month}.${meal.time.year} ${meal.time.hour}:${meal.time.minute}",
                          onPressed: (meal) {}),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: FontStyles.fsBody, fontWeight: FontStyles.fwTitle),
    );
  }
}
