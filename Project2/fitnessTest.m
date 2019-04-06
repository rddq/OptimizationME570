sessionFileName = 'TempleSchedules/templeEndowmentSchedules.json';
sessions = jsondecode(fileread(sessionFileName));
global sessions

x = importdata('DistanceAndTimeBetweenTemples/timeBetweenLocations.txt');
global travel_time
travel_time = x(2:end,2:end);

generation = (1:1:72);
generation = generation.';
fitness(generation)

function [time] = fitnessOfPath(path)
    global sessions
    global travel_time
    time = 0;
    startDate = datetime(2019,4,16,5,0,0,'TimeZone','local',...
    'Format','d-MMM-y HH:mm:ss Z')
    date = startDate;
    dayForm = 'long';
    for j=1:(length(path))
        [daynumber,currDay] = weekday(date,dayForm);
        schedule = sessions(j).(currDay);
        schedule = string(schedule);
        % Check if there is a session, if not try the next day.
        if isempty(schedule)
            sessionSearch = 1;
            while sessionSearch
                daynumber = daynumber+1;
                [~,currDay] = weekday(daynumber,dayForm)
                schedule = sessions(j).(currDay);
                schedule = string(schedule);
                if isempty(schedule)
                    continue
                end
                
            end
            
        end
        time = 1;
    end
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