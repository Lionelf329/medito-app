import 'dart:async';

import 'package:medito/constants/constants.dart';

import '../repositories/events/events_repository.dart';
import '../services/network/dio_api_service.dart';

Future<void> callUpdateStats(Map<String, dynamic> inputData) async {
  var eventsRpo = EventsRepositoryImpl(
    client: DioApiService(),
  );
  await eventsRpo.markAudioAsListenedEvent(
    trackId: inputData[TypeConstants.trackIdKey],
    timestamp: inputData[TypeConstants.timestampIdKey],
    fileDuration: inputData[TypeConstants.durationIdKey],
    fileId: inputData[TypeConstants.fileIdKey],
    fileGuide: inputData[TypeConstants.guideIdKey],
    userToken: inputData[UpdateStatsConstants.userTokenKey],
  );
}

class UpdateStatsConstants {
  static const userTokenKey = 'userToken';
}
