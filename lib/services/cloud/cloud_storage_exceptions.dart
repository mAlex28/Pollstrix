// poll related exceptions
class PollRelatedException implements Exception {
  const PollRelatedException();
}

class CouldNotCreatePollException extends PollRelatedException {}

class CouldNotGetAllPollsException extends PollRelatedException {}

class CouldNotDeletePollException extends PollRelatedException {}

class CouldNotVotePollException extends PollRelatedException {}

class CouldNotReportPollException extends PollRelatedException {}

class CouldNotLikePollException extends PollRelatedException {}

class CouldNotLeaveFeedbackException extends PollRelatedException {}

class CouldNotGetFeedbackException extends PollRelatedException {}

// user related exceptions
class UserRelatedException implements Exception {
  const UserRelatedException();
}

class CouldNotCreateUserException implements UserRelatedException {}

class CouldNotGetUserException implements UserRelatedException {}

class CouldNotDeleteUserException implements UserRelatedException {}

class CouldNotUpdateUserException implements UserRelatedException {}

// device Id related exceptions
class DeviceIdRelatedException implements Exception {
  const DeviceIdRelatedException();
}

class CouldNotSaveDeviceId extends DeviceIdRelatedException {}

class CouldNotFindDeviceId extends DeviceIdRelatedException {}
