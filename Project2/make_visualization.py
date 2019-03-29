import pandas as pd
import webbrowser

filename = 'Project2/temples.txt'
temples = pd.read_csv(filename, delim_whitespace=True)

lat_coords = temples['lat']
long_coords = temples['long'] # long is negative in the US


def _make_path_visualization_url_osrm(lats, longs):
    url = 'https://map.project-osrm.org/?z=9&'
    for index in range(lats.size):
        if index != (1 or 7) and index != 8:
            url += 'loc=' + str(lats[index]) + '%2C' + str(longs[index]) + '&'
        if index == 8:
            break 
    url += 'hl=en&alt=0'
    return url

def _make_path_visualization_url_graphhopper(lats,longs):
    url = 'https://graphhopper.com/maps/?'
    for index in range(lats.size):
        if index != 30 and index != 31:
            url += 'point=' + str(lats[index]) + '%2C' + str(longs[index]) + '&'
    url += 'locale=nl-NL&vehicle=car&weighting=fastest&elevation=true&use_miles=false&layer=Omniscale'
    return url

url_string = _make_path_visualization_url_graphhopper(lat_coords, long_coords)
webbrowser.open_new_tab(url_string)
#webbrowser.open_new_tab('https://map.project-osrm.org/?z=9&center=39.013849%2C-78.689575&loc=38.904793%2C-77.055960&loc=38.922491%2C-77.036640&loc=38.904793%2C-79.055961&hl=en&alt=0')
#'https://graphhopper.com/maps/?point=36.686041%2C-6.122131&point=37.38107%2C-5.990295&point=37.872685%2C-4.777679&point=Granada%2C%20Spain&locale=nl-NL&vehicle=car&weighting=fastest&elevation=true&use_miles=false&layer=Omniscale'