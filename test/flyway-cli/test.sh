#!/bin/bash
set -e
source dev-container-features-test-lib

check "validate flyway version" flyway version | grep 10.17.3

reportResults