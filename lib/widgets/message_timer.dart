import 'package:flutter/material.dart';
import 'dart:async';

class MessageTimer extends StatefulWidget {
  final DateTime expirationTime;

  const MessageTimer({required this.expirationTime});

  @override
  _MessageTimerState createState() => _MessageTimerState();
}

class _MessageTimerState extends State<MessageTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
    _updateTime();
  }

  void _updateTime() {
    final remaining = widget.expirationTime.difference(DateTime.now());
    if (remaining != _remaining) {
      setState(() => _remaining = remaining);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_remaining.inMinutes}m ${_remaining.inSeconds.remainder(60)}s',
      style: TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
