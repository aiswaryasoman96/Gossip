-module(gossip).
-export([start/1]).

    
spreadRumor(ConnectedNodes, Rumor) ->
    Len = length(ConnectedNodes),
    Nth = rand:uniform(Len),
    ChosenNeighbour = lists:nth(Nth, ConnectedNodes),
    io:fwrite("~nTime to spread the Rumor to ~w!!!", [ChosenNeighbour]),
    ChosenNeighbour ! Rumor.

start(RumourCount) when RumourCount == 20->
    % Stop listening and spreading!!!
    io:fwrite("~nHad enough of the Rumors!!! Quitting ~w", [self()]),
    timer:sleep(500000),
    % Trying a infinite loop of doing nothing!!
    start(RumourCount);

% Master required?
start(RumourCount) when RumourCount < 20->
    receive
        Rumor ->
            io:fwrite("~nRumor ~w received by ~w!!!",[RumourCount,self()]),
            getNeighbours ! self(),

            receive
                ConnectedNodes -> 
                    spreadRumor(ConnectedNodes, Rumor)
            end,

        start(RumourCount + 1)
    end.
