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
