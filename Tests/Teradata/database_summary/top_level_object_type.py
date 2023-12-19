from enum import Enum
from types import DynamicClassAttribute

class TopLevelObjectType(Enum):
    TABLE = 1
    PROCEDURE = 2
    VIEW = 3
    DATABASE = 4
    TRIGGER = 5
    MACRO = 6
    FUNCTION = 7
    JOIN_INDEX = 8
    UNDEFINED_TYPE = 20