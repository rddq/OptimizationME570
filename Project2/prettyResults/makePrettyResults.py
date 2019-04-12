import pandas as pd
import json
import numpy as np
from matplotlib import pyplot as plt

def makePretty(folder, experiment_name):
    '''
    Concatenates input csv and output json, and outputs to a csv to prepare to use in JMP
    '''
    with open(folder+ experiment_name +'time.json', 'r') as outfile:
        all_times = json.load(outfile)
    with open(folder+ experiment_name +'fopt.json', 'r') as outfile:
        fopts = json.load(outfile)
    with open('folder'+ experiment_name +'iterations.json', 'r') as outfile:
        all_iterations = json.load(outfile)
    expts = pd.read_csv("inputs/"+experiment_name+".csv")
    expts.loc[:,'fopt'] = pd.Series(fopts, index=expts.index)
    expts.loc[:,'iterations'] = pd.Series(all_iterations, index=expts.index)
    expts.loc[:,'time'] = pd.Series(all_times, index=expts.index)
    expts.to_csv("prettyResults" + experiment_name + "pretty.csv")
if __name__ == "__main__":
    folder = 'results/pastResults/'
    name = "testNoOptimal"
    makePretty(folder,name)