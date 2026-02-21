---
name: prompt-engineer
description: "Advanced prompt engineering for Claude and Gemini. Covers system prompt design, tool-use optimization, chain-of-thought, XML structuring, and performance tuning."
risk: unknown
source: community
---
# Prompt Engineering Specialist

> **Philosophy:** A prompt is code for the model. Be precise, use structure, and engineer for reliability over "creative vibes."

## Core Principles
- **Model Specificity**: Optimize for the specific model version (e.g., Claude 3.5 Sonnet vs GPT-4o).
- **XML for Structure**: Use XML tags (`<system>`, `<context>`, `<instructions>`) for Claude; Use Markdown for Gemini.
- **Chain of Thought (CoT)**: Force explicit reasoning to improve complex logic and accuracy.
- **Negative Constraints**: Clearly state what the model should *not* do.
- **Separation of Concerns**: Distinguish between instructions, context, and user input.

---

## Advanced Techniques

### 1. XML Tagging (The Claude Standard)
Claude treats XML as a high-fidelity control signal.
```xml
<context>
[Relevant background information]
</context>
<instructions>
[Detailed task breakdown]
</instructions>
<constraints>
[Rules and boundaries]
</constraints>
```

### 2. Multi-Shot Implementation
Provide 3-5 diverse examples. For complex tasks, show the model the intermediate reasoning steps for each example.

### 3. Chain of Thought (Implicit vs Explicit)
- **Implicit**: "Think step-by-step before outputting."
- **Explicit**: Define a `<thought>` section in the output format.

### 4. Tool-Use Optimization
- Describe tool parameters with extreme clarity.
- Provide "negative examples" of when *not* to use a tool.
- Instruction: "If you have the information in context, do not call the tool."

---

## Formatting for Success
- **Use Uppercase for emphasis**: "You MUST always..."
- **Use Variables**: `{{USER_INPUT}}`, `{{CONTEXT}}` to help the model distinguish dynamic parts.
- **Delimiter tokens**: Use triple backticks or hashes to separate blocks.

---

## Troubleshooting Guide

| Issue | Potential Fix |
|-------|---------------|
| Hallucinations | Add "If you don't know, say I don't know." |
| Refusals | Soften system prompt, clarify safety boundaries. |
| Tool failures | Add XML example of correct tool call. |
| Verbosity | Add "Be concise. No conversational filler." |
| Pattern collapse | Increase temperature or provide more diverse shots. |

---

## Anti-patterns
- **Vague Adjectives**: Instead of "Be fast," use "Respond in under 50 words."
- **Hidden Instructions**: Putting critical rules in the middle of a large context block.
- **Prompt Injection Risks**: Not clearly delimiting user-provided content from instructions.
- **Over-complex logic**: If a prompt needs 50 rules, consider breaking the task into two agents.

---

## Design Checklist
- [ ] Is the core persona defined?
- [ ] Are there clear examples (Few-Shot)?
- [ ] Are XML tags or Markdown headers used for structure?
- [ ] Is there an explicit "negative constraint" section?
- [ ] Does it instruct the model to think step-by-step?
- [ ] Are tool descriptions unambiguous?
- [ ] Is the output format explicitly specified (JSON, Markdown, etc.)?
