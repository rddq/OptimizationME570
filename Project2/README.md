# Project 2 - Endowment Session Attender

This project for ME 575 at BYU involved making a genetic algorithm that would solve a type of traveling salesman problem with schedules.
It is attending an endowment session in each temple of the Church of Jesus Christ of Latter Day Saints.
The project was originally coded up in matlab but then moved to python to improve datetime performance.

## Data Collection
### Travel time between temples
The time to travel between temples was calculated using the lat long coordinates in the Temple.txt document. The Open Street Map Routing Machine API was called from a python script to make a distance and a time matrix.

### Temple Schedules
The temple schedules were scraped from https://churchofjesuschrist.org using Selenium.
It worked as of April 2019.

### Experiment Running
A latin hypercube DOE was used for exploring the parameter space. An RSM analysis was done in JMP. The files for creating and running these experiments are contained in the python folder.

## Packages used 
Packages were installed with anaconda to prevent package dependency headaches.

Numpy, Pandas, SciPy, pytz, timezonefinder, requests, pyDOE, and Basemaps.
Basemaps can be difficult to install especially for windows and requires additional dependencies. It is only used for map visualization.

## Experiments Running
The experiment results are in the results folder. The single run experiments were not documented super well, only with an info.txt file in the results folder. 
The other multiple experiment runs have their parameters in the inputs folder.

Fitness.json is the fitness of the best in each generation.

history.json is the x values for the best fitness in each generation.

time.json is the amount of time it took for the experiment to run.

fopt.json is the best fitness in each experiment.

xopt.json is the temple ordering for the best fitness in each experiment.
xopt has indices matching the Temple.txt file, the history.json have indices starting at 0.

iterations.xopt is the number of iterations per run that it took to converge. This dynamic was removed in most experiments. 