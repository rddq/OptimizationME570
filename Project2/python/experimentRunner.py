import json
import pandas as pd
from geneticAlgorithm import runExperiment
import pytz
import numpy as np
from matplotlib import pyplot as plt
import time

def runAllExperiments(sessions,travel_time,daysotw,timezones,csv_name):
    # read excel file that specifies input values
    expts = pd.read_csv(csv_name+".csv")
    all_history = []
    all_fitness = []
    all_times = []
    xopts = []
    fopts = []
    all_iterations = []
    # Execute each experiment
    for i in list(range(expts.shape[0])):
        dictionary = {}
        cross_percent_ordered = expts["OrderedCrossPercent"][i]
        cross_percent_swap = expts["CrossPercent"][i]
        mutat_percent = expts["MutationPercent"][i]
        num_gen = int(expts["NumGen"][i])
        gen_size = int(expts["GenSize"][i])
        tourneykeep = expts["TourneyKeep"][i]
        runExperiment(cross_percent_ordered,cross_percent_swap,mutat_percent,num_gen,gen_size,tourneykeep,dictionary,sessions,travel_time,daysotw,timezones,all_history,all_fitness,all_times,xopts,fopts,all_iterations)
        if i%5 == 1:
            save_parameters(csv_name,all_history,all_fitness,all_times,fopts,xopts,all_iterations)
        print(i)
    save_parameters(csv_name,all_history,all_fitness,all_times,fopts,xopts,all_iterations)

def save_parameters(csv_name,all_history,all_fitness,all_times,fopts,xopts,all_iterations):
    # Save the history of the experiments to json files
    with open('results/'+ csv_name +'history.json', 'w') as outfile:
        json.dump(all_history, outfile)
    with open('results/'+ csv_name +'fitness.json', 'w') as outfile:
        json.dump(all_fitness, outfile)
    with open('results/'+ csv_name +'time.json', 'w') as outfile:
        json.dump(all_times, outfile)
    with open('results/'+ csv_name +'fopt.json', 'w') as outfile:
        json.dump(fopts, outfile)
    with open('results/'+ csv_name +'xopt.json', 'w') as outfile:
        json.dump(xopts, outfile)
    with open('results/'+ csv_name +'iterations.json', 'w') as outfile:
        json.dump(all_iterations, outfile)

def execute(csv_name=None):
    sessionFileName = 'TempleSchedules/templeEndowmentSchedules.json'
    with open(sessionFileName, 'r') as file1:
        sessions = json.load(file1)

    timezonesFileName = 'TimeZones/timezones.json'
    with open(timezonesFileName, 'r') as file2:
        timezones = json.load(file2)
    timezones = [pytz.timezone(t) for t in timezones]

    timefilename = 'BetweenTempleInfo/timeBetweenLocations.txt'
    travel_time = pd.read_csv(timefilename, delimiter='\t')
    travel_time = travel_time.values
    travel_time = np.delete(travel_time,0,1)
    daysotw = ["Monday", "Tuesday", "Wednesday", "Thursday","Friday","Saturday","Sunday"]
    # Either run one or run multiple experimetns
    runOneExperiment(sessions,travel_time,daysotw,timezones,csv_name)
    #runAllExperiments(sessions,travel_time,daysotw,timezones,csv_name)

def runOneExperiment(sessions,travel_time,daysotw,timezones,csv_name):
    # Specify parameters for experiment
    cross_percent_ordered = 0.03
    cross_percent_swap = 0
    mutat_percent = 0.001
    num_gen = 100
    gen_size = 20
    tourneykeep = 0.85
    dictionary = {}
    all_history = []
    all_fitness = []
    all_times = []
    all_iterations = []
    xopts = []
    fopts = []
    runExperiment(cross_percent_ordered,cross_percent_swap,mutat_percent,num_gen,gen_size,tourneykeep,dictionary,sessions,travel_time,daysotw,timezones,all_history,all_fitness,all_times,xopts,fopts,all_iterations)
    print(fopts[0])
    print(xopts[0])
    save_parameters(csv_name, all_history, all_fitness, all_times, fopts, xopts, all_iterations)
    plt.plot(list(range(num_gen)),all_fitness[0])
    plt.show()

if __name__ == "__main__":
    starttime = time.time()
    # Name of input/output file
    execute("Endowment11")
    endtime = time.time()
    print(endtime-starttime)