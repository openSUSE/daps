"""
Our custom exception classes
"""
class NoConfigFilesFoundError(FileNotFoundError):
    pass


class BaseMetadataError(ValueError):
    pass

class InvalidElementError(BaseMetadataError):
    pass

class InvalidValueError(BaseMetadataError):
    pass