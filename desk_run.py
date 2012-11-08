#!/usr/bin/python

import sys
import subprocess
import platform
import os

#SDK = "C:/Users/yuv/Downloads/moai-sdk"
SDK = open('sdk_location.txt').read().strip()

WINRUN = '/bin/win32/moai.exe'
OSXRUN = '/bin/osx/moai'

SUFFIX = ' config.lua main.lua'

if platform.system() == "Windows":
    run = WINRUN
else:
    run = OSXRUN


os.chdir('host-chrome')
subprocess.check_call('bash sdk-setup.sh', shell=True)

os.chdir('build')
line = SDK + run + SUFFIX
print(line)
subprocess.check_call(line, shell=True)

#print('--- press enter ---')
#sys.stdin.readline()
