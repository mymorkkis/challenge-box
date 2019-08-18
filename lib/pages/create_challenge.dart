import 'package:challenge_box/db/connections/challenge_connection.dart';
import 'package:challenge_box/utility_functions.dart';
import 'package:flutter/material.dart';
import 'package:challenge_box/db/models/challenge.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class CreateChallengePage extends StatefulWidget {
  CreateChallengePage({
    Key key,
    @required this.title,
    @required this.dbConnection,
  }) : super(key: key);

  final String title;
  final ChallengeConnection dbConnection;

  @override
  _CreateChallengePageState createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat("dd-MM-yyyy");
  final _nameController = TextEditingController();
  final _startDateController = TextEditingController();

  String _challengeName;
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                icon: Icon(Icons.equalizer),
                labelText: 'Challenge Name',
                hintText: 'E.g Quit Alcohol',
              ),
              validator: (input) => _validateName(input),
              onSaved: (input) =>
                  _challengeName = ReCase(input).titleCase.trim(),
            ),
            DateTimeField(
              controller: _startDateController,
              decoration: InputDecoration(
                icon: Icon(Icons.calendar_today),
                labelText: 'Challenge Start Date',
              ),
              format: _dateFormat,
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                    context: context,
                    firstDate: DateTime(2018),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime.now());
              },
              onSaved: (input) => input is DateTime ? _startDate = input : null,
            ),
            Builder(
              builder: (context) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          int challengeId =
                              await _saveChallenge(widget.dbConnection);
                          _showSnackBar(context, challengeId);
                        }
                      },
                      child: Text('Create Challenge'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _validateName(String name) {
    var nonAlphaNumericRegex = RegExp('[^0-9a-zA-Z ]');

    if (name.length < 1) {
      return 'You must choose a challenge name';
    }
    if (nonAlphaNumericRegex.firstMatch(name) != null) {
      return 'Challenge names must be alphanumeric';
    }

    return null;
  }

  _saveChallenge(dbConnection) async {
    _formKey.currentState.save();

    final challenge = Challenge(_challengeName, toDate(_startDate));
    int challengeId = await dbConnection.insertChallenge(challenge);

    _nameController.clear();
    _startDateController.clear();

    return challengeId;
  }

  _showSnackBar(BuildContext context, int challengeId) {
    var text = '$_challengeName Created';
    var color = Colors.teal[100];

    if (challengeId == null) {
      text = '$_challengeName is already taken';
      color = Colors.red;
    }

    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(fontSize: 18.0, color: color),
        ),
      ),
    );
  }
}