---
description: Project setup and environment configuration
applyTo: "**"
---

# Virtual Environment

**IMPORTANT:** Always activate the project's virtual environment before running any commands.

## Activation

Activate the virtual environment:
- **PowerShell (Windows)**:
  ```powershell
  .\venv\Scripts\Activate.ps1
  ```

## Verify

To verify you're in the correct environment:
```bash
which python      # macOS/Linux
where python      # Windows PowerShell
```

The path should include `/venv/` or `\venv\`.

