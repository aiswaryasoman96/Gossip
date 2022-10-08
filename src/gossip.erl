-module(gossip).
-export([listenToRumor/2]).

    
spreadRumor(ConnectedNodes, Rumor) ->
    Len = length(ConnectedNodes),
    Nth = rand:uniform(Len),
    ChosenNeighbour = lists:nth(Nth, ConnectedNodes),
    io:fwrite("~nTime to spread the Rumor to ~w!!!", [ChosenNeighbour]),
    ChosenNeighbour ! Rumor.

listenToRumor(Master, RumourCount) when RumourCount == 20->
    % Stop listening and spreading!!!
    io:fwrite("~nHad enough of the Rumors!!! Quitting ~w", [self()]),
    timer:sleep(500000),
    % Trying a infinite loop of doing nothing!!
    listenToRumor(Master, RumourCount);

% Master required?
listenToRumor(Master, RumourCount) when RumourCount < 20->
    receive
        Rumor ->
            io:fwrite("~nRumor ~w received by ~w!!!",[RumourCount,self()]),
            getNeighbours ! self(),

            receive
                ConnectedNodes -> 
                    spreadRumor(ConnectedNodes, Rumor)
            end,

        listenToRumor(Master, RumourCount + 1)
    end.
