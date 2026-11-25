# V6Bench

V6Bench implements the integration testing recommendations from the IETF Internet-Draft [draft-ietf-v6ops-ipv6-app-testing](https://datatracker.ietf.org/doc/draft-ietf-v6ops-ipv6-app-testing/).

The initial focus is on the connectivity scenarios described in Section 3.1 of the draft.

This tool has two execution modes: **SCANAPI** and **MANUAL**. In the **SCANAPI** mode these scenarios are tested against APIs defined by an OpenAPI specification (JSON or YAML), while the **MANUAL** mode allows hands-on testing in the same connectivity scenarios. Support for additional application types and draft sections will be added over time.

> **⚠️ Project status:** Early development. Functional, but may contain bugs.

Feedback is welcome through GitHub Issues, and contributions are welcome via Pull Requests.

## Overview

V6Bench helps Quality Assurance teams validate IPv6 readiness throughout the software development lifecycle. It can also be used by developers, operators, and system administrators to verify whether applications behave correctly in different IPv6 deployment scenarios.

## Requirements

* [ScanAPI](https://scanapi.dev/) — required only for **SCANAPI** mode
   * Currently using version 2.13.2
       * Requires `curlify2<2.0.0,>=1.0.1`
* `xterm` — required only for **MANUAL** mode (one terminal window per client node)
* Docker
   * Must enable IPv6 for the default bridge network ([ref](https://docs.docker.com/engine/daemon/ipv6/#use-ipv6-for-the-default-bridge-network))
* [Kathará](https://www.kathara.org/)

## Architecture

V6Bench is built around a Kathará topology that creates the required network infrastructure (DNS, NAT64, SIIT, etc.) together with client hosts representing different IPv6 connectivity scenarios.

The diagram below illustrates the architecture and the test workflow.

![Architecture Diagram](doc/architecture_diagram.svg?raw=true&sanitize=true "Architecture Diagram")

## Usage Workflow

### SCANAPI mode

Automated test execution using ScanAPI, based on an OpenAPI specification.

1. Download this repo

2. Obtain the OpenAPI specification (JSON or YAML).

3. Generate the DNS configuration and zone files:

   ```bash
   python3 v6bench/zonefile_creator.py <test_domain>
   ```

4. Generate the ScanAPI test template:

   > ⚠️ At this stage, you need `ScanAPI` installed in your environment. You can use Python's `pip` module to install it: [ScanAPI on pypi](https://pypi.org/project/scanapi/).

   ```bash
   v6bench/scanapi_conversor.sh -i OPENAPI_PATH
   ```

   Then:

   * Customize the generated test plan in `v6bench/kathara/shared/shared_data/scanapi.yaml`.
   * Variables are automatically exported as environment variables. Runtime values should be customized in the generated configuration.

5. Configure the environment files under `v6bench/kathara/shared/env/`:

   * `test_vars.env` — general configuration variables
   * `credentials.env` — authentication credentials

6. Run the tests:

   * `v6bench/run_lab.sh SCANAPI`

7. Check results at `v6bench/kathara/shared/results/`

### MANUAL mode

Hands-on testing: the lab opens one `xterm` terminal per client node (4 in total), so you can run whatever tests you need. This mode does not require ScanAPI, and therefore the steps for the OpenAPI specification, the test template, and the environment files are not needed.

1. Download this repo

2. Generate the DNS configuration and zone files:

   ```bash
   python3 v6bench/zonefile_creator.py <test_domain>
   ```

3. Run the lab:

   * `v6bench/run_lab.sh MANUAL`

   One xterm window opens for each client node (4 terminals). Run whatever tests you need in them.

4. To finish, simply close the xterm windows and the lab will finish automatically.
