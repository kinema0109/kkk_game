import asyncio
import os
import pathspec
import json
from pathlib import Path
from typing import List, Dict, Any, Optional
from mcp.server import Server
from mcp.types import Tool, TextContent
import mcp.server.stdio
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
from fastembed import TextEmbedding
import pydantic

# Configuration
REPO_ROOT = Path("e:/myproject/manager-game")
STORAGE_ROOT = REPO_ROOT / ".vibe" / "rag_storage"
COLLECTION_NAME = "codebase"

# Ensure storage directory exists
STORAGE_ROOT.mkdir(parents=True, exist_ok=True)

class CodeChunk(pydantic.BaseModel):
    file_path: str
    content: str
    start_line: int
    end_line: int

class CodebaseRAG:
    def __init__(self):
        self.qdrant = QdrantClient(path=str(STORAGE_ROOT))
        self.encoder = TextEmbedding()
        self._ensure_collection()
        self.ignore_spec = self._load_ignore_spec()

    def _ensure_collection(self):
        collections = self.qdrant.get_collections().collections
        exists = any(c.name == COLLECTION_NAME for c in collections)
        if not exists:
            # fastembed default model is BAAI/bge-small-en-v1.5 which has 384 dims
            self.qdrant.create_collection(
                collection_name=COLLECTION_NAME,
                vectors_config=VectorParams(size=384, distance=Distance.COSINE),
            )

    def _load_ignore_spec(self):
        patterns = [
            ".git/", "node_modules/", "dist/", "build/", ".next/", 
            "*.log", ".env*", ".vibe/", "venv/", ".venv/"
        ]
        
        # Load from .gitignore if exists
        gitignore = REPO_ROOT / ".gitignore"
        if gitignore.exists():
            patterns.extend(gitignore.read_text().splitlines())
            
        # Load from repomix.config.json if exists
        repomix_config = REPO_ROOT / "repomix.config.json"
        if repomix_config.exists():
            try:
                data = json.loads(repomix_config.read_text())
                custom_ignore = data.get("ignore", {}).get("customPatterns", [])
                patterns.extend(custom_ignore)
            except:
                pass
                
        return pathspec.PathSpec.from_lines('gitwildmatch', patterns)

    def should_ignore(self, file_path: Path) -> bool:
        rel_path = file_path.relative_to(REPO_ROOT)
        return self.ignore_spec.match_file(str(rel_path))

    def chunk_file(self, file_path: Path, chunk_size: int = 1000) -> List[CodeChunk]:
        try:
            content = file_path.read_text(encoding='utf-8', errors='ignore')
            lines = content.splitlines()
            chunks = []
            
            # Simple line-based chunking
            for i in range(0, len(lines), chunk_size):
                chunk_lines = lines[i : i + chunk_size]
                chunks.append(CodeChunk(
                    file_path=str(file_path.relative_to(REPO_ROOT)),
                    content="\n".join(chunk_lines),
                    start_line=i + 1,
                    end_line=i + len(chunk_lines)
                ))
            return chunks
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
            return []

    def index_all(self):
        points = []
        batch_id = 0
        
        for file_path in REPO_ROOT.rglob("*"):
            if file_path.is_file() and not self.should_ignore(file_path):
                chunks = self.chunk_file(file_path)
                for chunk in chunks:
                    # Generate embedding
                    embedding = list(self.encoder.embed([chunk.content]))[0]
                    
                    points.append(PointStruct(
                        id=batch_id,
                        vector=embedding.tolist(),
                        payload={
                            "file_path": chunk.file_path,
                            "content": chunk.content,
                            "start_line": chunk.start_line,
                            "end_line": chunk.end_line
                        }
                    ))
                    batch_id += 1
        
        if points:
            self.qdrant.upsert(
                collection_name=COLLECTION_NAME,
                points=points
            )
        return len(points)

    def search(self, query: str, limit: int = 5):
        query_vector = list(self.encoder.embed([query]))[0]
        hits = self.qdrant.search(
            collection_name=COLLECTION_NAME,
            query_vector=query_vector.tolist(),
            limit=limit
        )
        return [hit.payload for hit in hits]

# Initialize RAG
rag = CodebaseRAG()

# Create MCP Server
app = Server("codebase-rag")

@app.list_tools()
async def list_tools() -> List[Tool]:
    return [
        Tool(
            name="semantic_search",
            description="Search for relevant code snippets in the codebase using semantic similarity",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "The search query (e.g. 'how does authentication work?')"},
                    "limit": {"type": "number", "description": "Number of results to return", "default": 5}
                },
                "required": ["query"]
            }
        ),
        Tool(
            name="index_codebase",
            description="Re-index the entire codebase to pick up new changes",
            inputSchema={"type": "object", "properties": {}}
        ),
        Tool(
            name="list_files",
            description="List all files currently indexed in the RAG system",
            inputSchema={"type": "object", "properties": {}}
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    if name == "semantic_search":
        query = arguments.get("query")
        limit = arguments.get("limit", 5)
        results = rag.search(query, limit=limit)
        
        formatted_results = []
        for res in results:
            formatted_results.append(
                f"--- File: {res['file_path']} (Lines {res['start_line']}-{res['end_line']}) ---\n{res['content']}\n"
            )
        
        return [TextContent(type="text", text="\n".join(formatted_results))]
        
    elif name == "index_codebase":
        count = rag.index_all()
        return [TextContent(type="text", text=f"Successfully indexed {count} code chunks.")]
        
    elif name == "list_files":
        # Get unique file paths from payload
        # This is a bit slow in Qdrant but works for small-medium projects
        scroll_results = rag.qdrant.scroll(
            collection_name=COLLECTION_NAME,
            limit=1000,
            with_payload=True,
            with_vectors=False
        )
        files = set(point.payload["file_path"] for point in scroll_results[0])
        return [TextContent(type="text", text="Indexed files:\n" + "\n".join(sorted(files)))]

    raise ValueError(f"Unknown tool: {name}")

async def main():
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "index":
        print("Indexing codebase...")
        rag.index_all()
        print("Done.")
    else:
        asyncio.run(main())
