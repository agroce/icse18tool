#1/bin/bash

MUTATE=${HOME}/.local/bin/mutate

mkdir -p mutants/invalid
mkdir -p mutants/valid

classpath=$(mvn dependency:build-classpath | grep -A1 "\[INFO\] Dependencies classpat " | grep -v "Dependencies" | paste -sd':' | sed 's;--;;g'):target/classes
echo ${classpath}
mvn clean compile > /dev/null
for f in $(find src/main/java/ -name "*.java"); do
    # Reset back to original first
    git checkout src/main/java/
    mvn clean compile > /dev/null

    # Make relevant directories in both valid and invalid
    mkdir -p mutants/valid/$(dirname ${f})
    mkdir -p mutants/invalid/$(dirname ${f})

    # Generate all mutants into valid first
    cp ${f} mutants/valid/$(dirname ${f})
    ${MUTATE} mutants/valid/${f} --noCheck --mutantDir mutants/valid/$(dirname ${f}) > /dev/null

    # For each mutant, copy it into the same place as the original, compile to see if it is valid
    # For each invalid mutant, move to relevant area
    for m in $(find mutants/valid/ -name "$(basename ${f} | sed 's;.java;.mutant.*.java;')"); do
        cp ${m} ${f}
        #mvn compile > /dev/null
        javac -cp ${classpath} -d target/classes ${f} &> /dev/null
        if [[ $? != 0 ]]; then
            echo ${m} IS INVALID
            mv ${m} $(echo ${m} | sed 's;valid;invalid;')   # Move the invalid mutant into the proper invalid location
        fi
    done

    # Cleanup by removing the original source from the valid/ directory and removing the tmp source file
    rm mutants/valid/${f}
    rm $(find mutants/ -name .um.tmp_mutant.java)
done
