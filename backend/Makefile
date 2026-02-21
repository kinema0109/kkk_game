install:
	pip install -r requirements.txt

run:
	uvicorn src.app.main:app --reload --host 0.0.0.0 --port 8000

test:
	pytest tests

clean:
	rm -rf __pycache__ .pytest_cache
