import os
import os.path

class VerticaConfig:

    def __init__(self, host = "", port = "", user = "", password = "", database = "", ssl = False, schema = ""):
        self.host = host
        self.port = port
        self.user = user
        self.password = password
        self.database = database
        self.ssl = ssl
        self.schema = schema

    def readConfig(self, configFile):
        isVerticaFile = False

        with open(configFile) as f:
            for line in f:
                line = line.strip()
                if line.upper() == "[VERTICA]":
                    isVerticaFile = True
                else:
                    lineItems = line.split("=")
                    if len(lineItems) != 2:
                        print("Invalid Config Line: " + line)
                        break

                    if lineItems[0].upper() == "HOST":
                        self.host = lineItems[1]
                    elif lineItems[0].upper() == "PORT":
                        self.port = lineItems[1]
                    elif lineItems[0].upper() == "USER":
                        self.user = lineItems[1]
                    elif lineItems[0].upper() == "PASSWORD":
                        self.password = lineItems[1]
                    elif lineItems[0].upper() == "DATABASE":
                        self.database = lineItems[1]
                    elif lineItems[0].upper() == "SCHEMA":
                        self.schema = lineItems[1]
                    elif lineItems[0].upper() == "SSL":
                        if lineItems[1].upper() == "False":
                            self.ssl = False
                        else:
                            self.ssl = True



    def validate(self):
         #TODO - Add validation

        return True



