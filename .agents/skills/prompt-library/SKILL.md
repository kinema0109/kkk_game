---
name: prompt-library
description: "Curated collection of high-performance prompt templates and meta-prompts. Use to generate specialized agents, system instructions, and evaluation sets."
risk: unknown
source: community
---
# Prompt Library & Meta-Prompting

> **Philosophy:** Don't write prompts. Generate them. Meta-prompting ensures consistency, rigor, and structural excellence across all your AI assistants.

## Meta-Prompting Protocol
The Meta-Prompt is a master template designed to transform a task description into a high-fidelity system prompt.

### 1. The Transformation Flow
1. **Input**: User goal or rough task description.
2. **Analysis**: Meta-prompt identifies persona, requirements, and constraints.
3. **Synthesis**: Produces a structured system prompt with XML tags and few-shot examples.

---

## Common Templates

### Template: Technical Specialist
**Persona**: Senior Engineer / Architect
**Structure**:
```xml
<persona>
[Specific role and expertise]
</persona>

<knowledge_boundaries>
[What to know vs what to ask/research]
</knowledge_boundaries>

<workflow>
1. Analyze
2. Plan
3. Execute
4. Verify
</workflow>
```

### Template: Security Auditor
**Persona**: Offensive Security Expert / Pen-tester
**Key Focus**:
- Vulnerability patterns
- OWASP standards
- Mitigation strategies
- Zero-trust implementation

---

## Use Cases
- **System Instruction Generation**: Creating dedicated system prompts for new agents.
- **Task-Specific Optimization**: Refining broad prompts into precision tools.
- **Agent Orchestration**: Designing "Coordination Prompts" for multi-agent systems.
- **Evaluation Sets**: Prompting the model to generate test cases for other prompts.

---

## Best Practices
- **Version Control your Prompts**: Treat them like source code.
- **Variable Injection**: Design prompts with `{{placeholders}}` for dynamic context.
- **Rigor Testing**: Use the "Adversarial Test" – try to break your own prompt.
- **Consistency**: Use the same XML/Markdown tagging style across the entire library.

---

## Anti-patterns
- **Duplicate Prompts**: Creating distinct prompts for "Python Expert" and "Django Expert" when they could be one modular prompt.
- **Hardcoding Data**: Putting project-specific data into the library templates.
- **Too much filler**: Avoid "You are a friendly and helpful assistant" unless tone is critical.

---

## Library Checklist
- [ ] Does this template follow the XML/Markdown structural standard?
- [ ] Is the persona clearly distinguished from the instructions?
- [ ] Are few-shot examples optional or required?
- [ ] Is there a placeholder for project-specific context?
- [ ] Is there an explicit output format requirement?
