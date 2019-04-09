import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import pandas as pd

filename = 'Temple.txt'
columns = ["temple name", "location","index","lat","long" ]
temples = pd.read_csv(filename, delimiter='\t', names=columns)

matlab_ind = list(range(72))

matlab_ind = np.subtract(np.array(matlab_ind),1).astype(int)
matlab_ind
lat_coords = temples.values[:,3]
long_coords = temples.values[:,4] # long is negative in the US

lat_coords = lat_coords[matlab_ind]
long_coords = long_coords[matlab_ind]

fig = plt.figure(figsize=(8, 8))
m = Basemap(projection='lcc', resolution=None,
            width=1E6, height=1E6, 
            lat_0=39, lon_0=-110,)
m.etopo(scale=1.0, alpha=0.5)

# Map (long, lat) to (x, y) for plotting
for index in range(len(lat_coords)):
    x, y = m(long_coords[index],lat_coords[index])
    plt.plot(x, y, 'ok', markersize=1)
    plt.text(x, y, str(index), fontsize=4)
# for index in range(len(allx)):
    

# x, y = m(long_coords[0], lat_coords[0])
# x1, y1 = m(long_coords[2], lat_coords[2])
# x, y = m(long_coords,lat_coords, 'ok')
# # plt.plot(x, y, 'ok', markersize=5)
# # plt.plot(x1, y1, 'ok', markersize=5)
#plt.plot(allx, ally)
# # plt.text(x, y, 'Provo', fontsize=12)
# # plt.text(x1, y1, 'Detroit', fontsize=12)
plt.show()