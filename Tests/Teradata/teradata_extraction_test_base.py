import unittest
import subprocess
from database_summary.database_source_code_summarizer import sumarize_database_source_code
from database_summary.database_source_code_summary import DatabaseSourceCodeSummary

class TeradataExtractionTestBase(unittest.TestCase):
    source_database_path = "./source_code/"
    extracted_database_path = "./extracted_code/"
    source_database_summary : DatabaseSourceCodeSummary = None
    extracted_database_summary : DatabaseSourceCodeSummary= None

    def sumarize_source_code(database_folder_name: str) -> DatabaseSourceCodeSummary:
        result = sumarize_database_source_code("./source_code/"+database_folder_name)
        return result

    def sumarize_extracted_code(database_folder_name: str) -> DatabaseSourceCodeSummary:
        return sumarize_database_source_code("./extracted_code/"+database_folder_name)

    def run_extraction_scripts(database_folder_name: str, extraction_output_folder_name: str, extraction_parameters: "list[str]") -> None:
        subprocess.call(['sh', './execute_scripts.sh', database_folder_name, extraction_output_folder_name] + extraction_parameters, cwd='./scripts')

    def remove_extraction_results(database_folder_name: str) -> None:
        subprocess.call(['rm', '-r', f'extracted_code/{database_folder_name}' ])


    
    