from enum import Enum

class TopLevelObjectType(Enum):
    TABLE = 1
    PROCEDURE = 2
    VIEW = 3
    DATABASE = 4
    TRIGGER = 5
    UNDEFINED_TYPE = 6