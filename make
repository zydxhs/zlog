#!/usr/bin/env bash

if [ ! -d "build" ]; then
    mkdir build
fi

cd build
cmake -DCMAKE_BUILD_TYPE=Debug -DUNIT_TEST=1 ..
#cmake -DCMAKE_BUILD_TYPE=Release -DUNIT_TEST=1 ..

make

os=`uname`

if [ "$os" = "Linux" ]; then
    #make package
    packs=`find cpack/ -name "CPackConfig.cmake"`
    for p in $packs
    do
        cpack --config "$p"
    done
fi

if [ "$os" = "SunOS" ]; then
    make -u test
else
    make test
fi
#lcov -d . -c -o myapp.info
#genhtml -o result myapp.info
