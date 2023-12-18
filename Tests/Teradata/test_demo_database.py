import unittest
from teradata_extraction_test_base import TeradataExtractionTestBase
from database_summary.top_level_object_type import TopLevelObjectType

class TestDemoDatabase(TeradataExtractionTestBase):

    @classmethod
    def setUpClass(cls):
        extraction_parameters = ["include_databases=(UPPER(T1.DATABASENAME) = 'SC_EXAMPLE_DEMO')",
                                 "exclude_databases=(UPPER(T1.DATABASENAME) NOT IN ('SYS_CALENDAR','ALL','CONSOLE','CRASHDUMPS','DBC','DBCMANAGER','DBCMNGR','DEFAULT','EXTERNAL_AP','EXTUSER','LOCKLOGSHREDDER','PDCRADM','PDCRDATA','PDCRINFO','PUBLIC','SQLJ','SYSADMIN','SYSBAR','SYSJDBC','SYSLIB','SYSSPATIAL','SYSTEMFE','SYSUDTLIB','SYSUIF','TD_SERVER_DB','TD_SYSFNLIB','TD_SYSFNLIB','TD_SYSGPL','TD_SYSXML','TDMAPS', 'TDPUSER','TDQCD','TDSTATS','TDWM','VIEWPOINT','PDCRSTG'))"]
        cls.run_extraction_scripts("demo_database", "test_demo_database", extraction_parameters)
        cls.source_database_summary = cls.sumarize_source_code("demo_database")
        cls.extracted_database_summary = cls.sumarize_extracted_code("test_demo_database")

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