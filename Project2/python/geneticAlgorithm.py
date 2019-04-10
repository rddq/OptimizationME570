from datetime import datetime
from datetime import timedelta
import pytz
import time
import numpy as np
import json
import pandas as pd
from fitness_all import fitnessOfPath
import random
from scipy.stats import truncnorm
from matplotlib import pyplot as plt

def fitness(generation,sessions,travel_time,daysotw,timezones,dictionary):
    m = np.size(generation,1)
    total_time = []
    for i in range(m):
        gen_time = 0
        path = generation.astype(int)
        path = path[:,i]
        listpath = str(path.tolist())
        if listpath in dictionary:
            fitness_path = dictionary[listpath]
        else:
            fitness_path = fitnessOfPath(path,sessions,travel_time,daysotw,timezones)
            dictionary[listpath] = fitness_path
        total_time.append(fitness_path)  
    return total_time

def runExperiment(cross_percent_ordered,cross_percent_swap,mutat_percent,num_gen,gen_size,tourneykeep,dictionary,sessions,travel_time,daysotw,timezones,all_history,all_fitness,all_times,xopts,fopts,all_iterations):
    start = time.time()
    tourny_size = 2
    num_temples = len(timezones)

    old_gen = np.zeros((num_temples,gen_size))
    parents = np.zeros((2,))
    children = np.zeros((num_temples,2))
    # Generate 1st Generation (Random)
    generation = np.array([36.0, 39.0, 50.0, 23.0, 69.0, 68.0, 62.0, 1.0, 34.0, 59.0, 25.0, 16.0, 41.0, 5.0, 3.0, 46.0, 21.0, 14.0, 49.0, 35.0, 24.0, 8.0, 47.0, 18.0, 15.0, 33.0, 27.0, 12.0, 42.0, 65.0, 29.0, 72.0, 66.0, 6.0, 4.0, 20.0, 17.0, 71.0, 53.0, 52.0, 48.0, 40.0, 19.0, 28.0, 45.0, 58.0, 9.0, 44.0, 10.0, 31.0, 67.0, 56.0, 26.0, 70.0, 7.0, 38.0, 13.0, 63.0, 2.0, 61.0, 51.0, 37.0, 55.0, 57.0, 22.0, 32.0, 43.0, 60.0, 54.0, 30.0, 64.0, 11.0])
    col = np.subtract(generation,1)
    for i in range(gen_size):
        #col = np.random.permutation(num_temples)
        old_gen[:,i] = np.transpose(col)
    initial_gen = old_gen
    initial_fit = fitness(old_gen, sessions, travel_time, daysotw, timezones, dictionary)
    prev_fit = np.array(initial_fit)
    # Generation For Loop
    fitness_history = []
    best_history = []
    prev_fit_one_behind = 20000000000000000
    end_timer = 0
    for gen in range(num_gen):
        # Child Generation For loop
        old_fit = prev_fit.tolist()
        # Do a tournament
        new_gen = np.zeros((num_temples,gen_size*2))
        for i in range(int(gen_size)):
            # Two tournaments for the two parents
            for j in range(2):
                # Select Parents (By fitness) (Tournament Style) 
                tourny_participants = random.sample(list(range(gen_size)), tourny_size)
                arg = np.argmin(np.array(old_fit)[tourny_participants])
                if(np.random.rand(1)>tourneykeep):
                    del tourny_participants[arg]
                    parents[j] = np.copy(tourny_participants[0])
                else:
                    parents[j]= np.copy(tourny_participants[arg])    
            children[:,0] = np.copy(old_gen[:,np.copy(int(parents[0]))])
            children[:,1] = np.copy(old_gen[:,np.copy(int(parents[1]))])    
            #Crossover (Uniform) (With chromosome repair)
            for j in range(num_temples): #Iterate through the genes of the children. 
                if np.random.rand(1) < cross_percent_swap:
                    #Store the genes 
                    temp1 = np.copy(children[j][0]) #Temporarily store child one's gene
                    temp2 = np.copy(children[j][1])       
                    #Child one gene swap and chromosome repair
                    gene_loc_1 = np.argwhere(children[:,0]==temp2).flatten()[0] #Find the location of the gene to be swapped
                    gene_loc_2 = np.argwhere(children[:,1]==temp1).flatten()[0]               
                    children[gene_loc_1][0] = np.copy(temp1)
                    children[j][0] = np.copy(temp2)
                    children[gene_loc_2][1] = np.copy(temp2)
                    children[j][1] = np.copy(temp1)
            #Ordered Crossover
            crossover_values = []
            for j in range(num_temples): #Iterate through the genes of the children. 
                if np.random.rand(1) < cross_percent_ordered:
                    crossover_values.append(j)
            # array of the order of the values of the first parent
            if len(crossover_values) != 0:
                child1 = children[:,0]
                child2 = children[:,1]
                indices1 = np.sort([np.where(child1==cv)[0][0] for cv in crossover_values])
                indices2 = np.sort([np.where(child2==cv)[0][0] for cv in crossover_values])
                temp1 = np.copy(child1)
                temp2 = np.copy(child2)
                child1[indices1] = np.copy(temp2[indices2])
                child2[indices2] = np.copy(temp1[indices1])       
            #Mutation (Uniform)
            for chil in range(2):
                for j in range(num_temples): #Iterate through the genes of the children. 
                    if np.random.rand(1) < mutat_percent:
                        # Child gene insertion
                        mutated_value = np.random.randint(0,num_temples)
                        if mutated_value == children[j,chil]:
                            continue
                        gene_loc_mutate = np.argwhere(children[:,chil]==mutated_value).flatten()[0]
                        child = children[:,chil]
                        updated_child = np.insert(child,j,mutated_value)
                        if j > gene_loc_mutate:
                            child = np.delete(updated_child,gene_loc_mutate)
                        else:
                            child = np.delete(updated_child,gene_loc_mutate+1)
                        children[:,chil] = np.copy(child)
            #Store Children into new generation       
            new_gen[:,2*(i+1)-2] = np.copy(children[:,0])
            new_gen[:,2*(i+1)-1] = np.copy(children[:,1])
        #Elitism (Pick top N)
        current_gen = np.concatenate((old_gen,new_gen),axis=1); #Concatenate together for fitness function
        new_fit = fitness(new_gen, sessions, travel_time, daysotw, timezones, dictionary)
        current_gen_fit = old_fit+new_fit
        winners = np.array(current_gen_fit).argsort()[:gen_size]
        old_gen = np.copy(current_gen[:,winners])
        prev_fit = np.copy(np.array(current_gen_fit)[winners])     
        I = np.argmin(current_gen_fit)
        fit_now = current_gen_fit[I]
        fitness_history.append(fit_now)
        best_history.append(current_gen[:,I].tolist())
        # Check if the GA is stuck
        print(gen)
        # if fit_now < prev_fit_one_behind:
        #     prev_fit_one_behind = fit_now
        #     end_timer = 0
        # else:
        #     if end_timer > 200:
        #         end_timer = 0

        #     else:
        #         end_timer += 1 
    final_gen = old_gen
    final_fit = fitness(old_gen, sessions, travel_time, daysotw, timezones, dictionary)
    I = np.argmin(final_fit)   
    fit_opt = final_fit[I]
    xopt = final_gen[:,I]+1
    endtime = time.time()
    all_iterations.append(gen)
    all_history.append(best_history)
    all_fitness.append(fitness_history)
    all_times.append(endtime-start)
    xopts.append(xopt.tolist())
    fopts.append(fit_opt)
    print(gen)

def runAllExperiments(sessions,travel_time,daysotw,timezones,csv_name):
    expts = pd.read_csv(csv_name+".csv")
    # Optimization Variables
    all_history = []
    all_fitness = []
    all_times = []
    xopts = []
    fopts = []
    all_iterations = []
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
    runOneExperiment(sessions,travel_time,daysotw,timezones,csv_name)

def runOneExperiment(sessions,travel_time,daysotw,timezones,csv_name):
    cross_percent_ordered = 0.09
    cross_percent_swap = 0.03
    mutat_percent = 0.03
    num_gen = 1500
    gen_size = 100
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
    execute("testNoOptimal")
    endtime = time.time()
    print(endtime-starttime)
