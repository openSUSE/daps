import os.path
import typing as t


#: The configuration paths where to search for the config
CONFIGDIRS: t.Sequence = [
    # "Reserve" first place for environment variable 'METAVALIDATOR_CONFIG'
    # Search in the current directory:
    "metadatavalidator.ini",
    # In the users' home directory:
    "~/.config/metadatavalidator/config.ini",
    # In the system
    "/etc/metadatavalidator/config.ini"
    ]
METAVALIDATOR_CONFIG = os.environ.get('METAVALIDATOR_CONFIG')
if METAVALIDATOR_CONFIG is not None:
    CONFIGDIRS.insert(0, os.path.expanduser(METAVALIDATOR_CONFIG))

CONFIGDIRS = tuple(os.path.expanduser(i) for i in CONFIGDIRS)

