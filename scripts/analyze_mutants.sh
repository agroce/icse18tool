#!/bin/bash

ANALYZE=${HOME}/.local/bin/analyze_mutants

# Set up top-level killed/not-killed
killed=topkilled.txt
notkilled=topnotkilled.txt
rm -f ${killed}
rm -f ${notkilled}

# Try and analyze mutants with all valid mutants and running
for f in $(find mutants/valid/ -name "*.java" | cut -d'.' -f1,4 | sort -u); do    # Use some cut magic to get the original file name
    ${ANALYZE} $(echo ${f} | sed 's;mutants/valid/;;') --mutantDir $(dirname ${f}) "mvn clean test -Dsurefire.skipAfterFailureCount=1"
    # Save results into top-level files
    cat killed.txt >> ${killed}
    cat notkilled.txt >> ${notkilled}
done
