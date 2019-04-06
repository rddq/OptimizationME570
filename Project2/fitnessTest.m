clear
sessionFileName = 'TempleSchedules/templeEndowmentSchedules.json';
global sessions
sessions = jsondecode(fileread(sessionFileName));

timezonesFileName = 'timezones.json';
global timezones
timezones = jsondecode(fileread(timezonesFileName));
timezones = string(timezones);

x = importdata('DistanceAndTimeBetweenTemples/timeBetweenLocations.txt');
global travel_time
travel_time = x(2:end,2:end);

daysotw = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday','Friday','Saturday'];

generation = (1:1:72);
generation = generation.';
fitness(generation)

function [time] = fitnessOfPath(path)
    global sessions
    global travel_time
    time = 0;
    startDate = datetime(2019,4,16,5,0,0,'TimeZone','local',...
    'Format','d-MMM-y HH:mm:ss Z');
    date = startDate;
    dayForm = 'long';
    for j=2:(length(path))
        % Travel to temple
        travelToTemple = travel_time(path(j-1),path(j));
        date = date + seconds(travelToTemple);
        
        % Attend a Session
        [daynumber,currDay] = weekday(date,dayForm);
        schedule = sessions(j).(currDay);
        schedule = string(schedule);       
        if ~isempty(schedule)
            foundSession = 0;
            [~,numberSessionsToday] = size(schedule);
            for index = 1:numberSessionsToday
                session = schedule(index);
                tsess = getSessionDateTime(session, j, date);
                difference = tsess-date;
                if minutes(difference) > 20
                    date = date + difference + hours(2);
                    foundSession = 1;
                    break
                end
            end
            if foundSession
                continue
            end
        end        
        % If no available session, try the next day.
        sessionSearch = 1;
        while sessionSearch
            daynumber = daynumber+1;
            newDay = daysotw(daynumber)
            schedule = sessions(j).(newDay);
            schedule = string(schedule);
            
            if isempty(schedule)
                continue
            end            
        end                 
        time = 1;
    end
end

function sesTime = getSessionDateTime(session, templeIndex, date)
    global timezones
    info = split(session);
    time = split(info(1),':');
    Hour = str2num(time(1));
    Minute = str2num(time(2));
    if info(2) == 'PM'
        Hour = Hour+12;
    end
    Year = year(date);
    Month = month(date);
    Day = day(date);

    sesTime = datetime(Year,Month,Day,Hour,Minute,0,'TimeZone',timezones(templeIndex),...
            'Format','d-MMM-y HH:mm:ss Z');
end

function [total_time] = fitness(generation)
[~,m] = size(generation);
total_time = zeros(1,m);
for i=1:m
    gen_time = 0;
    path = generation(:,i);
    total_time(i) = fitnessOfPath(path)
end
end