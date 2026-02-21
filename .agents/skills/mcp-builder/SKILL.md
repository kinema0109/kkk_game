---
name: mcp-builder
description: "Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. Use when building MCP servers to integrate exte..."
license: Complete terms in LICENSE.txt
risk: unknown
source: community
---
# MCP Server Development Guide

Create MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. The quality of an MCP server is measured by how well it enables LLMs to accomplish real-world tasks.

---

# Process

## 🚀 High-Level Workflow
Creating a high-quality MCP server involves four main phases:

### Phase 1: Deep Research and Planning
#### 1.1 Understand Modern MCP Design

**API Coverage vs. Workflow Tools:**
Balance comprehensive API endpoint coverage with specialized workflow tools. Workflow tools can be more convenient for specific tasks, while comprehensive coverage gives agents flexibility to compose operations. Performance varies by client—some clients benefit from code execution that combines basic tools, while others work better with higher-level workflows. When uncertain, prioritize comprehensive API coverage.

**Tool Naming and Discoverability:**
Clear, descriptive tool names help agents find the right tools quickly. Use consistent prefixes (e.g., `github_create_issue`, `github_list_repos`) and action-oriented naming.

**Context Management:**
Agents benefit from concise tool descriptions and the ability to filter/paginate results. Design tools that return focused, relevant data. Some clients support code execution which can help agents filter and process data efficiently.

**Actionable Error Messages:**
Error messages should guide agents toward solutions with specific suggestions and next steps.

#### 1.2 Study MCP Protocol Documentation

**Navigate the MCP specification:**

Start with the sitemap to find relevant pages: `https://modelcontextprotocol.io/sitemap.xml`

Then fetch specific pages with `.md` suffix for markdown format (e.g., `https://modelcontextprotocol.io/specification/draft.md`).

Key pages to review:
- Specification overview and architecture
- Transport mechanisms (streamable HTTP, stdio)
- Tool, resource, and prompt definitions

#### 1.3 Study Framework Documentation

**Recommended stack:**
- **Language**: TypeScript (high-quality SDK support and good compatibility in many execution environments e.g. MCPB. Plus AI models are good at generating TypeScript code, benefiting from its broad usage, static typing and good linting tools)
- **Transport**: Streamable HTTP for remote servers, using stateless JSON (simpler to scale and maintain, as opposed to stateful sessions and streaming responses). stdio for local servers.

**Load framework documentation:**

- **MCP Best Practices**: [📋 View Best Practices](./reference/mcp_best_practices.md) - Core guidelines

**For TypeScript (recommended):**
- **TypeScript SDK**: Use WebFetch to load `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md`
- [⚡ TypeScript Guide](./reference/node_mcp_server.md) - TypeScript patterns and examples

**For Python:**
- **Python SDK**: Use WebFetch to load `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md`
- [🐍 Python Guide](./reference/python_mcp_server.md) - Python patterns and examples

#### 1.4 Plan Your Implementation

**Understand the API:**
Review the service's API documentation to identify key endpoints, authentication requirements, and data models. Use web search and WebFetch as needed.

**Tool Selection:**
Prioritize comprehensive API coverage. List endpoints to implement, starting with the most common operations.

---\n\n### Phase 2: Implementation\n#### 2.1 Set Up Project Structure\n\nSee language-specific guides for project setup:\n- [⚡ TypeScript Guide](./reference/node_mcp_server.md) - Project structure, package.json, tsconfig.json\n- [🐍 Python Guide](./reference/python_mcp_server.md) - Module organization, dependencies\n\n#### 2.2 Implement Core Infrastructure\n\nCreate shared utilities:\n- API client with authentication\n- Error handling helpers\n- Response formatting (JSON/Markdown)\n- Pagination support\n\n#### 2.3 Implement Tools\n\nFor each tool:\n\n**Input Schema:**\n- Use Zod (TypeScript) or Pydantic (Python)\n- Include constraints and clear descriptions\n- Add examples in field descriptions\n\n**Output Schema:**\n- Define `outputSchema` where possible for structured data\n- Use `structuredContent` in tool responses (TypeScript SDK feature)\n- Helps clients understand and process tool outputs\n\n**Tool Description:**\n- Concise summary of functionality\n- Parameter descriptions\n- Return type schema\n\n**Implementation:**\n- Async/await for I/O operations\n- Proper error handling with actionable messages\n- Support pagination where applicable\n- Return both text content and structured data when using modern SDKs\n\n**Annotations:**\n- `readOnlyHint`: true/false\n- `destructiveHint`: true/false\n- `idempotentHint`: true/false\n- `openWorldHint`: true/false\n\n---

### Phase 3: Review and Test
#### 3.1 Code Quality

Review for:
- No duplicated code (DRY principle)
- Consistent error handling
- Full type coverage
- Clear tool descriptions

#### 3.2 Build and Test

**TypeScript:**
- Run `npm run build` to verify compilation
- Test with MCP Inspector: `npx @modelcontextprotocol/inspector`

**Python:**
- Verify syntax: `python -m py_compile your_server.py`
- Test with MCP Inspector

See language-specific guides for detailed testing approaches and quality checklists.

---\n\n### Phase 4: Create Evaluations\nAfter implementing your MCP server, create comprehensive evaluations to test its effectiveness.\n\n**Load [✅ Evaluation Guide](./reference/evaluation.md) for complete evaluation guidelines.**\n\n#### 4.1 Understand Evaluation Purpose\n\nUse evaluations to test whether LLMs can effectively use your MCP server to answer realistic, complex questions.\n\n#### 4.2 Create 10 Evaluation Questions\n\nTo create effective evaluations, follow the process outlined in the evaluation guide:\n\n1. **Tool Inspection**: List available tools and understand their capabilities\n2. **Content Exploration**: Use READ-ONLY operations to explore available data\n3. **Question Generation**: Create 10 complex, realistic questions\n4. **Answer Verification**: Solve each question yourself to verify answers\n\n#### 4.3 Evaluation Requirements\n\nEnsure each question is:\n- **Independent**: Not dependent on other questions\n- **Read-only**: Only non-destructive operations required\n- **Complex**: Requiring multiple tool calls and deep exploration\n- **Realistic**: Based on real use cases humans would care about\n- **Verifiable**: Single, clear answer that can be verified by string comparison\n- **Stable**: Answer won't change over time\n\n#### 4.4 Output Format\n\nCreate an XML file with this structure:\n\n```xml\n<evaluation>\n  <qa_pair>\n    <question>Find discussions about AI model launches with animal codenames. One model needed a specific safety designation that uses the format ASL-X. What number X was being determined for the model named after a spotted wild cat?</question>\n    <answer>3</answer>\n  </qa_pair>\n<!-- More qa_pairs... -->\n</evaluation>\n```

---

# Reference Files

## 📚 Documentation Library
Load these resources as needed during development:

### Core MCP Documentation (Load First)
- **MCP Protocol**: Start with sitemap at `https://modelcontextprotocol.io/sitemap.xml`, then fetch specific pages with `.md` suffix
- [📋 MCP Best Practices](./reference/mcp_best_practices.md) - Universal MCP guidelines including:
  - Server and tool naming conventions
  - Response format guidelines (JSON vs Markdown)
  - Pagination best practices
  - Transport selection (streamable HTTP vs stdio)
  - Security and error handling standards

### SDK Documentation (Load During Phase 1/2)
- **Python SDK**: Fetch from `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md`
- **TypeScript SDK**: Fetch from `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md`

### Language-Specific Implementation Guides (Load During Phase 2)
- [🐍 Python Implementation Guide](./reference/python_mcp_server.md) - Complete Python/FastMCP guide with:
  - Server initialization patterns
  - Pydantic model examples
  - Tool registration with `@mcp.tool`
  - Complete working examples
  - Quality checklist

- [⚡ TypeScript Implementation Guide](./reference/node_mcp_server.md) - Complete TypeScript guide with:
  - Project structure
  - Zod schema patterns
  - Tool registration with `server.registerTool`
  - Complete working examples
  - Quality checklist

### Evaluation Guide (Load During Phase 4)
- [✅ Evaluation Guide](./reference/evaluation.md) - Complete evaluation creation guide with:
  - Question creation guidelines
  - Answer verification strategies
  - XML format specifications
  - Example questions and answers
  - Running an evaluation with the provided scripts

---\n\n## When to Use\nThis skill is applicable to execute the workflow or actions described in the overview.
