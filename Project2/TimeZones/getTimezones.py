import timezonefinder
import pandas as pd 
import json

def timezone_execute():
    tf = timezonefinder.TimezoneFinder()
    filename = 'Temple.txt'
    temples = pd.read_csv(filename, delimiter='\t', header=None)

    lat_coords = temples.values[:,3]
    long_coords = temples.values[:,4] # long is negative in the US

    all_results = []
    for index in range(len(lat_coords)):
        result = tf.timezone_at(lng=long_coords[index], lat=lat_coords[index])
        all_results.append(result)
    with open('timezones.json','w') as filename:
        json.dump(all_results,filename)

if __name__ == "__main__":
    timezone_execute()