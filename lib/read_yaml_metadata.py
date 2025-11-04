import yaml
import re
import argparse
from pathlib import Path
# from sa_conversion_utils.utilities.setup_logger import setup_logger
from detect_encoding import detect_encoding

# logger = setup_logger(__name__, log_file="run.log")

def read_yaml_metadata(file_path):
    """
    Reads YAML metadata from a /*--- ... ---*/ block at the top of a SQL file.
    """
    file_path = Path(file_path)

    if not file_path.exists():
        print(f"File does not exist: {file_path}")
        return None

    try:
        encoding = detect_encoding(file_path)
        content = file_path.read_text(encoding=encoding)
    except Exception as e:
        print(f"⚠️ Error reading {file_path}: {e}")
        return None

    # Regex to find block like /*--- ... ---*/
    match = re.search(r'/\*---(.*?)---\*/', content, re.DOTALL)
    if not match:
        return None

    try:
        metadata = yaml.safe_load(match.group(1).strip()) or {}
        metadata["script"] = file_path.name
        return metadata
    except yaml.YAMLError as e:
        print(f"⚠️ YAML parsing error in {file_path.name}: {e}")
        return None


def main():
    parser = argparse.ArgumentParser(description="Extract YAML metadata from a SQL file.")
    parser.add_argument("file", type=Path, help="Path to the SQL file")
    args = parser.parse_args()

    metadata = read_yaml_metadata(args.file)
    print(metadata)


if __name__ == "__main__":
    main()