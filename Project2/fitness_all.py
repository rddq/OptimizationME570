from datetime import datetime
from datetime import timedelta
import pytz
import time
import numpy as np
import json
import pandas as pd 

def fitness(generation):
    sessionFileName = 'TempleSchedules/templeEndowmentSchedules.json'
    with open(sessionFileName, 'r') as file1:
        sessions = json.load(file1)

    timezonesFileName = 'timezones.json'
    with open(timezonesFileName, 'r') as file2:
        timezones = json.load(file2)
    timezones = [pytz.timezone(t) for t in timezones]

    timefilename = 'DistanceAndTimeBetweenTemples/timeBetweenLocations.txt'
    travel_time = pd.read_csv(timefilename, delimiter='\t')
    travel_time = travel_time.values
    travel_time = np.delete(travel_time,0,1)
    daysotw = ["Monday", "Tuesday", "Wednesday", "Thursday","Friday","Saturday","Sunday"]
    
    m = len(generation)
    total_time = []
    for i in range(m):
        gen_time = 0
        path = generation[i]
        total_time.append(fitnessOfPath(path,sessions,travel_time,daysotw,timezones))  
    return total_time

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

def fitnessOfPath(path, sessions, travel_time, daysotw, timezones):
    now = pytz.utc.localize(datetime.utcnow())
    MDT = pytz.timezone("America/Denver")
    startDate = MDT.localize(datetime(2019,4,16,7,40,0,0))
    date = startDate
    for j in range(1,len(path)):
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
                     minutesDiffdaysmin = difference.days*24*60
                     minutesDiffsecondmin = difference.seconds/60
                     diff = minutesDiffdaysmin+minutesDiffsecondmin
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
            # TODO include date in this calculation
            difference = tsess-date
            minutesDiffdaysmin = difference.days*24*60
            minutesDiffsecondmin = difference.seconds/60
            diff = minutesDiffdaysmin+minutesDiffsecondmin
            if diff < 0:
                raise Exception("Session should not be before you get there")
            date = date + difference + timedelta(hours=2)
            break
    finaldelta = date-startDate
    finaltime = finaldelta.days*24*60*60+finaldelta.seconds
    return finaltime

# start_time = time.time()

# generation = np.array(list(range(0,72)))
# generation = generation.T
# total_days = fitness(generation)
# print(total_days)
# end_time = time.time()
# print (end_time-start_time)

     
