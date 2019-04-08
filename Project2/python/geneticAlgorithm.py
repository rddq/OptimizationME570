from datetime import datetime
from datetime import timedelta
import pytz
import time
import numpy as np
import json
import pandas as pd
from fitness_all import fitness
import random


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

# Optimization Variables
cross_percent = .1
# I've done some fiddling around with the crossover percentage, Changing
# this doesn't seem to have much effect on the outcome. 
mutat_percent = .05 #Mutation percentage
# Increasing this actually tends to decrease the efficacy of the
# optimization (makes the optimal distance larger). 
num_gen = 1000
gen_size = 200
tourny_size = int(gen_size/2)

num_temples = len(timezones)
old_gen = np.zeros((num_temples,gen_size))
parents = np.zeros((2,))
children = np.zeros((num_temples,2))

# Generate 1st Generation (Random)
for i in range(gen_size):
    col = np.random.permutation(num_temples)
    old_gen[:,i] = np.transpose(col)
initial_gen = old_gen
initial_fit = fitness(old_gen, sessions, travel_time, daysotw, timezones)
# %Generation For Loop
for gen in range(num_gen):
    # Child Generation For loop
    old_fit = fitness(old_gen, sessions, travel_time, daysotw, timezones)
    # Do a tournament
    new_gen = np.zeros((num_temples,gen_size*2))
    for i in range(int(gen_size)):
        # Two tournaments for the two parents
        for j in range(2):
            # Select Parents (By fitness) (Tournament Style) 
            tourny_participants = random.sample(list(range(gen_size)), tourny_size)
            arg = np.argmin(np.array(old_fit)[tourny_participants])
            parents[j]= np.copy(tourny_participants[arg])    
        children[:,0] = np.copy(old_gen[:,np.copy(int(parents[0]))])
        children[:,1] = np.copy(old_gen[:,np.copy(int(parents[1]))])    
        #Crossover (Uniform) (With chromosome repair)
        for j in range(num_temples): #Iterate through the genes of the children. 
            if np.random.rand(1) < cross_percent:
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
                if len(np.unique(children[:,0])) < 72 or len(np.unique(children[:,1])) < 72:
                    h=1  
        #Mutation (Uniform)
        for j in range(num_temples): #Iterate through the genes of the children. 
            if np.random.rand(1) < mutat_percent:
                #Child gene swap and chromosome repair
                original_value = np.copy(children[j][0])
                mutated_value = np.random.randint(0,num_temples)
                gene_loc_1 = np.argwhere(children[:,0]==mutated_value).flatten()[0]
                children[gene_loc_1][0] = np.copy(original_value)
                children[j][0] = np.copy(mutated_value)
                if len(np.unique(children[:,0])) < 72 or len(np.unique(children[:,1])) < 72:
                    h=1
        #Mutation (Uniform) child 2 
        for j in range(num_temples): #Iterate through the genes of the children. 
            if np.random.rand(1) < mutat_percent:
                #Child gene swap and chromosome repair
                original_value = np.copy(children[j][1])
                mutated_value = np.random.randint(0,num_temples)
                gene_loc_2 = np.argwhere(children[:,1]==mutated_value).flatten()[0]
                children[gene_loc_2][1] = np.copy(original_value)
                children[j][1] = np.copy(mutated_value)
                if len(np.unique(children[:,0])) < 72 or len(np.unique(children[:,1])) < 72:
                    h=1
        #Store Children into new generation
        new_gen[:,2*(i+1)-2] = np.copy(children[:,0])
        new_gen[:,2*(i+1)-1] = np.copy(children[:,1])
    #Elitism (Pick top N)
    current_gen = np.concatenate((old_gen,new_gen),axis=1); #Concatenate together for fitness function
    new_fit = fitness(new_gen, sessions, travel_time, daysotw, timezones)
    current_gen_fit = old_fit+new_fit
    winners = np.array(current_gen_fit).argsort()[:gen_size]
    old_gen = np.copy(current_gen[:,winners])
    print(gen)
final_gen = old_gen
final_fit = fitness(old_gen, sessions, travel_time, daysotw, timezones)
I = np.argmin(final_fit)
fit_opt = final_fit[I]
xopt = final_gen[:,I]
print(xopt)
print(fit_opt)