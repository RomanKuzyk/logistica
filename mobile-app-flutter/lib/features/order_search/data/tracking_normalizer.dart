String truncateTracking(String track) {
  if (track.length == 28 && track.startsWith('%')) {
    return track.substring(8, 22);
  }
  if (track.length == 34 && track.startsWith('9')) {
    return track.substring(22, 34);
  }
  if (track.length == 34 && track.startsWith('4')) {
    return track.substring(22, 34);
  }
  if (track.length == 30 && track.startsWith('4')) {
    return track.substring(10, 30);
  }
  return track;
}

String normalizeReceiveSearchInput(String rawValue) {
  final String trimmed = rawValue.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  final String truncated = truncateTracking(trimmed);
  if (truncated.startsWith('%') && truncated.length >= 22) {
    return truncated.substring(8, 22);
  }
  return truncated;
}
