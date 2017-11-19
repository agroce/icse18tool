#!/bin/bash

ANALYZE=${HOME}/.local/bin/analyze_mutants

# Try and analyze mutants with all valid mutants and running
for f in $(find mutants/valid/ -name "*.java" | cut -d'.' -f1,4 | sort -u); do    # Use some cut magic to get the original file name
    ${ANALYZE} $(echo ${f} | sed 's;mutants/valid/;;') --mutantDir $(dirname ${f}) "mvn clean test -Dsurefire.skipAfterFailureCount=1"
done
