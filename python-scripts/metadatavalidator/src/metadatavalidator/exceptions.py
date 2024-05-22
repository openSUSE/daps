"""
Our custom exception classes
"""
class NoConfigFilesFoundError(FileNotFoundError):
    pass


class BaseMetadataError(ValueError):
    pass

