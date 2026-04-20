Feature: Export All Informatica PowerCenter Workflows
  As a data engineer
  I want to export all workflows from a PowerCenter folder
  So that I have individual XML files for each workflow

  # --- Pure function tests ---

  Scenario: Default pmrep path on Windows
    Given the operating system is "Windows"
    When I request the default pmrep path
    Then the path should be "C:\Informatica\10.4.1\server\bin\pmrep.exe"

  Scenario: Default pmrep path on Linux
    Given the operating system is "Linux"
    When I request the default pmrep path
    Then the path should be "/opt/informatica/10.4.1/server/bin/pmrep"

  Scenario Outline: Identify noise lines in pmrep output
    Given a line of pmrep output "<line>"
    When I check if it is a noise line
    Then it should be identified as noise: <is_noise>

    Examples:
      | line                                               | is_noise |
      | Informatica(r) PMREP, version [10.4.1]             | true     |
      | Copyright (c) Informatica LLC 1996 - 2023          | true     |
      | All Rights Reserved.                                | true     |
      | This Software is protected by U.S. Patent Numbers  | true     |
      | Invoked at Thu Jun 12 10:30:00 2025                 | true     |
      | Completed at Thu Jun 12 10:30:05 2025               | true     |
      | listobjects completed successfully.                 | true     |
      | workflow WF_DAILY_LOAD                              | false    |

  Scenario: Check command status when successful
    Given pmrep output lines containing "completed successfully"
    When I check the command status
    Then it should report success

  Scenario: Check command status when failed
    Given pmrep output lines without "completed successfully"
    When I check the command status
    Then it should report failure

  Scenario: Parse workflows from pmrep listobjects output
    Given pmrep listobjects output with workflows "WF_DAILY_LOAD", "WF_NIGHTLY_BATCH", and "WF_CUSTOMER_SYNC"
    When I parse the workflows
    Then I should get 3 workflow names
    And the workflow names should be "WF_DAILY_LOAD", "WF_NIGHTLY_BATCH", "WF_CUSTOMER_SYNC"

  Scenario: Parse workflows filters out noise lines
    Given pmrep listobjects output with noise headers and workflow "WF_ONLY_ONE"
    When I parse the workflows
    Then I should get 1 workflow names
    And the workflow names should be "WF_ONLY_ONE"

  Scenario: Parse workflows from empty output
    Given pmrep listobjects output with no workflow lines
    When I parse the workflows
    Then I should get 0 workflow names

  # --- Mocked tests ---

  Scenario: run_pmrep executes subprocess and detects success
    Given a mock pmrep that returns successful output
    When I run pmrep with arguments "listobjects -o workflow -f TestFolder"
    Then the run should report success
    And subprocess should have been called with the correct command

  Scenario: run_pmrep detects failure
    Given a mock pmrep that returns failure output
    When I run pmrep with arguments "listobjects -o workflow -f TestFolder"
    Then the run should report failure

  # --- Main orchestration tests ---

  Scenario: Main exports all workflows successfully
    Given a folder "TestFolder" with workflows "WF_A" and "WF_B"
    And pmrep listobjects succeeds with those workflows
    And pmrep objectexport succeeds for all workflows
    When I run the main function with folder "TestFolder"
    Then it should exit with code 0

  Scenario: Main handles empty folder gracefully
    Given a folder "EmptyFolder" with no workflows
    And pmrep listobjects succeeds with those workflows
    When I run the main function with folder "EmptyFolder"
    Then it should exit with code 0

  Scenario: Main exits with error when listobjects fails
    Given pmrep listobjects fails
    When I run the main function with folder "BadFolder"
    Then it should exit with code 1

  Scenario: Main reports partial failures
    Given a folder "MixedFolder" with workflows "WF_OK1", "WF_FAIL", and "WF_OK2"
    And pmrep listobjects succeeds with those workflows
    And pmrep objectexport fails for workflow "WF_FAIL"
    When I run the main function with folder "MixedFolder"
    Then it should exit with code 1
