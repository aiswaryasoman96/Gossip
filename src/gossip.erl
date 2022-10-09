-module(gossip).
-export([start/1]).

    
spreadRumor(ConnectedNodes, Rumor) ->
    Len = length(ConnectedNodes),
    Nth = rand:uniform(Len),
    ChosenNeighbour = lists:nth(Nth, ConnectedNodes),
    io:fwrite("~nTime to spread the Rumor to ~w!!!", [ChosenNeighbour]),
    ChosenNeighbour ! Rumor.

listenToRumor(_, _, RumorCount) when RumorCount == 20->
    % Stop listening and spreading!!!
    io:fwrite("~nHad enough of the Rumors!!! Quitting ~w", [self()]),
    exit(self(), kill);


listenToRumor(Rumor, ConnectedNodes, RumorCount) when RumorCount < 20->
    spreadRumor(ConnectedNodes, Rumor),
    receive
        Rumor ->
            io:fwrite("~nRumor ~w received by ~w!!!",[RumorCount, self()]),
            listenToRumor(Rumor, ConnectedNodes, RumorCount + 1)
    end.

start(_) ->
    receive
        Rumor ->
            io:fwrite("~nRumor ~w received by ~w!!!",[0, self()]),
            getNeighbours ! self(),
            receive
                ConnectedNodes -> 
                    listenToRumor(Rumor, ConnectedNodes, 0)
            end
    end.