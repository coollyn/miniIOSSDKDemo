#!/bin/bash

rm -fr AVEngine/build && cmake -B AVEngine/build -S AVEngine && cmake --build AVEngine/build -j8
cp -fr AVEngine/build/AVEngine.framework miniIOSApp/Framework