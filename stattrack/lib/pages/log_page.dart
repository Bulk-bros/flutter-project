import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stattrack/components/custom_app_bar.dart';
import 'package:stattrack/components/custom_bottom_bar.dart';
import 'package:stattrack/components/stats/stat_card.dart';
import 'package:stattrack/models/consumed_meal.dart';
import 'package:stattrack/providers/auth_provider.dart';
import 'package:stattrack/providers/repository_provider.dart';
import 'package:stattrack/services/auth.dart';
import 'package:stattrack/services/firestore_repository.dart';
import 'package:stattrack/services/repository.dart';
import 'package:stattrack/styles/palette.dart';

enum NavItem { daily, weekly, monthly, yearly }

final List<num> dayOfMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
final List<String> month = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

class LogPage extends ConsumerStatefulWidget {
  const LogPage({Key? key}) : super(key: key);

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends ConsumerState<LogPage> {
  NavItem activeNavItem = NavItem.daily;

  /// Handlse the event when nav item is presses
  ///
  /// [selected] the nav item presses
  void _handleNavSelect(NavItem selected) {
    setState(() {
      activeNavItem = selected;
    });
  }

  /// Converts a list of [ConsumedMeal]'s to a map group by day, week,
  /// month or year based on the active nav item that is sorted by time
  ///
  /// [meals] list of meals to convert
  /// [activeNavItem] the active nav item determining the grouping
  /// (day, week, month or year)
  Map<DateTime, List<ConsumedMeal>> _groupMeals(
      List<ConsumedMeal> meals, NavItem activeNavItem) {
    final Map<DateTime, List<ConsumedMeal>> groupedMeals = {};

    for (var meal in meals) {
      final DateTime date = meal.time;
      final DateTime dateKey = _getDateKey(date, activeNavItem);

      if (groupedMeals.containsKey(dateKey)) {
        groupedMeals[dateKey]!.add(meal);
      } else {
        groupedMeals[dateKey] = [meal];
      }
    }

    return groupedMeals;
  }

  /// Returns the date key for a given date based on the active nav item.
  ///
  /// [date] the date to get the key for
  /// [activeNavItem] the active nav item determining the grouping
  /// (day, week, month or year)
  DateTime _getDateKey(DateTime date, NavItem activeNavItem) {
    switch (activeNavItem) {
      case NavItem.daily:
        return DateTime(date.year, date.month, date.day);
      case NavItem.weekly:
        return DateTime(date.year, date.month, date.day - date.weekday);
      case NavItem.monthly:
        return DateTime(date.year, date.month);
      case NavItem.yearly:
        return DateTime(date.year);
    }
  }

  /// Returns a string representing the day, week, month or year for a given date
  /// based on the active nav item. (e.g. if daily is active, card will display
  /// the date, if weekly is active, the card will display the week number, if
  /// monthly is active, the card will display the month...)
  ///
  /// [date] the date to represent
  String _getCardDate(DateTime date) {
    switch (activeNavItem) {
      case NavItem.daily:
        return "${date.day}.${date.month}.${date.year}";
      case NavItem.weekly:
        return "Week ${_getWeekNumber(date)}, ${date.year}";
      case NavItem.monthly:
        return "${month[date.month - 1]} ${date.year}";
      case NavItem.yearly:
        return "${date.year}";
    }
  }

  /// Returns the week number for a given date
  ///
  /// [date] the date to get the week number for
  num _getWeekNumber(DateTime date) {
    final month = date.month;
    final day = date.day;

    num numberOfDays = 0;
    for (var i = 0; i < month - 1; i++) {
      numberOfDays += dayOfMonth[i];
    }
    numberOfDays += day;

    return (numberOfDays / 7).ceil();
  }

  /// Navigates back to the page visited before the log page
  ///
  /// [context] the current build context
  void _navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        headerTitle: 'Log',
        navButton: IconButton(
          // TODO: Nav back one page
          onPressed: () => _navigateBack(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
        actions: [
          IconButton(
            // TODO: Nav to stats page
            onPressed: () => print('stats'),
            icon: const Icon(
              Icons.bar_chart,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Returns the body of the log page
  Widget _buildBody() {
    final Repository repo = ref.read(repositoryProvider);
    final String uid = ref.read(authProvider).currentUser!.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          _buildNav(),
          const SizedBox(
            height: 16.0,
          ),
          StreamBuilder<List<ConsumedMeal>>(
            stream: repo.getLog(uid),
            builder: ((context, snapshot) {
              if (snapshot.connectionState != ConnectionState.active) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return _buildErrorText('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return _buildErrorText('You have no meals logged');
              }
              // Group items by date
              final Map<DateTime, List<ConsumedMeal>> groupedMeals =
                  _groupMeals(
                snapshot.data!,
                activeNavItem,
              );
              if (groupedMeals.isEmpty) {
                return _buildErrorText('You have no meals logged');
              }
              return _buildList(groupedMeals);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorText(String msg) {
    return SizedBox(
      height: 48.0,
      child: Center(
        child: Text(msg),
      ),
    );
  }

  Widget _buildList(Map<DateTime, List<ConsumedMeal>> groupedMeals) {
    return Expanded(
      child: ListView(
        children: <Widget>[
          ...groupedMeals.values.map((meals) => StatCard(
              date: _getCardDate(meals[0].time),
              calories: meals
                  .map((consumedMeal) => consumedMeal.calories)
                  .reduce((value, element) => value + element),
              proteins: meals
                  .map((consumedMeal) => consumedMeal.proteins)
                  .reduce((value, element) => value + element),
              fat: meals
                  .map((consumedMeal) => consumedMeal.fat)
                  .reduce((value, element) => value + element),
              carbs: meals
                  .map((consumedMeal) => consumedMeal.carbs)
                  .reduce((value, element) => value + element),
              // TODO: Navigate to specific log page where all meals should be displayed
              onPress: () => print('Pressed card with date: $meals')))
        ],
      ),
    );
  }

  /// Returns a nav widget
  Widget _buildNav() {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _navItem(
              label: 'Daily',
              onPress: () => _handleNavSelect(NavItem.daily),
              active: activeNavItem == NavItem.daily,
            ),
            _navItem(
              label: 'Weekly',
              onPress: () => _handleNavSelect(NavItem.weekly),
              active: activeNavItem == NavItem.weekly,
            ),
            _navItem(
              label: 'Monthly',
              onPress: () => _handleNavSelect(NavItem.monthly),
              active: activeNavItem == NavItem.monthly,
            ),
            _navItem(
              label: 'Yearly',
              onPress: () => _handleNavSelect(NavItem.yearly),
              active: activeNavItem == NavItem.yearly,
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a nav item
  ///
  /// [label] the label displayed in the item
  /// [onPress] the callback function called when the item is pressed
  /// [active] a boolean describing if the item is currently active or
  /// not. Active items has a change in style
  Widget _navItem(
      {required String label,
      required VoidCallback onPress,
      required bool active}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: active ? Palette.accent[400] : Colors.transparent,
      ),
      child: SizedBox(
        height: 40.0,
        child: TextButton(
          onPressed: onPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
