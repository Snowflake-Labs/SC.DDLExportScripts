import os
import os.path


class SFConfig:

    def __init__(self, sfAccount = "", sfUser = "", sfPassword = "", sfWarehouse = "",  sfRole= ""):
        self.sfAccount = sfAccount
        self.sfUser = sfUser
        self.sfPassword = sfPassword
        self.sfWarehouse = sfWarehouse
        self.sfRole = sfRole
        self.schemaMapping = ["",""]
        self.execution = ["",""]
        self.inviewMappings = ["",""]

    def readConfig(self, configFile):
        isSnowflakeFile = False
        mappingSpecified = False
        executionSpecified = False
        inviewMappingSpecified = False

        with open(configFile) as f:
            for line in f:
                line = line.strip()
                # Ignore comments
                if line[0] == "#":
                    continue

                if line.upper() == "[SNOWFLAKE]":
                    isSnowflakeFile = True
                elif line.upper() == "[SCHEMA_MAPPINGS]":
                    mappingSpecified = True
                    inviewMappingSpecified = False
                    executionSpecified = False
                    self.schemaMapping.clear()
                elif line.upper() == "[INVIEW_MAPPINGS]":
                    inviewMappingSpecified = True
                    mappingSpecified = False
                    executionSpecified = False
                    self.inviewMappings.clear()
                elif line.upper() == "[EXECUTION]":
                    executionSpecified = True
                    mappingSpecified = False
                    inviewMappingSpecified = False
                    self.execution.clear()

                else:
                    lineItems = line.split("=")
                    if len(lineItems) != 2:
                        print("Invalid Config Line: " + line)
                    else:
                        if mappingSpecified is True:
                            self.schemaMapping.append([lineItems[0], lineItems[1]])
                            continue

                        if executionSpecified is True:
                            self.execution.append([lineItems[0], lineItems[1]])
                            continue

                        if inviewMappingSpecified is True:
                            self.inviewMappings.append([lineItems[0], lineItems[1]])
                            continue

                        if lineItems[0].upper() == "ACCOUNT":
                            self.sfAccount = lineItems[1]
                        elif lineItems[0].upper() == "USER":
                            self.sfUser = lineItems[1]
                        elif lineItems[0].upper() == "PASSWORD":
                            self.sfPassword = lineItems[1]
                        elif lineItems[0].upper() == "ROLE":
                            self.sfRole = lineItems[1]
                        elif lineItems[0].upper() == "ROLE":
                            self.sfRole = lineItems[1]
                        elif lineItems[0].upper() == "PROCESSVIEWS":
                            if lineItems[1].upper == "TRUE":
                                self.processViews = True;
                            else:
                                self.processViews = False;

    def validate(self):
        # TODO - Add validation

        return True