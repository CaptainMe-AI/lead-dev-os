# Coding Style — Python / FastAPI

> Established: 2026-02-27

## Conventions

### Naming
- **Rule:** Use `snake_case` for variables, functions, and modules; `PascalCase` for classes and Pydantic models; `UPPER_SNAKE_CASE` for constants.
- **Example:** `user_service.py`, `class UserProfile`, `MAX_UPLOAD_SIZE = 5_242_880`
- **Rationale:** Follows PEP 8 and is the universal Python convention. Consistent naming reduces cognitive load when navigating code.

### File Organization
- **Rule:** Organize by feature domain, not by type. Each feature gets a package with `router.py`, `service.py`, `models.py`, and `schemas.py`.
- **Example:**
  ```
  src/features/
  ├── auth/
  │   ├── router.py      # FastAPI route definitions
  │   ├── service.py      # Business logic
  │   ├── models.py       # SQLAlchemy models
  │   └── schemas.py      # Pydantic request/response schemas
  └── tasks/
      ├── router.py
      ├── service.py
      ├── models.py
      └── schemas.py
  ```
- **Rationale:** Feature-based organization keeps related code together, makes features independently navigable, and avoids 500-line files that mix concerns.

### Formatting
- **Rule:** Use `ruff` for formatting and linting. Line length limit: 100 characters. Configure in `pyproject.toml`.
- **Example:** `ruff check . && ruff format .`
- **Rationale:** Ruff is fast, replaces both Black and Flake8, and enforces consistent style automatically with zero arguments about formatting.

### Type Hints
- **Rule:** Type-hint all function signatures and Pydantic model fields. Use `from __future__ import annotations` in every module.
- **Example:** `def get_user(user_id: UUID) -> UserResponse:`
- **Rationale:** Type hints enable IDE autocomplete, catch bugs early, and serve as inline documentation. FastAPI uses them to generate OpenAPI schemas.

### Error Handling
- **Rule:** Raise `HTTPException` in routers for client errors. Raise domain-specific exceptions in services (e.g., `UserNotFoundError`). Map service exceptions to HTTP responses in a central exception handler.
- **Example:**
  ```python
  # service.py
  class TaskNotFoundError(Exception):
      def __init__(self, task_id: UUID):
          self.task_id = task_id

  # exception_handlers.py
  @app.exception_handler(TaskNotFoundError)
  async def handle_task_not_found(request, exc):
      return JSONResponse(status_code=404, content={"detail": f"Task {exc.task_id} not found"})
  ```
- **Rationale:** Separating domain exceptions from HTTP exceptions keeps service logic framework-agnostic and testable without importing FastAPI.

### Testing
- **Rule:** Use `pytest` with `pytest-asyncio` for async tests. Test files mirror the source tree: `tests/features/auth/test_service.py`. Aim for >80% coverage on service logic; router tests use `httpx.AsyncClient`.
- **Example:** `pytest --cov=src --cov-report=term-missing`
- **Rationale:** Pytest is the de facto Python testing standard. Mirroring source structure makes it easy to find tests for any module.

### Dependencies
- **Rule:** Use `uv` for dependency management. Pin all direct dependencies in `pyproject.toml`. Lock transitive dependencies with `uv lock`.
- **Example:** `uv add fastapi sqlalchemy[asyncio]`
- **Rationale:** uv is fast, reliable, and produces reproducible builds via lockfiles. Pinning direct deps prevents surprise breakage.

### API Design
- **Rule:** Use RESTful resource paths (`/api/v1/tasks/{task_id}`). Return Pydantic response models. Use 201 for creation, 204 for deletion, 422 for validation errors.
- **Example:** `@router.post("/tasks", response_model=TaskResponse, status_code=201)`
- **Rationale:** Consistent API design makes endpoints predictable for frontend developers and API consumers. FastAPI + Pydantic auto-generates accurate OpenAPI docs.
