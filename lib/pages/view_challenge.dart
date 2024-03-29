import 'package:challenge_box/db/connections/challenge_connection.dart';
import 'package:challenge_box/db/connections/challenge_day_completed_connection.dart';
import 'package:challenge_box/db/models/challenge.dart';
import 'package:challenge_box/db/models/challenge_day_completed.dart';
import 'package:challenge_box/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

class ChallengePage extends StatefulWidget {
  final Challenge challenge;
  final ChallengeConnection challengeConnection;
  final ChallengeDayCompletedConnection challengeDateConnection;

  ChallengePage({
    Key key,
    @required this.challenge,
    @required this.challengeConnection,
    @required this.challengeDateConnection,
  }) : super(key: key);

  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challenge.name),
      ),
      body: futureBuilderWrapper(
        child: _displayChallengeData,
        futureAction:
            widget.challengeDateConnection.queryPreviousChallengeDatesCompleted,
        id: widget.challenge.id,
      ),
    );
  }

  _displayChallengeData(previousDatesCompleted) {
    final buttonText = widget.challenge.failed ? 'Restart' : 'Fail';
    final buttonAction = widget.challenge.failed
        ? widget.challenge.restart
        : widget.challenge.fail;

    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 380.0,
              child: CalendarCarousel(
                thisMonthDayBorderColor: Colors.grey,
                height: 350.0,
                width: 320.0,
                daysTextStyle: TextStyle(color: Colors.grey[300]),
                weekendTextStyle: TextStyle(color: Colors.grey[300]),
                weekdayTextStyle: TextStyle(color: Colors.blueGrey[200]),
                selectedDateTime: DateTime.now(),
                selectedDayButtonColor: Colors.grey[600],
                selectedDayBorderColor: Colors.grey[700],
                daysHaveCircularBorder: false,
                markedDatesMap: _markedCompletedDays(
                  widget.challenge,
                  previousDatesCompleted,
                ),
                markedDateShowIcon: true,
                markedDateIconMaxShown: 1,
                markedDateIconBuilder: (event) => event.icon,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 4.0, bottom: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _iconExplanation(Colors.green, 'Current Challenge'),
                  _iconExplanation(Colors.green[200], 'Previously Completed'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
              key: ValueKey('deleteButton'),
              onPressed: () => _confirm(
                'Delete',
                widget.challenge,
                context,
                () => widget.challengeConnection.deleteChallenge(
                  widget.challenge,
                ),
              ),
              child: Text('Delete'),
            ),
            RaisedButton(
              key: ValueKey('${buttonText.toLowerCase()}Button'),
              onPressed:
                  widget.challenge.failedToday() || widget.challenge.completed()
                      ? null
                      : () => _confirm(
                            buttonText,
                            widget.challenge,
                            context,
                            () => _updateChallenge(
                              widget.challenge,
                              buttonAction,
                            ),
                          ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  _confirm(actionName, challenge, context, doAction) async {
    final confirmedAction = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('$actionName ${challenge.name}'),
            content: new Text('Are you sure?'),
            actions: <Widget>[
              FlatButton(
                  key: Key('yesButton'),
                  child: Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  }),
              FlatButton(
                  key: Key('noButton'),
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  }),
            ],
          );
        });

    if (confirmedAction) {
      doAction();
      Navigator.of(context).pop();
    }
  }

  _updateChallenge(Challenge challenge, Function challengeAction) {
    final List<ChallengeDayCompleted> completedDays = [];
    for (final dateCompleted in challenge.datesCompleted()) {
      completedDays.add(ChallengeDayCompleted(challenge.id, dateCompleted));
    }

    challengeAction();

    widget.challengeConnection.updateChallenge(challenge);
    widget.challengeDateConnection.insertChallengeDaysCompleted(completedDays);
  }
}

_markedCompletedDays(
  Challenge challenge,
  List<DateTime> previousDatesCompleted,
) {
  final eventList = EventList<Event>(events: {});

  for (final currentDateCompleted in challenge.datesCompleted()) {
    eventList.add(
      currentDateCompleted,
      Event(
        date: currentDateCompleted,
        title: 'Completed',
        icon: _dayCompletedIcon(
          text: currentDateCompleted.day.toString(),
          iconColor: Colors.green,
        ),
      ),
    );
  }

  for (final DateTime previousDateCompleted in previousDatesCompleted) {
    eventList.add(
      previousDateCompleted,
      Event(
        date: previousDateCompleted,
        title: 'Previously Completed',
        icon: _dayCompletedIcon(
          text: previousDateCompleted.day.toString(),
          iconColor: Colors.green[200],
        ),
      ),
    );
  }

  return eventList;
}

Widget _dayCompletedIcon({String text, Color iconColor}) {
  return Container(
    decoration: BoxDecoration(
      color: iconColor,
      borderRadius: BorderRadius.all(
        Radius.circular(1000),
      ),
    ),
    child: Center(
      child: Text(text, style: TextStyle(color: Colors.black)),
    ),
  );
}

Widget _iconExplanation(Color color, String text) {
  return Row(
    children: <Widget>[
      Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Text('$text'),
      ),
    ],
  );
}
