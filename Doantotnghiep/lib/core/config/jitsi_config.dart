class JitsiConfig {
  static const serverUrl = String.fromEnvironment(
    'JITSI_SERVER_URL',
    defaultValue: 'https://meet.jit.si',
  );

  static String buildMeetingUrl(String roomName) {
    final baseUrl = serverUrl.endsWith('/')
        ? serverUrl.substring(0, serverUrl.length - 1)
        : serverUrl;
    return '$baseUrl/$roomName';
  }
}
