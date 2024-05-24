"""
Our custom exception classes
"""

class NoConfigFilesFoundError(FileNotFoundError):
    pass


# --- Configuration exceptions
class BaseConfigError(ValueError):
    def __init__(self, error, *args, **kwargs):
        self.error = error
        super().__init__(*args, **kwargs)


class MissingSectionError(BaseConfigError):
    """A missing section could not be found in the config"""

    def __str__(self) -> str:
        return f"Missing section in config file: {self.error}"


class MissingKeyError(BaseConfigError):
    """A missing key could not be found in the config"""

    def __str__(self) -> str:
        return f"Missing key in config file: {self.error}"


# --- Validator exceptions
class BaseMetadataError(ValueError):
    pass

class InvalidElementError(BaseMetadataError):
    pass

class InvalidValueError(BaseMetadataError):
    pass