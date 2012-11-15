#!/bin/bash

#================================================================#
# Copyright (c) 2010-2011 Zipline Games, Inc.
# All Rights Reserved.
# http://getmoai.com
#================================================================#
export MOAI_SDK=$1

cp -rf ../lua/* ./build/
cp -rf ../images/* ./build/
cp -rf $MOAI_SDK/bin/chrome/* ./build/
cp -rf $MOAI_SDK/include/lua-modules ./build/
cp -rf host-source/* ./build/
