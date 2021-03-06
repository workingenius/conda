set -e
set +x

main_test() {
    export PYTHONHASHSEED=$(python -c "import random as r; print(r.randint(0,4294967296))")
    echo $PYTHONHASHSEED

    # basic unit tests
    python -m pytest --cov-report xml --shell=bash --shell=zsh -m "not installed" tests
    python setup.py --version

    # activate tests
    python setup.py install
    hash -r
    python -m conda info
    python -m pytest --cov-report xml --cov-append --shell=bash --shell=zsh -m "installed" tests
}

flake8_test() {
    python -m flake8 --statistics
}

conda_build_smoke_test() {
    conda config --add channels conda-canary
    conda build conda.recipe
}

conda_build_unit_test() {
    pushd conda-build
    echo
    echo ">>>>>>>>>>>> runnin conda-build unit tests >>>>>>>>>>>>>>>>>>>>>"
    echo
    python -m pytest -n 2 --basetemp /tmp/cb tests || echo -e "\n>>>>> conda-build tests exited with code" $? "\n\n\n"
    popd
}

which -a python
env | sort

if [[ $FLAKE8 == true ]]; then
    flake8_test
elif [[ -n $CONDA_BUILD ]]; then
    conda_build_smoke_test
    conda_build_unit_test
    # if [[ $CONDA_BUILD == 1.21.11 || $CONDA_BUILD == master ]]; then
    # fi
else
    main_test
fi
