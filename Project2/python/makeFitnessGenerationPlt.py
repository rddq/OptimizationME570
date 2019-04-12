import pandas as pd
import json
import numpy as np
from matplotlib import pyplot as plt

def makeFitnessGenPlot(experiment_name):
    with open('results/'+ experiment_name +'history.json', 'r') as outfile:
        all_history = json.load(outfile)
    with open('results/'+ experiment_name +'fitness.json', 'r') as outfile:
        all_fitness = json.load(outfile)
    with open('results/'+ experiment_name +'time.json', 'r') as outfile:
        all_times = json.load(outfile)
    with open('results/'+ experiment_name +'fopt.json', 'r') as outfile:
        fopts = json.load(outfile)
    with open('results/'+ experiment_name +'xopt.json', 'r') as outfile:
        xopts = json.load(outfile)
    with open('results/'+ experiment_name +'iterations.json', 'r') as outfile:
        all_iterations = json.load(outfile)
    # expts = pd.read_csv(experiment_name+".csv")
    # expts.loc[:,'fopt'] = pd.Series(fopts, index=expts.index)
    # expts.loc[:,'iterations'] = pd.Series(all_iterations, index=expts.index)
    # expts.loc[:,'time'] = pd.Series(all_times, index=expts.index)
    plt.plot(list(range(len(all_fitness[0]))),all_fitness[0])
    plt.xlabel("Generation")
    plt.ylabel("Fitness (s)")
    plt.subplots_adjust(bottom=.1, left=.25)
    plt.show()
    #expts.to_csv(experiment_name+ "pretty.csv")
if __name__ == "__main__":
    makeFitnessGenPlot("pastResults/testNoOptimal")