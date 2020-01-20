// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'theme_info.dart';

/// Aniaml Clock - using the basic digital clock as base.
class AnimalClock extends StatefulWidget {
  const AnimalClock(this.model);
  final ClockModel model;

  @override
  _AnimalClockState createState() => _AnimalClockState();
}

class _AnimalClockState extends State<AnimalClock> {
  final FlareControls lionControls = FlareControls();
  final FlareControls dogControls = FlareControls();
  final FlareControls birdControls = FlareControls();
  DateTime _dateTime = DateTime.now();
  DayPeriod _period;
  Timer _timer;
  bool _isLionPause = false;
  String _previousTime = "";
  bool _dogPlaysLeft = true;
  bool _birdPlaysLeft = false;
  // bool _dogSmile = false;

  @override
  void initState() {
    super.initState();

    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnimalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {});
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(seconds: 3) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );

      final currentTime = DateFormat('HH mm').format(_dateTime);
      if (_previousTime == "") _previousTime = currentTime;
      if (_previousTime != "" && currentTime != _previousTime) {
        _playSurpriseAnimation();
        _previousTime = currentTime;
      }
    });
  }

  void _playSurpriseAnimation() {
    birdControls.play("fly");
    dogControls.play("walk");
    lionControls..play("surprised");
    Timer(Duration(seconds: 3), () {
      lionControls..play("idle");
    });

    _dogPlaysLeft = !_dogPlaysLeft;
    _birdPlaysLeft = !_birdPlaysLeft;
  }

  String _getPeriodOfDay(String value, int placement) {
    String txt = "";

    if (placement == 2) {
      txt = value[0];
    } else if (placement == 3) {
      txt = value[1];
    }
    return txt;
  }

  Widget _getColumnContent(String value, double width, int placement) {
    Color color = Colors.black;
    FontWeight weight = FontWeight.w400;

    if (placement == 0) {
      color = Colors.pinkAccent.withOpacity(0.4);
      weight = FontWeight.w200;
    } else if (placement == 1) {
      color = Colors.cyan.withOpacity(0.7);
      weight = FontWeight.w200;
    } else if (placement == 2) {
      color = Colors.blue.withOpacity(0.5);
      //this leaves a gap in android, but otherwise overflows in iOS
      width = width - 1;
    } else if (placement == 3) {
      color = Colors.tealAccent.withOpacity(0.5);
      width = width - 1;
    }

    final period = (_period == DayPeriod.am) ? "AM" : "PM";
    Text periodOfDay = Text(_getPeriodOfDay(period, placement),
        key: ValueKey(value),
        style: getPeriodOfDayStyle(weight),
        textScaleFactor: 0.55);

    Text time = Text(value,
        key: ValueKey(value),
        style: getNumberStyle(weight),
        textScaleFactor: 0.9);

    return Stack(
      children: <Widget>[
        Positioned(
            bottom: -25,
            left: 0,
            child: Container(
                width: width,
                alignment: Alignment.center,
                child:
                    (widget.model.is24HourFormat) ? Container() : periodOfDay)),
        Container(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
                Colors.transparent.withOpacity(0.7), BlendMode.dstOut),
            child: Container(
                width: width,
                height: MediaQuery.of(context).size.height,
                color: color),
          ),
        ),
        Positioned(
          top: -70,
          child: Container(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Colors.transparent.withOpacity(0.2), BlendMode.dst),
              child: Container(
                width: width,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                      duration: const Duration(seconds: 2), child: time),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHeight = mediaQueryData.size.height;

    final theme = Theme.of(context).brightness == Brightness.light
        ? lightTheme
        : darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = screenWidth / 2;
    final columnWidth = screenWidth / 4 - 11;
    final defaultStyle =
        getDefaultTextStyle(theme[Item.text], fontSize, theme[Item.shadow]);
    _period = TimeOfDay.fromDateTime(_dateTime).period;

    return Container(
        child: Stack(
      children: <Widget>[
        Image.asset(
          "assets/background.png",
          height: screenHeight,
          width: screenWidth,
          fit: BoxFit.cover,
        ),
        AnimatedPositioned(
          duration: Duration(seconds: 14),
          top: 40,
          right: _birdPlaysLeft ? (screenWidth + 100) : -150,
          width: 50,
          height: 50,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(_birdPlaysLeft ? pi : 0),
            child: new FlareActor(
              "assets/Bird.flr",
              animation: "fly",
              fit: BoxFit.contain,
              alignment: Alignment.center,
              controller: birdControls,
            ),
          ),
        ),
        Container(
          height: screenHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.blueGrey.withOpacity(0.5),
                  Colors.black.withOpacity(0.95),
                ],
                stops: [
                  0.0,
                  0.9
                ]),
          ),
        ),
        DefaultTextStyle(
          style: defaultStyle,
          child: Row(
            children: [
              _getColumnContent(hour[0], columnWidth, 0),
              _getColumnContent(hour[1], columnWidth, 1),
              _getColumnContent(minute[0], columnWidth, 2),
              _getColumnContent(minute[1], columnWidth, 3),
            ],
          ),
        ),
        AnimatedPositioned(
          duration: Duration(seconds: 10),
          bottom: -40,
          right: _dogPlaysLeft ? (screenWidth + 100) : -150,
          width: 130,
          height: 130,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(_dogPlaysLeft ? 0 : pi),
            child: new FlareActor(
              "assets/Dog.flr",
              animation: "walk",
              fit: BoxFit.contain,
              alignment: Alignment.center,
              controller: dogControls,
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: 0,
          width: 150,
          height: 150.0,
          child: new FlareActor("assets/Lion.flr",
              animation: "idle",
              fit: BoxFit.fitHeight,
              alignment: Alignment.center,
              isPaused: _isLionPause,
              controller: lionControls),
        ),
      ],
    ));
  }
}
