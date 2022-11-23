import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stattrack/components/buttons/main_button.dart';
import 'package:stattrack/components/meals/meal_card.dart';
import 'package:stattrack/models/meal.dart';
import 'package:stattrack/providers/auth_provider.dart';
import 'package:stattrack/providers/repository_provider.dart';
import 'package:stattrack/services/auth.dart';
import 'package:stattrack/services/repository.dart';
import 'package:stattrack/styles/palette.dart';

class AddMealSelect extends ConsumerStatefulWidget {
  const AddMealSelect({Key? key, required this.meals}) : super(key: key);

  final List<Meal> meals;
  @override
  _AddMealSelectState createState() => _AddMealSelectState();
}

class _AddMealSelectState extends ConsumerState<AddMealSelect> {
  Meal? activeMeal;
  String? errorMsg;

  void _updateAcitveMeal(Meal meal) {
    setState(() {
      activeMeal = meal;
    });
  }

  void _logMeal(BuildContext context, String uid, Repository repo) {
    try {
      repo.logMeal(meal: activeMeal!, uid: uid);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMsg = "Something wen't wrong... Please try again";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthBase auth = ref.read(authProvider);
    final Repository repo = ref.read(repositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ...widget.meals.map(
                (meal) {
                  return Column(
                    children: <Widget>[
                      MealCard(
                        meal: meal,
                        onPressed: (m) => _updateAcitveMeal(m),
                        backgroundColor:
                            activeMeal == meal ? Palette.accent[400] : null,
                        color: activeMeal == meal ? Colors.white : null,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        ),
        MainButton(
          callback: activeMeal == null
              ? null
              : () => _logMeal(context, auth.currentUser!.uid, repo),
          label: 'Eat Meal',
        ),
        Text(
          errorMsg != null ? errorMsg! : '',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}