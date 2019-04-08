clear all
close all
clc
pyversion /Users/ryandd/anaconda/envs/controlsclass/bin/python

%%%% TODO:
% - Change first temple location to Provo city center
% - Add some sort of penalty function
profile on
fitnesspy = py.importlib.import_module('fitness_all');
%Load in temple data
w = importdata('Temple.txt'); % Read in Datafile
x = importdata('DistanceAndTimeBetweenTemples/timeBetweenLocations.txt');
temple_name = string(w.textdata(:,1)); % Pull Temple Names
temple_state = string(w.textdata(:,2)); % Pull Temple Names
temple_number = w.data(:,1); % Pull Number/Coords
sessionFileName = 'TempleSchedules/templeEndowmentSchedules.json';
timezonesFileName = 'timezones.json';

global timezones
timezones = jsondecode(fileread(timezonesFileName));
timezones = string(timezones);
global sessions
sessions = jsondecode(fileread(sessionFileName));
global daysotw
daysotw = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday","Friday","Saturday"];

global lat  %I had to make it a global to make all the functions happy 
lat = w.data(:,2);
global long     %Same on global here
long = w.data(:,3);
global travel_time
travel_time = x(2:end,2:end);

%Optimization Variables
cross_percent = .1; %Crossover percentage 
%I've done some fiddling around with the crossover percentage, Changing
%this doesn't seem to have much effect on the outcome. 
mutat_percent = .05; %Mutation percentage
%Increasing this actually tends to decrease the efficacy of the
%optimization (makes the optimal distance larger). 
global num_gen
num_gen = 100;     %Number of generations (Basically the number of iterations)
global gen_size
gen_size = 20; %Must be even number
tourny_size = floor(gen_size/3);

old_gen = uint8(zeros(length(temple_name),gen_size));
new_gen = old_gen;
current_gen = [old_gen,old_gen];
parents=zeros(1,2);

%Generate 1st Generation (Random)
for i=1:gen_size
    old_gen(:,i) = randperm(length(temple_name))';
end
initial_gen = old_gen;
initial_fit = fitness(old_gen);

%Generation For Loop
for gen=1:num_gen
    tic
    %Child Generation For loop
    old_fit = fitnesspy.fitness(old_gen.');
    for i=1:2:(gen_size)    %Only odds so storage of children is easy
        %Select Parents (By fitness) (Tournament Style)
        for j=1:2
            %Randomly determine the index of who will fight
            tourny_participants = randi(gen_size,1,tourny_size); 
            [~,I] = min(old_fit(tourny_participants)); %find the index of the winner
            parents(j) = tourny_participants(I); %Store the index of the winner
        end
        %Birthing of children
        children(:,1) = old_gen(:,parents(1));
        children(:,2) = old_gen(:,parents(2));
        
        %Crossover (Uniform) (With chromosome repair)
        for j=1:length(temple_name) %Iterate through the genes of the children. 
            if rand<cross_percent
                %Store the genes 
                temp1 = children(j,1); %Temporarily store child one's gene
                temp2 = children(j,2);
                
                %Child one gene swap and chromosome repair
                gene_loc = find(children(:,1)==temp2);  %Find the location of the gene to be swapped
                if gene_loc ~= j    %if the gene to be swapped is not at the current location, it must be repaired. 
                    children(gene_loc,1) = children(j,1); %Place the current gene 
                    %(the one that would be deleted by the swap) into the
                    %location of where the gene that would be repeated.
                    children(j,1) = temp2; %place child 2's gene in child 1. 
                end
                %Child two gene swap and chromosome repair
                gene_loc = find(children(:,2)==temp1);
                if gene_loc ~= j
                    children(gene_loc,2) = children(j,2);
                    children(j,2) = temp1;
                end
                %Change between child 1 and 2 to check uniqueness. 
                if length(unique(children(:,2))) ~= length(temple_name)
                    error("not unique")
                end
            end
        end

        %Mutation (Uniform)
        for j=1:length(temple_name) %Iterate through the genes of the children.
            %Child 1 Mutation
            if rand<mutat_percent
                %Store the gene
                temp = randi(length(temple_name)); %randomly generate a new gene
                
                %Child one gene swap and chromosome repair
                gene_loc = find(children(:,1)==temp);  %Find the location of the gene to be swapped
                if gene_loc ~= j    %if the gene to be swapped is not at the current location, it must be repaired.
                    children(gene_loc,1) = children(j,1); %Place the current gene
                    %(the one that would be deleted by the swap) into the
                    %location of where the gene that would be repeated.
                    children(j,1) = temp; %place child 2's gene in child 1.
                end

                %Change between child 1 and 2 to check uniqueness.
                if length(unique(children(:,1))) ~= length(temple_name)
                    error("not unique")
                end
            end
            %Child 2 Mutation
            if rand<mutat_percent
                %Store the gene
                temp = randi(length(temple_name)); 
                
                %Child one gene swap and chromosome repair
                gene_loc = find(children(:,2)==temp);  %Find the location of the gene to be swapped
                if gene_loc ~= j    %if the gene to be swapped is not at the current location, it must be repaired.
                    children(gene_loc,2) = children(j,2); %Place the current gene
                    %(the one that would be deleted by the swap) into the
                    %location of where the gene that would be repeated.
                    children(j,2) = temp; %place child 2's gene in child 1.
                end

                %Change between child 1 and 2 to check uniqueness.
                if length(unique(children(:,2))) ~= length(temple_name)
                    error("not unique")
                end
            end
        end
        %Store Children into new generation
        new_gen(:,i) = children(:,1);
        new_gen(:,i+1) = children(:,2);
    end
    %Elitism (Pick top N)
    current_gen = [old_gen, new_gen];   %Concantonate together for fitness function
    toc
    current_fit = fitnesspy.fitness(current_gen);  
    [~,winners] = mink(current_fit,gen_size); %Determine winning generation's index
    old_gen = current_gen(:,winners);   %Place winning generation as surviving gen. 
end
final_gen = old_gen;
final_fit = fitnesspy.fitness(old_gen);
[f_opt,I] = min(final_fit);
x_opt = final_gen(:,I)
profile viewer

%%%%%% Functions
function rad = radians(degree) 
   rad = degree .* pi / 180;
end

function [distance] = haversine(lat1,lon1,lat2,lon2) 
    dlat = radians(lat2-lat1);
    dlon = radians(lon2-lon1);
    lat1 = radians(lat1);
    lat2 = radians(lat2);
    a = (sin(dlat./2)).^2 + cos(lat1) .* cos(lat2) .* (sin(dlon./2)).^2;
    c = 2 .* asin(sqrt(a));
    distance = 6372.8 * c;
end

% function [total_distance] = fitness(generation)
%     global lat
%     global long
%     
%     [~,m] = size(generation);
%     total_distance = zeros(1,m); 
%     
%     for j=1:m        %Iterate through each chromosome
%         gen_distance = 0;
%         path = generation(:,j);
%         
%         %iterate through the chromosome finding the total distance
%         for i=1:(length(path)-1)
%             gen_distance = gen_distance + haversine(lat(path(i)),long(path(i)),...
%                 lat(path(i+1)),long(path(i+1)));
%         end
%         %add distance from final location to initial location
%         total_distance(j) = gen_distance + haversine(lat(path(1)),long(path(1)),...
%             lat(path(end)),long(path(end)));
%     end
% 
% end
function [total_time] = fitness(generation)
global travel_time
[~,m] = size(generation);
total_time = zeros(1,m);
for i=1:m
    gen_time = 0;
    path = generation(:,i);    
    total_time(i) = days(fitnessOfPath(path));
end
end

function [time] = fitnessOfPath(path)
    global sessions
    global travel_time
    startDate = datetime(2019,4,16,7,40,0,'TimeZone','local',...
    'Format','d-MMM-y HH:mm:ss Z');
    date = startDate;
    dayForm = 'long';
    dummyTime = datetime(2019,4,16,7,40,0,'TimeZone','local',...
    'Format','d-MMM-y HH:mm:ss Z');
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
                    tsess = getSessionDateTime(session, j, date, 0, dummyTime);
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
            tsess = getSessionDateTime(schedule(1), j, date, extraday, dummyTime);
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

function sesTime = getSessionDateTime(session, templeIndex, date, extradays, dummyTime)
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
    dummyTime.TimeZone = timezones(templeIndex);
    dummyTime.Hour = Hour;
    dummyTime.Minute = Minute;
    dummyTime.Month = Month;
    dummyTime.Day = Day;
    %sesTime = datetime(Year,Month,Day,Hour,Minute,0,'TimeZone',timezones(templeIndex),...
     %       'Format','d-MMM-y HH:mm:ss Z');
    sesTime = dummyTime;
end

