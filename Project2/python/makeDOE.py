from pyDOE import lhs
import numpy as np
import pandas as pd

def makeDOE(csv_name, number_of_samples=1000):
    DOE = lhs(4, samples=number_of_samples)
    def setlimits(column,lb,ub):
        column = column*(ub-lb)+lb
        return column

    DOE[:,0] = setlimits(DOE[:,0],0.01,0.01) # cross percent
    DOE[:,1] = setlimits(DOE[:,1],0.07,0.07) # ordered cross percent
    DOE[:,2] = setlimits(DOE[:,2],0.2,0.2) # mutation percent
    DOE = np.insert(DOE, 3, 1500, axis=1) # num gen
    DOE = np.insert(DOE, 4, 100, axis=1) # gen size
    # DOE[:,3] = setlimits(DOE[:,3],1000,1000) # num gen
    # DOE[:,3] = np.round(DOE[:,3])
    # DOE[:,4] = setlimits(DOE[:,4],100,100) # gen size
    # DOE[:,4] = np.round(DOE[:,4])
    DOE[:,5] = setlimits(DOE[:,5],0.75,0.75) # tourney keep
    theDoe = pd.DataFrame(data=DOE,columns=["CrossPercent","OrderedCrossPercent","MutationPercent","NumGen","GenSize","TourneyKeep"])
    theDoe.to_csv(csv_name+".csv")

if __name__ == "__main__":
    makeDOE("TSparameterSweep",30)