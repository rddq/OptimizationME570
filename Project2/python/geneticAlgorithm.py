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
                gene_loc_1 = np.argwhere(children[:,0]==temp2).flatten() #Find the location of the gene to be swapped
                gene_loc_2 = np.argwhere(children[:,1]==temp1).flatten()               
                children[gene_loc_1][0] = temp1
                children[j][0] = temp2
                children[gene_loc_2][1] = temp2
                children[j][1] = temp1
        #Crossover (Uniform) (With chromosome repair)
        for j in range(num_temples): #Iterate through the genes of the children. 
            if np.random.rand(1) < cross_percent:
                #Store the genes 
                temp1 = np.copy(children[j][0]) #Temporarily store child one's gene
                temp2 = np.copy(children[j][1])       
                #Child one gene swap and chromosome repair
                gene_loc_1 = np.argwhere(children[:,0]==temp2).flatten() #Find the location of the gene to be swapped
                gene_loc_2 = np.argwhere(children[:,1]==temp1).flatten()               
                children[gene_loc_1][0] = temp1
                children[j][0] = temp2
                children[gene_loc_2][1] = temp2
                children[j][1] = temp1
        
#         %Mutation (Uniform)
#         for j=1:length(temple_name) %Iterate through the genes of the children.
#             %Child 1 Mutation
#             if rand<mutat_percent
#                 %Store the gene
#                 temp = randi(length(temple_name)); %randomly generate a new gene
                
#                 %Child one gene swap and chromosome repair
#                 gene_loc = find(children(:,1)==temp);  %Find the location of the gene to be swapped
#                 if gene_loc ~= j    %if the gene to be swapped is not at the current location, it must be repaired.
#                     children(gene_loc,1) = children(j,1); %Place the current gene
#                     %(the one that would be deleted by the swap) into the
#                     %location of where the gene that would be repeated.
#                     children(j,1) = temp; %place child 2's gene in child 1.
#                 end

#                 %Change between child 1 and 2 to check uniqueness.
#                 if length(unique(children(:,1))) ~= length(temple_name)
#                     error("not unique")
#                 end
#             end
#             %Child 2 Mutation
#             if rand<mutat_percent
#                 %Store the gene
#                 temp = randi(length(temple_name)); 
                
#                 %Child one gene swap and chromosome repair
#                 gene_loc = find(children(:,2)==temp);  %Find the location of the gene to be swapped
#                 if gene_loc ~= j    %if the gene to be swapped is not at the current location, it must be repaired.
#                     children(gene_loc,2) = children(j,2); %Place the current gene
#                     %(the one that would be deleted by the swap) into the
#                     %location of where the gene that would be repeated.
#                     children(j,2) = temp; %place child 2's gene in child 1.
#                 end

#                 %Change between child 1 and 2 to check uniqueness.
#                 if length(unique(children(:,2))) ~= length(temple_name)
#                     error("not unique")
#                 end
#             end
#         end
#         %Store Children into new generation
#         new_gen(:,i) = children(:,1);
#         new_gen(:,i+1) = children(:,2);
#     end
#     %Elitism (Pick top N)
#     current_gen = [old_gen, new_gen];   %Concantonate together for fitness function
#     toc
#     current_fit = fitness(current_gen);  
#     [~,winners] = mink(current_fit,gen_size); %Determine winning generation's index
#     old_gen = current_gen(:,winners);   %Place winning generation as surviving gen. 
# end
# final_gen = old_gen;
# final_fit = fitnesspy.fitness(old_gen);
# [f_opt,I] = min(final_fit);
# x_opt = final_gen(:,I)