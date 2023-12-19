import unittest
import subprocess
from database_summary.database_source_code_summarizer import sumarize_database_source_code
from database_summary.database_source_code_summary import DatabaseSourceCodeSummary
from database_summary.database_source_code_summary import TopLevelObjectType

class TeradataExtractionTestBase(unittest.TestCase):
    source_database_path = "./source_code/"
    extracted_database_path = "./extracted_code/"

    def __init__(self, *args, **kwargs):
        super(TeradataExtractionTestBase, self).__init__(*args, **kwargs)
        source_database_summary : DatabaseSourceCodeSummary = None
        extracted_database_summary : DatabaseSourceCodeSummary= None
        error_messages : "list[str]" = []

    def set_up_class(self, database_source_folder_name: str, database_output_folder_name: str, extraction_parameters: "list[str]"):
        self.run_extraction_scripts("demo_database", "test_demo_database", extraction_parameters)
        self.source_database_summary = self.sumarize_source_code(database_source_folder_name)
        self.extracted_database_summary = self.sumarize_extracted_code(database_output_folder_name)
        self.error_messages = []

    def sumarize_source_code(database_folder_name: str) -> DatabaseSourceCodeSummary:
        result = sumarize_database_source_code("./source_code/"+database_folder_name)
        return result
    
    def validate_top_level_objects_quantity(self, type: TopLevelObjectType, expected_amount: int) -> DatabaseSourceCodeSummary:
        actual_amount = self.source_database_summary.get_top_level_object_to_int_map()[type]
        try: 
            self.assertEqual(actual_amount, expected_amount)
        except AssertionError:
            self.error_messages += [f"Expected {expected_amount} {type.name.lower() + ('s' if expected_amount > 1 else '')} in source code, but {actual_amount} found"]

        actual_amount = self.extracted_database_summary.get_top_level_object_to_int_map()[type]
        try: 
            self.assertEqual(actual_amount, expected_amount)
        except AssertionError:
            self.error_messages += [f"Expected {expected_amount} {type.name.lower() + ('s' if expected_amount > 1 else '')} in extracted code, but {actual_amount} found"]

    def validate_extracted_files_quantity(self, actual_amount, expected_amount: int) -> DatabaseSourceCodeSummary:
        try: 
            self.assertEqual(actual_amount, expected_amount)
        except AssertionError as e:
            error_messages += [f"Expected {expected_amount} file{'s' if expected_amount > 1 else ''} in extracted files, but {actual_amount} found"]

    def assert_no_errors_messages(self):
        if len(self.error_messages) > 0:
            error_message = '\n'.join(self.error_messages)
            raise AssertionError(error_message)


    def sumarize_extracted_code(database_folder_name: str) -> DatabaseSourceCodeSummary:
        return sumarize_database_source_code("./extracted_code/"+database_folder_name)

    def run_extraction_scripts(database_folder_name: str, extraction_output_folder_name: str, extraction_parameters: "list[str]") -> None:
        subprocess.call(['sh', './execute_scripts.sh', database_folder_name, extraction_output_folder_name] + extraction_parameters, cwd='./scripts')

    def remove_extraction_results(database_folder_name: str) -> None:
        subprocess.call(['rm', '-r', f'extracted_code/{database_folder_name}' ])


    
    