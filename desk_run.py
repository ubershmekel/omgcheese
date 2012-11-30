#!/usr/bin/python

import sys
import subprocess
import platform
import os

#SDK = "C:/Users/yuv/Downloads/moai-sdk"
#SDK = open('sdk_location.txt').read().strip()
SDK = os.path.expandvars('$HOME/Downloads/moai-sdk')

WINRUN = '/bin/win32/moai.exe'
OSXRUN = '/bin/osx/moai'
LINUXRUN = '/bin/linux/moai'

SUFFIX = ' config.lua main.lua'

system = platform.system()
if system == "Windows":
    SDK = os.path.expandvars(r'%userprofile%/Downloads/moai-sdk')
    run = SDK + WINRUN
elif system == "Linux":
    run = SDK + LINUXRUN
else:
    run = SDK + OSXRUN


os.chdir('host-chrome')
subprocess.check_call('bash sdk-setup.sh ' + SDK, shell=True)

os.chdir('build')
line = run + SUFFIX
print(line)
try:
    subprocess.check_call(line, shell=True)
except KeyboardInterrupt:
    pass

#print('--- press enter ---')
#sys.stdin.readline()
