FROM python:3.9 AS builder

ENV PIP_DEFAULT_TIMEOUT=200 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    POETRY_VERSION=1.5.1 \
    POETRY_VIRTUALENVS_IN_PROJECT=true

ENV WD_NAME=/linker

WORKDIR $WD_NAME

COPY poetry.lock pyproject.toml .

RUN pip install poetry==${POETRY_VERSION}
RUN poetry config installer.max-workers 10 \
        && poetry install --only main --no-interaction --no-ansi

FROM python:3.9-slim as runtime

ENV WD_NAME=/linker
WORKDIR $WD_NAME

ENV PATH="$WD_NAME/.venv/bin/:$PATH"

COPY --from=builder $WD_NAME/.venv .venv
COPY config config
COPY src src
CMD ["flask", "--app", "src/main", "run", "--host", "0.0.0.0", "--port", "5000", "--with-threads"]
