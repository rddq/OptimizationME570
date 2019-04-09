import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import pandas as pd

filename = 'Temple.txt'
columns = ["temple name", "location","index","lat","long" ]
temples = pd.read_csv(filename, delimiter='\t', names=columns)

matlab_ind = [52,47,26,3,48,59,65,58,4,18,36,67,29,10,30,17,39,19,33,60,45,23,27,40,32,71,9,28,20,62,66,51,8,70,13,2,56,15,64,72,54,44,25,42,55,57,24,46,49,41,7,50,43,53,11,31,38,63,34,16,37,21,12,5,61,1,68,35,69,6,14,22,52]

matlab_ind = np.subtract(np.array(matlab_ind),1).astype(int)
matlab_ind
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
allx, ally = m(long_coords, lat_coords)
x, y = m(long_coords[0], lat_coords[0])
x1, y1 = m(long_coords[2], lat_coords[2])
#x, y = m(long_coords,lat_coords)
# plt.plot(x, y, 'ok', markersize=5)
# plt.plot(x1, y1, 'ok', markersize=5)
plt.plot(allx, ally)
# plt.text(x, y, 'Provo', fontsize=12)
# plt.text(x1, y1, 'Detroit', fontsize=12)
plt.show()