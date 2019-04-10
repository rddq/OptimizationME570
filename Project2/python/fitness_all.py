from datetime import datetime
from datetime import timedelta
import pytz
import time
import numpy as np
import json
import pandas as pd 

def getSessionDateTime(session, templeIndex, date, extradays, timezones):
    info = session.split()
    time = info[0].split(":")
    Hour = int(time[0])
    Minute = int(time[1])
    if info[1] == 'PM' and Hour != 12:
        Hour += 12
    Year = date.year
    Month = date.month
    Day = date.day
    if extradays != 0:
        Day = Day + extradays
    if Day > 30:
        if Month == 4 or Month == 6 or Month == 9 or Month == 11:
            Day = Day - 30
            Month += 1
        if Day > 31 and (Month == 5 or Month == 7 or Month == 8 or Month == 10):
            Day = Day - 31
            Month += 1
    sesTime = timezones[templeIndex].localize(datetime(Year,Month,Day,Hour,Minute,0,0))
    return sesTime

def fitnessOfPathTS(path, sessions, travel_time, daysotw, timezones):
    fitness = 0
    for j in range(0,len(path)):
        fitness += travel_time[path[j-1]][path[j]]
    return fitness

def fitnessOfPath(path, sessions, travel_time, daysotw, timezones):
    timezone_start = timezones[0]
    startDate = timezone_start.localize(datetime(2019,4,16,7,40,0,0))
    date = startDate
    for j in range(0,len(path)):
        #Travel to temple
        travelToTemple = travel_time[path[j-1]][path[j]]
        date = date + timedelta(seconds=travelToTemple)
        # Attend a Session
        daynumber = date.weekday()
        currDay = daysotw[daynumber]
        if daynumber != 6:
            schedule = sessions[j][currDay]
            numberSessionsToday = len(schedule)
            if numberSessionsToday != 0:
                foundSession = 0
                for index in range(0,numberSessionsToday):
                     session = schedule[index]
                     tsess = getSessionDateTime(session, j, date, 0, timezones)
                     difference = tsess-date
                     diff = difference.total_seconds()/60
                     if diff > 20:
                        date = date + difference + timedelta(hours=2)
                        foundSession = 1
                        break
                if foundSession:
                    continue         
        # If no available session, try the first session of the next day.
        sessionSearch = 1
        extraday = 0
        while sessionSearch:
            extraday = extraday+1
            if daynumber < 5:
                daynumber = daynumber+1
            elif daynumber == 5:
                daynumber = 0
                extraday = extraday + 1
            else:
                daynumber = 0
            newDay = daysotw[daynumber]
            schedule = sessions[j][newDay]
            if len(schedule) == 0:
                continue
            # Go to first session of the next day
            tsess = getSessionDateTime(schedule[0], j, date, extraday, timezones)
            difference = tsess-date
            minutesDiffdaysmin = difference.days*24*60
            minutesDiffsecondmin = difference.seconds/60
            diff = minutesDiffdaysmin+minutesDiffsecondmin
            if diff < 0:
                raise Exception("Session should not be before you get there")
            date = date + difference + timedelta(hours=2)
            break
    finaldelta = date-startDate
    finaltime = finaldelta.total_seconds()
    return finaltime

if __name__ == "__main__":

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
    start_time = time.time()
    generation = np.array([52,48,36,39,62,50,23,69,68,1,34,59,25,16,5,46,21,14,3,41,49,35,24,8,47,15,33,27,18,12,65,42,29,0,66,6,20,17,71,53,40,19,45,28,58,9,44,10,31,67,4,56,26,70,7,38,63,13,61,2,51,37,55,57,22,32,43,60,54,30,64,11])
    generation = np.reshape(generation, (72,1))
    generation = np.subtract(generation,1)
    dictionary = {}
    total_seconds = fitness(generation, sessions, travel_time, daysotw, timezones,dictionary)
    print(total_seconds[0])
    end_time = time.time()
    print (end_time-start_time)

     
