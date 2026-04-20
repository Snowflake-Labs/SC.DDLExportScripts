"""BDD step definitions and fixtures for export_all_workflows.py tests."""

import importlib.util
import os
import sys
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

import pytest
from pytest_bdd import given, when, then, parsers, scenarios

# Dynamically import the script under test (path contains spaces).
_SCRIPT_PATH = os.path.normpath(
    os.path.join(
        os.path.dirname(__file__),
        "..", "..", "..",
        "ETL", "Informatica PowerCenter", "export_all_workflows.py",
    )
)
_spec = importlib.util.spec_from_file_location("export_all_workflows", _SCRIPT_PATH)
ewf = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(ewf)


# ---------------------------------------------------------------------------
# Shared fixture: mutable context dict passed between steps
# ---------------------------------------------------------------------------

@pytest.fixture
def ctx():
    return {}


# ---------------------------------------------------------------------------
# Helper: build a fake subprocess.run result
# ---------------------------------------------------------------------------

def _make_run_result(stdout="", stderr="", returncode=0):
    return SimpleNamespace(stdout=stdout, stderr=stderr, returncode=returncode)


def _listobjects_output(workflow_names):
    """Build realistic pmrep listobjects stdout."""
    lines = [
        "Informatica(r) PMREP, version [10.4.1]",
        "Copyright (c) Informatica LLC 1996 - 2023",
        "Invoked at Thu Jun 12 10:30:00 2025",
        "",
    ]
    for name in workflow_names:
        lines.append(f"workflow {name}")
    lines.append("")
    lines.append("listobjects completed successfully.")
    lines.append("Completed at Thu Jun 12 10:30:05 2025")
    return "\n".join(lines)


# ===================================================================
# GIVEN steps
# ===================================================================

# -- Pure function givens --

@given(parsers.parse('the operating system is "{os_name}"'), target_fixture="ctx")
def given_os(os_name):
    return {"os_name": os_name}


@given(parsers.parse('a line of pmrep output "{line}"'), target_fixture="ctx")
def given_noise_line(line):
    return {"line": line}


@given('pmrep output lines containing "completed successfully"', target_fixture="ctx")
def given_status_success():
    return {"output_lines": ["some info", "listobjects completed successfully.", "done"]}


@given('pmrep output lines without "completed successfully"', target_fixture="ctx")
def given_status_failure():
    return {"output_lines": ["some info", "error occurred", "done"]}


@given(
    parsers.parse(
        'pmrep listobjects output with workflows "{w1}", "{w2}", and "{w3}"'
    ),
    target_fixture="ctx",
)
def given_three_workflows(w1, w2, w3):
    return {"raw_output": _listobjects_output([w1, w2, w3])}


@given(
    parsers.parse('pmrep listobjects output with noise headers and workflow "{name}"'),
    target_fixture="ctx",
)
def given_noise_and_one_workflow(name):
    return {"raw_output": _listobjects_output([name])}


@given("pmrep listobjects output with no workflow lines", target_fixture="ctx")
def given_empty_output():
    return {"raw_output": _listobjects_output([])}


# -- Mocked givens: run_pmrep --

@given("a mock pmrep that returns successful output", target_fixture="ctx")
def given_mock_pmrep_success():
    result = _make_run_result(
        stdout="Invoked at ...\nworkflow WF_TEST\nlistobjects completed successfully.\n"
    )
    mock = MagicMock(return_value=result)
    return {"subprocess_mock": mock}


@given("a mock pmrep that returns failure output", target_fixture="ctx")
def given_mock_pmrep_failure():
    result = _make_run_result(stdout="Invoked at ...\nerror occurred\n", returncode=1)
    mock = MagicMock(return_value=result)
    return {"subprocess_mock": mock}


# -- Mocked givens: main() --

@given(parsers.parse('a folder "{folder}" with workflows "{w1}" and "{w2}"'), target_fixture="ctx")
def given_folder_two_workflows(folder, w1, w2):
    return {"folder": folder, "workflows": [w1, w2], "fail_workflows": []}


@given(
    parsers.parse('a folder "{folder}" with workflows "{w1}", "{w2}", and "{w3}"'),
    target_fixture="ctx",
)
def given_folder_three_workflows(folder, w1, w2, w3):
    return {"folder": folder, "workflows": [w1, w2, w3], "fail_workflows": []}


@given(parsers.parse('a folder "{folder}" with no workflows'), target_fixture="ctx")
def given_folder_empty(folder):
    return {"folder": folder, "workflows": [], "fail_workflows": []}


@given("pmrep listobjects succeeds with those workflows")
def given_listobjects_succeeds(ctx):
    ctx["listobjects_succeeds"] = True


@given("pmrep listobjects fails", target_fixture="ctx")
def given_listobjects_fails():
    return {"folder": None, "workflows": [], "fail_workflows": [], "listobjects_succeeds": False}


@given("pmrep objectexport succeeds for all workflows")
def given_export_all_succeed(ctx):
    ctx["fail_workflows"] = []


@given(parsers.parse('pmrep objectexport fails for workflow "{name}"'))
def given_export_fails_for(ctx, name):
    ctx.setdefault("fail_workflows", []).append(name)


# ===================================================================
# WHEN steps
# ===================================================================

@when("I request the default pmrep path")
def when_get_default_path(ctx):
    with patch("platform.system", return_value=ctx["os_name"]):
        ctx["result"] = ewf.get_default_pmrep_path()


@when("I check if it is a noise line")
def when_check_noise(ctx):
    ctx["result"] = ewf.is_noise_line(ctx["line"])


@when("I check the command status")
def when_check_status(ctx):
    ctx["result"] = ewf.check_command_status(ctx["output_lines"])


@when("I parse the workflows")
def when_parse_workflows(ctx):
    ctx["result"] = ewf.parse_workflows(ctx["raw_output"])


@when(parsers.parse('I run pmrep with arguments "{args_str}"'))
def when_run_pmrep(ctx, args_str):
    args = args_str.split()
    with patch.object(ewf.subprocess, "run", ctx["subprocess_mock"]):
        stdout, stderr, success = ewf.run_pmrep("/usr/bin/pmrep", args)
    ctx["stdout"] = stdout
    ctx["stderr"] = stderr
    ctx["success"] = success


@when(parsers.parse('I run the main function with folder "{folder}"'))
def when_run_main(ctx, folder):
    workflows = ctx.get("workflows", [])
    fail_workflows = ctx.get("fail_workflows", [])
    listobjects_succeeds = ctx.get("listobjects_succeeds", True)

    # Build the listobjects mock response
    if listobjects_succeeds:
        list_stdout = _listobjects_output(workflows)
    else:
        list_stdout = "Invoked at ...\nerror: repository connection failed\n"

    def fake_subprocess_run(command, **kwargs):
        cmd_str = " ".join(command)
        if "listobjects" in cmd_str:
            return _make_run_result(stdout=list_stdout)
        elif "objectexport" in cmd_str:
            # Check if this workflow should fail
            for wf_name in fail_workflows:
                if wf_name in cmd_str:
                    return _make_run_result(
                        stdout="Invoked at ...\nerror exporting\n",
                        stderr=f"Failed to export {wf_name}",
                    )
            return _make_run_result(
                stdout="Invoked at ...\nobjectexport completed successfully.\n"
            )
        return _make_run_result()

    test_argv = [
        "export_all_workflows.py",
        "--folder-name", folder,
        "--export-dir", "/tmp/test_exports",
    ]

    with (
        patch.object(ewf.subprocess, "run", side_effect=fake_subprocess_run),
        patch.object(ewf.os, "makedirs"),
        patch.object(sys, "argv", test_argv),
    ):
        try:
            ewf.main()
            ctx["exit_code"] = 0
        except SystemExit as exc:
            ctx["exit_code"] = exc.code if exc.code is not None else 0


# ===================================================================
# THEN steps
# ===================================================================

@then(parsers.parse('the path should be "{expected}"'))
def then_path_equals(ctx, expected):
    assert ctx["result"] == expected


@then(parsers.parse("it should be identified as noise: {expected}"))
def then_is_noise(ctx, expected):
    assert ctx["result"] == (expected.strip().lower() == "true")


@then("it should report success")
@then("the run should report success")
def then_report_success(ctx):
    assert ctx.get("result", ctx.get("success")) is True


@then("it should report failure")
@then("the run should report failure")
def then_report_failure(ctx):
    assert ctx.get("result", ctx.get("success")) is False


@then(parsers.parse("I should get {count:d} workflow names"))
def then_workflow_count(ctx, count):
    assert len(ctx["result"]) == count


@then(parsers.parse('the workflow names should be "{names}"'))
def then_workflow_names_single(ctx, names):
    expected = [n.strip().strip('"') for n in names.split(",")]
    assert ctx["result"] == expected


@then(parsers.parse('the workflow names should be "{w1}", "{w2}", "{w3}"'))
def then_workflow_names_three(ctx, w1, w2, w3):
    assert ctx["result"] == [w1, w2, w3]


@then("subprocess should have been called with the correct command")
def then_subprocess_called(ctx):
    ctx["subprocess_mock"].assert_called_once()
    call_args = ctx["subprocess_mock"].call_args[0][0]
    assert call_args[0] == "/usr/bin/pmrep"


@then(parsers.parse("it should exit with code {code:d}"))
def then_exit_code(ctx, code):
    assert ctx["exit_code"] == code
