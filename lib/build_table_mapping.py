import argparse
import pandas as pd
from pathlib import Path
from typing import List, Dict, Optional

# ------------------------------------------------------------
# 1️⃣ Parse filenames for source/target mapping
# ------------------------------------------------------------
def parse_filename_mapping(file_path: Path) -> Dict[str, Optional[str]]:
    """
    Infers source and target from filenames.
    """
    name = file_path.stem
    parts = name.split("__")

    # Remove numeric prefix if first part is a number
    if parts and parts[0].isdigit():
        parts = parts[1:]

    source = None
    target = None
    if len(parts) == 2:
        source, target = parts[0].strip(), parts[1].strip()
    elif len(parts) == 1:
        target = parts[0].strip()

    return {"Source Tables": source, "Target Screens": target}


# ------------------------------------------------------------
# 2️⃣ Build registry from filenames only
# ------------------------------------------------------------
def build_registry(folder: Path, recursive: bool) -> List[Dict]:
    """
    Builds a registry using filename mapping only.
    """
    search = folder.rglob("*.sql") if recursive else folder.glob("*.sql")
    registry = []
    
    # Define the final columns explicitly
    final_columns = ["Script", "Source Tables", "Target Screens", "Path"]

    for file_path in search:
        # Parse filename mapping
        file_info = parse_filename_mapping(file_path)

        # Combine all info
        entry_raw = {
            "Script": file_path.name,
            **file_info,
            "Path": str(file_path),
        }
        
        # Ensure correct column order
        entry = {col: entry_raw.get(col) for col in final_columns}
        
        registry.append(entry)

    return registry


# ------------------------------------------------------------
# 3️⃣ Export to Excel
# ------------------------------------------------------------
def export_registry_to_excel(df: pd.DataFrame, output_base_path: Path):
    """Exports the DataFrame registry to an Excel file."""
    
    # Force the extension to be .xlsx
    excel_path = output_base_path.with_suffix(".xlsx")
    
    with pd.ExcelWriter(excel_path, engine="openpyxl") as writer:
        df.to_excel(writer, index=False, sheet_name="Mapping Registry")

    print(f"✅ Excel export created: {excel_path}")


# ------------------------------------------------------------
# 4️⃣ Export to Markdown
# ------------------------------------------------------------
def export_registry_to_markdown(df: pd.DataFrame, output_base_path: Path):
    """Exports the DataFrame registry to a Markdown table file."""
    
    # Note: tabulate is required by pandas to_markdown and is installed in the action
    markdown_output = df.to_markdown(index=False)
    
    header = (
        f"# Schema Flow Mapping Registry\n\n"
        f"This table provides a mapping of Source Tables to Target Screens, automatically "
        f"generated from SQL script filenames.\n\n"
    )
    
    output_content = header + markdown_output
    
    # Force the extension to be .md
    markdown_path = output_base_path.with_suffix(".md")

    with open(markdown_path, 'w', encoding='utf-8') as f:
        f.write(output_content)

    print(f"✅ Markdown export created: {markdown_path}")


# ------------------------------------------------------------
# 5️⃣ Core Logic for Multiple Folders
# ------------------------------------------------------------
def process_multiple_folders(base_folder: Path, recursive: bool):
    """
    Scans the base_folder (e.g., './scripts') for subfolders,
    excludes 'shared', and generates mapping for each in the root directory.
    """
    print(f"Scanning base directory: {base_folder}")
    
    # Find all direct subdirectories, excluding 'shared' and hidden folders
    script_folders = [
        f for f in base_folder.iterdir()
        if f.is_dir() and f.name != "shared" and not f.name.startswith('.')
    ]
    
    if not script_folders:
        print(f"⚠️ No non-shared script folders found in {base_folder}.")
        return

    for folder in sorted(script_folders):
        print(f"\n--- Processing Folder: {folder.name} ---")
        
        # 1. Build Registry
        registry = build_registry(folder, recursive=recursive)

        if not registry:
            print(f"⚠️ No SQL files found in {folder.name}. Skipping export.")
            continue
        
        # 2. Create DataFrame and sort
        df = pd.DataFrame(registry)
        sort_cols = [col for col in ["Target Screens", "Script"] if col in df.columns]
        if sort_cols:
            df = df.sort_values(by=sort_cols, na_position="last")
        
        # 3. Define output path in the root directory: e.g., 'needles_schema_mapping_registry'
        # The base path is the current directory (root)
        output_base_name = f"{folder.name}_schema_mapping_registry"
        output_base = Path(output_base_name) 
        
        # 4. Execute both exports
        export_registry_to_excel(df, output_base)
        export_registry_to_markdown(df, output_base)
        print(f"--- Finished Processing {folder.name} ---")


# ------------------------------------------------------------
# 6️⃣ CLI Entry Point (Schema Flow Mapper)
# ------------------------------------------------------------
def schema_flow_mapper_cli():
    parser = argparse.ArgumentParser(
        description="Schema Flow Mapper: Parses SQL filenames to create a Source Table to Target Screen registry. If no folder is given, it scans subfolders in './scripts/'."
    )
    # Make folder optional (nargs='?'), defaulting to None (which triggers multi-folder scan)
    parser.add_argument("folder", type=Path, nargs='?', default=None, 
                        help="Path to a single folder containing SQL scripts. If omitted, scans all non-shared subfolders in './scripts/'.")
    
    # Output is now only used for single-folder mode, but we keep it for legacy
    parser.add_argument("-o", "--output", type=Path, default="mapping_registry",
                        help="Base name for output files (e.g., 'report' creates 'report.xlsx' and 'report.md'). Used only in single-folder mode.")
    parser.add_argument("--no-recursive", action="store_true", help="Exclude subfolders from parsing")
    args = parser.parse_args()

    recursive = not args.no_recursive
    
    print("\n--- Starting Schema Flow Mapper ---\n")

    if args.folder is None:
        # GitHub Action / Multi-Folder Scan mode
        base_script_path = Path("./scripts")
        process_multiple_folders(base_script_path, recursive)
    else:
        # Single-Folder Legacy mode
        print(f"Processing single folder: {args.folder}")
        registry = build_registry(args.folder, recursive=recursive)
        
        if not registry:
            print("⚠️ No registry data to export.")
            return

        df = pd.DataFrame(registry)
        sort_cols = [col for col in ["Target Screens", "Script"] if col in df.columns]
        if sort_cols:
            df = df.sort_values(by=sort_cols, na_position="last")
            
        export_registry_to_excel(df, args.output)
        export_registry_to_markdown(df, args.output)


if __name__ == "__main__":
    schema_flow_mapper_cli()
