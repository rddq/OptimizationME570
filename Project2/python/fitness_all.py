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

     
