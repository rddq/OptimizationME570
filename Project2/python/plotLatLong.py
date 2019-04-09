import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import pandas as pd

def plotlatlong(matlab_ind):
    filename = 'Temple.txt'
    columns = ["temple name", "location","index","lat","long" ]
    temples = pd.read_csv(filename, delimiter='\t', names=columns)

    matlab_ind = np.subtract(np.array(matlab_ind),1).astype(int)
    lat_coords = temples.values[:,3]
    long_coords = temples.values[:,4] # long is negative in the US

    lat_coords = lat_coords[matlab_ind]
    long_coords = long_coords[matlab_ind]

    fig = plt.figure(figsize=(8, 8))
    m = Basemap(projection='lcc', resolution=None,
                width=6E6, height=6E6, 
                lat_0=45, lon_0=-100,)
    m.etopo(scale=1.0, alpha=0.5)

    # Map (long, lat) to (x, y) for plotting
    x,y = m(long_coords,lat_coords)  
    plt.plot(x, y)
    plt.show()
    
if __name__ == "__main__":
    plotlatlong([52,48,36,39,62,50,23,69,68,1,34,59,25,16,5,46,21,14,3,41,49,35,24,8,47,15,33,27,18,12,65,42,29,0,66,6,20,17,71,53,40,19,45,28,58,9,44,10,31,67,4,56,26,70,7,38,63,13,61,2,51,37,55,57,22,32,43,60,54,30,64,11,52])
