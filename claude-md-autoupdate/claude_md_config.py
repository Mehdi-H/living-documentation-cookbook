# Markdown heading placed at the very top of the generated file.
# This is the document title; parts below will use ## headings.
HEADER = "# CLAUDE.md"

PARTS = [
    {
        "title": "TLDR",
        "source_type": "file",
        "source": "parts/repo_tldr.md",
    },
    {
        "title": "Main commands",
        "source_type": "command",
        "source": "make help",
        "format": "code",
    },
    {
        "title": "Arborescence",
        "source_type": "command",
        "source": "python claude-md-autoupdate/parts/tree_with_annotations.py",
        "format": "code",
    },
]

OUTPUT_PATH = "CLAUDE.md"
