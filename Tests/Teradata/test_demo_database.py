import unittest
from teradata_extraction_test_base import TeradataExtractionTestBase
from database_summary.top_level_object_type import TopLevelObjectType

class TestDemoDatabase(TeradataExtractionTestBase):

    @classmethod
    def setUpClass(cls):
        cls.run_extraction_scripts("demo_database")
        cls.source_database_summary = cls.sumarize_source_code("demo_database")
        cls.extracted_database_summary = cls.sumarize_extracted_code("demo_database")

    def test_number_of_extracted_files(self):
        self.assertEqual(self.extracted_database_summary.get_count_of_files(), 5)
        
    def test_number_of_extracted_tables(self):
        self.assertEqual(self.source_database_summary.get_top_level_object_to_int_map()[TopLevelObjectType.TABLE], 9)
        self.assertEqual(self.extracted_database_summary.get_top_level_object_to_int_map()[TopLevelObjectType.TABLE], 9)

    def test_number_of_extracted_databases(self):
        self.assertEqual(self.source_database_summary.get_top_level_object_to_int_map()[TopLevelObjectType.DATABASE], 1)
        self.assertEqual(self.extracted_database_summary.get_top_level_object_to_int_map()[TopLevelObjectType.DATABASE], 1)

    def test_number_of_extracted_procedures(self):
        self.assertEqual(self.source_database_summary.get_top_level_object_to_int_map()[TopLevelObjectType.PROCEDURE], 0)
        self.assertEqual(self.extracted_database_summary.get_top_level_object_to_int_map()[TopLevelObjectType.PROCEDURE], 0)

    def test_number_of_extracted_triggers(self):
        self.assertEqual(self.source_database_summary.get_top_level_object_to_int_map()[TopLevelObjectType.TRIGGER], 1)
        self.assertEqual(self.extracted_database_summary.get_top_level_object_to_int_map()[TopLevelObjectType.TRIGGER], 1)

    def test_number_of_extracted_views(self):
        self.assertEqual(self.source_database_summary.get_top_level_object_to_int_map()[TopLevelObjectType.VIEW], 1)
        self.assertEqual(self.extracted_database_summary.get_top_level_object_to_int_map()[TopLevelObjectType.VIEW], 1)


if __name__ == '__main__':
    unittest.main()