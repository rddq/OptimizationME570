import requests
import json
from collections import namedtuple
import pandas as pd
import webbrowser

def _make_request_string(temple1, temple2):
    (lat1, long1) = temple1
    (lat2, long2) = temple2
    request = 'http://router.project-osrm.org/route/v1/driving/' + str(long1) + ',' + str(lat1) + ';'+ str(long2) + ',' + str(lat2) + '?overview=false'
    return request

filename = 'Project2/temples.txt'
temples = pd.read_csv(filename, delim_whitespace=True)
lat_coords = temples['lat']
long_coords = temples['long'] # long is negative in the US

index = 0
index1 = 1
temple1 = (lat_coords[index], long_coords[index])
temple2 = (lat_coords[index1], long_coords[index1])
address = _make_request_string(temple1,temple2)

r = requests.get(address)
data = r.content
data_dict = json.loads(data)
route = data_dict['routes'][0]

distance = route['distance'] # in meters
time = route['duration'] # in seconds
print(str(distance))
print(str(time))

webbrowser.open_new_tab('https://map.project-osrm.org/?z=9&center=39.013849%2C-78.689575&loc=38.904793%2C-77.055960&loc=38.922491%2C-77.036640&loc=38.904793%2C-79.055961&hl=en&alt=0')
