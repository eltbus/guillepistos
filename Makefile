install:
	@poetry install
build:
	@poetry run python -m mkdocs build
deploy:
	@aws s3 sync site s3://guillepistos.com/
serve:
	@poetry run python -m mkdocs serve
