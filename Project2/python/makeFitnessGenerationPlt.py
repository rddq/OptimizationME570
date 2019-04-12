import pandas as pd
import json
import numpy as np
from matplotlib import pyplot as plt

def makeFitnessGenPlot(experiment_name):
    with open('results/'+ experiment_name +'fitness.json', 'r') as outfile:
        all_fitness = json.load(outfile)
    plt.plot(list(range(len(all_fitness[0]))),all_fitness[0])
    plt.xlabel("Generation")
    plt.ylabel("Fitness (s)")
    plt.subplots_adjust(bottom=.1, left=.25)
    plt.show()
if __name__ == "__main__":
    makeFitnessGenPlot("testNoOptimal")