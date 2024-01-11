import unittest
from teradata_extraction_test_base import TeradataExtractionTestBase
from database_summary.top_level_object_type import TopLevelObjectType

class TestDemoDatabase(TeradataExtractionTestBase):

    @classmethod
    def setUpClass(cls):
        extraction_parameters = ["include_databases=(UPPER(T1.DATABASENAME) IN ('SC_EXAMPLE_DEMO', 'SC_EXAMPLE_DEMO_2') )",
                                 "exclude_databases=(UPPER(T1.DATABASENAME) NOT IN ('SYS_CALENDAR','ALL','CONSOLE','CRASHDUMPS','DBC','DBCMANAGER','DBCMNGR','DEFAULT','EXTERNAL_AP','EXTUSER','LOCKLOGSHREDDER','PDCRADM','PDCRDATA','PDCRINFO','PUBLIC','SQLJ','SYSADMIN','SYSBAR','SYSJDBC','SYSLIB','SYSSPATIAL','SYSTEMFE','SYSUDTLIB','SYSUIF','TD_SERVER_DB','TD_SYSFNLIB','TD_SYSFNLIB','TD_SYSGPL','TD_SYSXML','TDMAPS', 'TDPUSER','TDQCD','TDSTATS','TDWM','VIEWPOINT','PDCRSTG'))"]
        cls.set_up_class(cls, "demo_database", "test_demo_database", extraction_parameters)

    def test_database_files(self):
        self.validate_extracted_files_quantity(self.extracted_database_summary.get_count_of_files(), 21)
        self.validate_top_level_objects_quantity(TopLevelObjectType.TABLE, 9)
        self.validate_top_level_objects_quantity(TopLevelObjectType.DATABASE, 2)
        self.validate_top_level_objects_quantity(TopLevelObjectType.PROCEDURE, 2)
        self.validate_top_level_objects_quantity(TopLevelObjectType.JOIN_INDEX, 2)
        self.validate_top_level_objects_quantity(TopLevelObjectType.MACRO, 2)
        self.validate_top_level_objects_quantity(TopLevelObjectType.FUNCTION, 1)
        self.validate_top_level_objects_quantity(TopLevelObjectType.TRIGGER, 1)
        self.validate_top_level_objects_quantity(TopLevelObjectType.VIEW, 1)

        self.assert_no_errors_messages()
        

if __name__ == '__main__':
    unittest.main()