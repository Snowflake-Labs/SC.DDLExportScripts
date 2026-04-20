"""
Export all Informatica PowerCenter workflows from a folder as separate XML files.

Works on Windows and Linux. Requires Python 3.7+ and pmrep installed.
Uses only standard library modules — no third-party dependencies.
"""

import subprocess
import sys
import os
import re
import argparse
import platform

# Lines containing these strings are noise from pmrep output and should be ignored.
NOISE_KEYWORDS = (
    "Informatica",
    "Copyright",
    "All Rights Reserved",
    "This Software is protected",
    "Invoked at",
    "Completed at",
    "completed successfully",
)


def get_default_pmrep_path():
    """Return the default pmrep path based on the current OS."""
    if platform.system() == "Windows":
        return r"C:\Informatica\10.4.1\server\bin\pmrep.exe"
    else:
        return "/opt/informatica/10.4.1/server/bin/pmrep"


def is_noise_line(line):
    """Check if a line is pmrep metadata noise that should be filtered out."""
    return any(keyword in line for keyword in NOISE_KEYWORDS)


def check_command_status(command_output):
    """
    Check if pmrep command completed successfully.
    """
    return any("completed successfully" in line for line in command_output)


def parse_workflows(output):
    """
    Parse pmrep listobjects output and extract workflow names.
    Filters out noise lines, then matches lines with format: 'workflow WORKFLOWNAME'
    """
    workflows = []
    for line in output.splitlines():
        stripped = line.strip()
        if not stripped or is_noise_line(stripped):
            continue
        match = re.match(r"^workflow\s+(.+)$", stripped)
        if match:
            workflows.append(match.group(1).strip())
    return workflows


def run_pmrep(pmrep_path, args):
    """
    Execute a pmrep command and return (stdout, stderr, success).
    """
    command = [pmrep_path] + args
    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    stdout_lines = result.stdout.splitlines()
    success = check_command_status(stdout_lines)
    return result.stdout, result.stderr, success


def main():
    parser = argparse.ArgumentParser(
        description="Export all Informatica PowerCenter workflows from a folder as separate XML files."
    )
    parser.add_argument(
        "--pmrep-path",
        default=get_default_pmrep_path(),
        help="Path to the pmrep executable (default: OS-specific Informatica path)",
    )
    parser.add_argument(
        "--folder-name",
        required=True,
        help="Name of the Informatica PowerCenter folder containing the workflows",
    )
    parser.add_argument(
        "--export-dir",
        default=os.path.join(".", "exports"),
        help="Directory where the exported .xml files will be saved (default: ./exports)",
    )
    args = parser.parse_args()

    # Create exports directory
    os.makedirs(args.export_dir, exist_ok=True)

    # Get list of workflows in folder
    print(f"Getting list of workflows from folder: {args.folder_name}")
    list_output, list_stderr, list_success = run_pmrep(
        args.pmrep_path, ["listobjects", "-o", "workflow", "-f", args.folder_name]
    )

    if not list_success:
        print("Failed to list workflows. pmrep output:", file=sys.stderr)
        print(list_output, file=sys.stderr)
        if list_stderr:
            print(list_stderr, file=sys.stderr)
        sys.exit(1)

    # Parse workflow names
    workflows = parse_workflows(list_output)
    total = len(workflows)
    print(f"Found {total} workflows\n")

    if total == 0:
        print("No workflows found. Nothing to export.")
        sys.exit(0)

    # Export each workflow
    failed = 0
    for i, workflow in enumerate(workflows, 1):
        print(f"[{i}/{total}] Exporting: {workflow}")
        output_file = os.path.join(args.export_dir, f"{workflow}.xml")

        _, export_stderr, export_success = run_pmrep(
            args.pmrep_path,
            [
                "objectexport",
                "-n", workflow,
                "-o", "workflow",
                "-f", args.folder_name,
                "-u", output_file,
                "-b", "-r", "-s", "-m",
            ],
        )

        if export_success:
            print(f"  Success: {workflow}.xml")
        else:
            print(f"  Failed: {workflow}", file=sys.stderr)
            if export_stderr:
                print(f"  {export_stderr.strip()}", file=sys.stderr)
            failed += 1

    print(f"\nDone! Exported {total - failed}/{total} workflows to {args.export_dir}")
    if failed > 0:
        print(f"{failed} workflow(s) failed to export.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
