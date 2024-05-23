"""
Our custom exception classes
"""

class NoConfigFilesFoundError(FileNotFoundError):
    pass


# --- Configuration exceptions
class BaseConfigError(ValueError):
    pass


class MissingSectionError(BaseConfigError):
    """A missing section could not be found in the config"""


class MissingKeyError(BaseConfigError):
    """A missing key could not be found in the config"""


# --- Validator exceptions
class BaseMetadataError(ValueError):
    pass

class InvalidElementError(BaseMetadataError):
    pass

class InvalidValueError(BaseMetadataError):
    pass