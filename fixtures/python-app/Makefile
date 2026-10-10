.PHONY: ci

ci:
	ruff check .
	ruff format --check .
	pytest --cov=src/fixture_app --cov-report=term-missing --cov-report=xml
