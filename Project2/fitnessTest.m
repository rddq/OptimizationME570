clear
w = importdata('Temple.txt'); % Read in Datafile
temple_name = string(w.textdata(:,1)); % Pull Temple Names
temple_state = string(w.textdata(:,2)); % Pull Temple Names
temple_number = w.data(:,1); % Pull Number/Coords

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

global daysotw
daysotw = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday","Friday","Saturday"];

generation = (1:1:72);
generation = generation.';
fitness(generation)

function [time] = fitnessOfPath(path)
    global sessions
    global travel_time
    startDate = datetime(2019,4,16,7,40,0,'TimeZone','local',...
    'Format','d-MMM-y HH:mm:ss Z');
    date = startDate;
    dayForm = 'long';
    for j=2:(length(path))
        % Travel to temple
        travelToTemple = travel_time(path(j-1),path(j));
        date = date + seconds(travelToTemple);
        
        % Attend a Session
        [daynumber,currDay] = weekday(date,dayForm);
        if daynumber ~= 1
            schedule = sessions(j).(currDay);
            schedule = string(schedule);       
            if ~isempty(schedule)          
                foundSession = 0;
                [numberSessionsToday,~] = size(schedule);
                for index = 1:numberSessionsToday
                    session = schedule(index);
                    tsess = getSessionDateTime(session, j, date, 0);
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
        end
        % If no available session, try the first session of the next day.
        sessionSearch = 1;
        extraday = 0;
        while sessionSearch
            extraday = extraday+1;
            if daynumber < 7
                daynumber = daynumber+1;
            else
                daynumber = 2;
                extraday = extraday + 1;
            end
            global daysotw
            newDay = daysotw(daynumber);
            schedule = sessions(j).(newDay);
            schedule = string(schedule);           
            if isempty(schedule)
                continue
            end
            % Go to first session of the next day
            tsess = getSessionDateTime(schedule(1), j, date, extraday);
            difference = tsess-date;
            if difference < 0
                error("Session should not be before you get there")
            end
            date = date + difference + hours(2);
            break
        end                 
    end
    time = date-startDate;
end

function sesTime = getSessionDateTime(session, templeIndex, date, extradays)
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
    if extradays ~= 0
        Day = Day + extradays;
    end
    sesTime = datetime(Year,Month,Day,Hour,Minute,0,'TimeZone',timezones(templeIndex),...
            'Format','d-MMM-y HH:mm:ss Z');
end

function [total_time] = fitness(generation)
[~,m] = size(generation);
total_time = zeros(1,m);
for i=1:m
    gen_time = 0;
    path = generation(:,i);
    total_time(i) = days(fitnessOfPath(path));
end
end