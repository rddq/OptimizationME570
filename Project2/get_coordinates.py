from python-osrm-master.osrm import osrm

points = [(-33.45017046193167,-70.65281867980957),
          (-33.45239047269638,-70.65300107002258),
          (-33.453867464504555,-70.65277576446533)]
result = osrm.match(points, step=False, overview="simplified")