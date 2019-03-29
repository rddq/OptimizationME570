import requests
import json
from collections import namedtuple
import pandas as pd
import webbrowser
import time

def _make_request_url(temple1, temple2):
    (lat1, long1) = temple1
    (lat2, long2) = temple2
    request = 'http://router.project-osrm.org/route/v1/driving/' + str(long1) + ',' + str(lat1) + ';'+ str(long2) + ',' + str(lat2) + '?overview=false'
    return request

filename = 'Project2/temples.txt'
temples = pd.read_csv(filename, delim_whitespace=True)

lat_coords = temples['lat']
long_coords = temples['long'] # long is negative in the US

all_time = []
all_distances = []
for index in range(lat_coords.size):
    all_time.append([])
    all_distances.append([])
    for index1 in range(lat_coords.size):
        temple1 = (lat_coords[index], long_coords[index])
        temple2 = (lat_coords[index1], long_coords[index1])
        address = _make_request_url(temple1, temple2)
        r = requests.get(address)
        data = r.content
        data_dict = json.loads(data)
        if data_dict['code'] == 'Ok':
            route = data_dict['routes'][0]
            distance = route['distance'] # in meters
            time = route['duration'] # in seconds
            all_time[index].append(time)
            all_distances[index].append(distance)
        else:
            print("The distance between templse: " + str(index)+ " " +str(index1) + " Did not work")
            all_time[index].append(None)
            all_distances[index].append(None)
time_csv = pd.DataFrame(data=all_time)
distance_csv = pd.DataFrame(data=all_distances)
time_csv.to_csv('time_between_locations')
distance_csv.to_csv('distance_between_locations')

def _make_path_visualization_url(lats, longs):
    url = 'https://map.project-osrm.org/?z=9&center=' + str(lats[0]) + '%2C' + str(longs[0]) + '&'
    for index in range(lats.size):
        if index != (1 or 7) and index != 8:
            url += 'loc=' + str(lats[index]) + '%2C' + str(longs[index]) + '&'
        if index == 8:
            break 
    url += 'hl=en&alt=0'
    return url

url_string = _make_path_visualization_url(lat_coords, long_coords)
webbrowser.open_new_tab(url_string)
#webbrowser.open_new_tab('https://map.project-osrm.org/?z=9&center=39.013849%2C-78.689575&loc=38.904793%2C-77.055960&loc=38.922491%2C-77.036640&loc=38.904793%2C-79.055961&hl=en&alt=0')
