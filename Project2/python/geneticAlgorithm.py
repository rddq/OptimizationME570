from datetime import datetime
from datetime import timedelta
import pytz
import time
import numpy as np
import json
import pandas as pd
from fitness_all import fitness


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
num_gen = 100
gen_size = 20
tourny_size = int(gen_size/3)

num_temples = len(timezones)
old_gen = np.zeros((num_temples,gen_size))
new_gen = old_gen
current_gen = [old_gen,old_gen]
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
    for i in range(int(gen_size/2)):
        # Two tournaments for the two parents
        for j in range(2):
            # Select Parents (By fitness) (Tournament Style)
            tourny_participants = np.random.randint(0, gen_size, tourny_size)
            arg = np.argmin(np.array(old_fit)[tourny_participants.tolist()])
            parents[j]= tourny_participants[arg]    
        children[:,0] = old_gen[:,int(parents[0])]
        children[:,1] = old_gen[:,int(parents[1])]      
        #Crossover (Uniform) (With chromosome repair)
        for j in range(num_temples): #Iterate through the genes of the children. 
            if np.random.rand(1) < cross_percent:
                #Store the genes 
                temp1 = np.copy(children[j][0]) #Temporarily store child one's gene
                temp2 = np.copy(children[j][1])       
                #Child one gene swap and chromosome repair
                gene_loc_1 = np.argwhere(children[:,0]==temp2).flatten()[0] #Find the location of the gene to be swapped
                gene_loc_2 = np.argwhere(children[:,1]==temp1).flatten()[0]               
                children[gene_loc_1][0] = temp1
                children[j][0] = temp2
                children[gene_loc_2][1] = temp2
                children[j][1] = temp1
        #Mutation (Uniform)
        for j in range(num_temples): #Iterate through the genes of the children. 
            if np.random.rand(1) < mutat_percent:
                #Child gene swap and chromosome repair
                original_value = children[j][0]
                mutated_value = np.random.randint(0,num_temples)
                gene_loc_1 = np.argwhere(children[:,0]==mutated_value).flatten()[0]
                children[gene_loc_1][0] = original_value
                children[j][0] = mutated_value
        #Mutation (Uniform) child 2 
        for j in range(num_temples): #Iterate through the genes of the children. 
            if np.random.rand(1) < mutat_percent:
                #Child gene swap and chromosome repair
                original_value = children[j][1]
                mutated_value = np.random.randint(0,num_temples)
                gene_loc_2 = np.argwhere(children[:,1]==mutated_value).flatten()[0]
                children[gene_loc_1][1] = original_value
                children[j][1] = mutated_value
        #Store Children into new generation
        new_gen[:,i] = children[:,1]
        new_gen[:,i+1] = children[:,2]
      #Elitism (Pick top N)
    current_gen = [old_gen, new_gen]; #Concatenate together for fitness function
    new_fit = fitness(new_gen, sessions, travel_time, daysotw, timezones)
    current_gen_fit = [old_fit, new_fit]
#     [~,winners] = mink(current_fit,gen_size); %Determine winning generation's index
#     old_gen = current_gen(:,winners);   %Place winning generation as surviving gen. 

# final_gen = old_gen;
# final_fit = fitnesspy.fitness(old_gen);
# [f_opt,I] = min(final_fit);
# x_opt = final_gen(:,I)