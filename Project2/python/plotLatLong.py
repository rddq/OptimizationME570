import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import pandas as pd

# Note: basemap can be pretty complicated to install on windows
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
    #plotlatlong(yes)
