# AI test automation demo

An AI agent reads an API spec (OpenAPI) and writes Robot Framework tests **once**.
After that, the pipeline runs the tests with **no AI and no AI cost**.
The agent acts again only when a test breaks.

- `spec/`: the OpenAPI files of a public currency API (v1 and v2)
- `tests/`, `resources/`, `variables/`: tests written by the agent
- `config/api_version.txt`: the API version the pipeline tests (`v1` or `v2`)
- `ledger.csv`: what the AI cost, per event
- `.github/workflows/tests.yml`: the pipeline

Public API used: https://frankfurter.dev

The test report of the last run on `main` is published as a web page (GitHub Pages).
