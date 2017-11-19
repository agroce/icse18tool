#1/bin/bash

MUTATE=${HOME}/.local/bin/mutate

mkdir -p mutants/invalid
mkdir -p mutants/valid

for f in $(find src/main/java/ -name "*.java"); do
    # Make relevant directories in both valid and invalid
    mkdir -p mutants/valid/$(dirname ${f})
    mkdir -p mutants/invalid/$(dirname ${f})
    # Generate all mutants into valid first
    ${MUTATE} mutants/valid/${f} --noCheck --mutantDir mutants/valid/$(dirname ${f}) > /dev/null

    # For each mutant, copy it into the same place as the original, compile to see if it is valid
    # For each invalid mutant, move to relevant area
    for m in $(find mutants/valid/ -name "*.mutant.*.java"); do
        cp ${m} ${f}
        mvn clean compile > /dev/null   # Using clean is important, cannot trust Maven to compile properly without cleaning...
        if [[ $? != 0 ]]; then
            echo ${m} IS INVALID
            mv ${m} $(echo ${m} | sed 's;valid;invalid;')   # Move the invalid mutant into the proper invalid location
        fi
    done
done
