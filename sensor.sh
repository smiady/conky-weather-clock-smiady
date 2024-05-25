#!/bin/bash

TEMP=$(sensors | grep 'Package id' | awk '{print $4}')

TEMP=${TEMP/+/}

echo ${TEMP/./,}
