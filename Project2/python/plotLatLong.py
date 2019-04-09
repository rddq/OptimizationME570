import numpy as np
import matplotlib.pyplot as plt
import Basemap
import pandas as pd

filename = 'Temple.txt'
columns = ["temple name", "location","index","lat","long" ]
temples = pd.read_csv(filename, delimiter='\t', names=columns)

matlab_ind = [52,44,70,72,22,57,13,62,19,6,12,48,36,59,20,14,42,3,31,8,18,1,51,56,55,58,69,11,68,54,66,60,23,7,53,46,5,45,26,32,33,35,39,15,67,43,17,30,40,21,29,61,9,10,28,27,4,16,41,34,38,63,65,2,47,25,71,64,49,50,24,37]
matlab_ind = matlab_ind-1

lat_coords = temples.values[:,3]
long_coords = temples.values[:,4] # long is negative in the US

lat_coords = lat_coords[matlab_ind]
long_coords = long_coords[matlab_ind]

fig = plt.figure(figsize=(8, 8))
m = Basemap(projection='lcc', resolution=None,
            width=8E6, height=8E6, 
            lat_0=45, lon_0=-100,)
m.etopo(scale=0.5, alpha=0.5)

# Map (long, lat) to (x, y) for plotting
x, y = m(-122.3, 47.6)
plt.plot(x, y, 'ok', markersize=5)
plt.text(x, y, ' Seattle', fontsize=12)