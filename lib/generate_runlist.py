import os

def generate_runlist(folder_path, output_file="_runlist.txt"):
    """
    Updates or creates a runlist file by appending any new .sql files
    found in the specified folder, preserving existing order and comments.

    Args:
        folder_path (str): The path to the folder containing .sql files.
        output_file (str): The name of the runlist file. Defaults to '_runlist.txt'.

    Returns:
        None
    """
    if not os.path.exists(folder_path):
        raise FileNotFoundError(f"The folder '{folder_path}' does not exist.")

    # Get all .sql files in the folder
    all_sql_files = sorted([f for f in os.listdir(folder_path) if f.lower().endswith('.sql')])

    if not all_sql_files:
        print(f"No .sql files found in the folder '{folder_path}'.")
        return

    runlist_path = os.path.join(folder_path, output_file)
    existing_lines = []
    existing_scripts = set()

    # Read existing runlist if it exists
    if os.path.exists(runlist_path):
        with open(runlist_path, "r") as f:
            for line in f:
                line_clean = line.strip()
                existing_lines.append(line.rstrip("\n"))
                if line_clean and not line_clean.startswith("#"):
                    script = line_clean.split("#", 1)[0].strip()
                    if script:
                        existing_scripts.add(script)

    # Detect new scripts to append
    missing_scripts = [f for f in all_sql_files if f not in existing_scripts]

    if not existing_lines:
        # Fresh runlist
        with open(runlist_path, "w") as f:
            f.write("# Auto-generated runlist\n")
            for script in all_sql_files:
                f.write(f"{script}\n")
        print(f"Runlist created at: {runlist_path}")
    elif missing_scripts:
        with open(runlist_path, "a") as f:
            f.write("\n# --- Auto-appended scripts ---\n")
            for script in missing_scripts:
                f.write(f"{script}\n")
        print(f"Updated {runlist_path} with {len(missing_scripts)} new script(s).")
    else:
        print("Runlist already up-to-date. No changes made.")

if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python generate_runlist.py <folder_path>")
        sys.exit(1)

    folder_path = sys.argv[1]
    generate_runlist(folder_path)
