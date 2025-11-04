import os
import argparse
import pandas as pd
from pathlib import Path
from typing import List, Dict, Optional


def parse_filename(file_path: Path) -> Dict[str, Optional[str]]:
    """
    Infers source and target from filenames.
    Examples:
        '00__users__UserScreen.sql' → source=users, target=UserScreen
        'users__UserScreen.sql'     → source=users, target=UserScreen
        '01__CaseTypes.sql'         → source=None, target=CaseTypes
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
        file_info = parse_filename(file_path)

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
def export_registry_to_excel(df: pd.DataFrame, output_path: Path):
    """Exports the DataFrame registry to an Excel file."""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Force the extension to be .xlsx
    excel_path = output_path.with_suffix(".xlsx")
    
    with pd.ExcelWriter(excel_path, engine="openpyxl") as writer:
        df.to_excel(writer, index=False, sheet_name="Mapping Registry")

    print(f"✅ Excel export created: {excel_path}")


# ------------------------------------------------------------
# 4️⃣ Export to Markdown
# ------------------------------------------------------------
def export_registry_to_markdown(df: pd.DataFrame, output_path: Path):
    """Exports the DataFrame registry to a Markdown table file."""
    
    markdown_output = df.to_markdown(index=False)
    
    header = (
        f"# Schema Flow Mapping Registry\n\n"
        f"This table provides a mapping of Source Tables to Target Screens, automatically "
        f"generated from SQL script filenames.\n\n"
    )
    
    output_content = header + markdown_output
    
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Force the extension to be .md
    markdown_path = output_path.with_suffix(".md")

    with open(markdown_path, 'w', encoding='utf-8') as f:
        f.write(output_content)

    print(f"✅ Markdown export created: {markdown_path}")

# ------------------------------------------------------------
# 4️⃣ CLI Entry
# ------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="Parse SQL filenames into a mapping registry.")
    parser.add_argument("folder", type=Path, help="Path to folder containing SQL scripts")
    parser.add_argument("-o", "--output", type=Path, default="Table Mapping.xlsx",
                        help="Path to output Excel file (default: Table Mapping.xlsx)")
    parser.add_argument("--no-recursive", action="store_true", help="Exclude subfolders from parsing")
    args = parser.parse_args()

    recursive = not args.no_recursive
    registry = build_registry(
        args.folder, 
        recursive=recursive
    )

    if not registry:
        print("⚠️ No registry data to export.")
        return

    # Create DataFrame and apply sorting once
    df = pd.DataFrame(registry)
    sort_cols = [col for col in ["Target Screens", "Script"] if col in df.columns]
    if sort_cols:
        df = df.sort_values(by=sort_cols, na_position="last")
        
    # --- Execute both exports ---
    print("\n--- Starting Export ---\n")
    export_registry_to_excel(df, args.output)
    export_registry_to_markdown(df, args.output)


if __name__ == "__main__":
    main()