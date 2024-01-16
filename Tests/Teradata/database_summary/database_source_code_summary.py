from .top_level_object_type import TopLevelObjectType
class DatabaseSourceCodeSummary():
    def __init__(self):
        self._file_paths = []
        self._top_level_object_to_int_map = {}
        for top_level_object_type in TopLevelObjectType:
            self._top_level_object_to_int_map[top_level_object_type] = 0

    def get_count_of_files(self) -> int:
        return len(self._file_paths)
    
    def add_sql_file(self, file_path: str) -> None:
        self._file_paths+=[file_path]

    def get_top_level_object_to_int_map(self) -> "dict[TopLevelObjectType, int]":
        return self._top_level_object_to_int_map