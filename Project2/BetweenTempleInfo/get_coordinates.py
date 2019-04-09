import requests
import json
from collections import namedtuple
import pandas as pd

def _make_request_url(temple1, temple2):
    (lat1, long1) = temple1
    (lat2, long2) = temple2
    request = 'http://router.project-osrm.org/route/v1/driving/' + str(long1) + ',' + str(lat1) + ';'+ str(long2) + ',' + str(lat2) + '?overview=false'
    return request

def coordinates_execute():
    filename = 'Temple.txt'
    temples = pd.read_csv(filename, delimiter='\t', header=None)

    lat_coords = temples.values[:,3]
    long_coords = temples.values[:,4] # long is negative in the US

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
                print("No path found between temples: " +str(index)+ " " +str(index1))
                all_time[index].append(None)
                all_distances[index].append(None)

    time_csv = pd.DataFrame(data=all_time)
    distance_csv = pd.DataFrame(data=all_distances)
    time_csv.to_csv('time_between_locations.csv')
    distance_csv.to_csv('distance_between_locations.csv')

if __name__ == "__main__":
    coordinates_execute()