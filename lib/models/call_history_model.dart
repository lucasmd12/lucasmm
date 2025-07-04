import 'dart:convert';

class CallHistoryModel {
  final String id;
  final String callerId;
  final String receiverId;
  final String callType;
  final int duration;
  final String status;
  final String roomId;
  final String? clanId;
  final String? federationId;
  final DateTime timestamp;
  final String callerUsername;
  final String receiverUsername;

  CallHistoryModel({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.callType,
    required this.duration,
    required this.status,
    required this.roomId,
    this.clanId,
    this.federationId,
    required this.timestamp,
    required this.callerUsername,
    required this.receiverUsername,
  });

  factory CallHistoryModel.fromMap(Map<String, dynamic> map) {
    return CallHistoryModel(
      id: map["_id"] as String,
      callerId: map["callerId"]["_id"] as String,
      receiverId: map["receiverId"]["_id"] as String,
      callType: map["callType"] as String,
      duration: map["duration"] as int,
      status: map["status"] as String,
      roomId: map["roomId"] as String,
      clanId: map["clanId"] as String?,
      federationId: map["federationId"] as String?,
      timestamp: DateTime.parse(map["timestamp"] as String),
      callerUsername: map["callerId"]["username"] as String,
      receiverUsername: map["receiverId"]["username"] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "_id": id,
      "callerId": callerId,
      "receiverId": receiverId,
      "callType": callType,
      "duration": duration,
      "status": status,
      "roomId": roomId,
      "clanId": clanId,
      "federationId": federationId,
      "timestamp": timestamp.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory CallHistoryModel.fromJson(String source) =>
      CallHistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}


