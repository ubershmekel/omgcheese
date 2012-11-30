"""
# with apples
> generate_levels(12, 6, '5fr.lua', 'easy', false)
generating
sorting
standardDeviation	1.2264344312443
mean	8.03
median	8
mode	{8}
maxmin	11	5
> generate_levels(12, 6, '5fh.lua', 'easy', true)
generating
sorting
standardDeviation	1.181122561401
mean	6.67
median	7
mode	{6}
maxmin	9	3

"""

import numpy as np
import matplotlib.pyplot as plt
import re

def getn(fname):
    t=open(fname).read()
    turns = re.findall(r'lev.minTurns = (\d+)', t)
    return [int(i) for i in turns]

tp = getn('LevelsHexHard.lua')
plt.hist(tp, bins = max(tp) - min(tp), color=(0,0,1), alpha=0.5)
tp = getn('LevelsHard.lua')
plt.hist(tp, bins = max(tp) - min(tp), color=(1,0,0), alpha=0.5)
