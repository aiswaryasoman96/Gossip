-module(gossip).
-export([listenToRumor/2]).
-import_module(server).

    
spreadRumor(ConnectedNodes, Rumor) ->
    Len = length(ConnectedNodes),
    % io:fwrite("~nLen = ~w",[Len]),
    Nth = rand:uniform(Len),
    % io:fwrite("~nNTH = ~w",[Nth]),
    ChosenNeighbour = lists:nth(Nth, ConnectedNodes),
    io:fwrite("~nTime to spread the Rumor to ~w!!!", [ChosenNeighbour]),
    ChosenNeighbour ! Rumor.

listenToRumor(Master, RumourCount) when RumourCount == 10->
    % Stop listening and spreading!!!
    io:fwrite("~nHad enough of the Rumors!!! Quitting ~w", [self()]),
    timer:sleep(500000),
    % Trying a infinite loop of doing nothing!!
    listenToRumor(Master, RumourCount);

% Master required?
listenToRumor(Master, RumourCount) when RumourCount < 10->
    receive
        Rumor ->
            io:fwrite("~nRumors received by ~w!!!",[self()]),
            getNeighbours ! self(),

            receive
                ConnectedNodes -> 
                    % io:fwrite("~nFound neighbour"),
                    spreadRumor(ConnectedNodes, Rumor)
            end,

        listenToRumor(Master, RumourCount + 1)
    end.
