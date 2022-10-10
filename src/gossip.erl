-module(gossip).
-export([start/1, spreadRumor/2, listenToRumor/3]).


spreadRumor(ConnectedNodes, Rumor) ->
    Len = length(ConnectedNodes),
    Nth = rand:uniform(Len),
    ChosenNeighbour = lists:nth(Nth, ConnectedNodes),
    ChosenNeighbour ! Rumor,
    spreadRumor(ConnectedNodes, Rumor).

listenToRumor(_, _, RumorCount) when RumorCount > 20->
    % Stop listening and spreading!!!
    io:fwrite("~nHad enough of the Rumors!!! Quitting ~w", [self()]);


listenToRumor(Rumor, ConnectedNodes, RumorCount) when RumorCount =< 20->
    receive
        Rumor ->
            listenToRumor(Rumor, ConnectedNodes, RumorCount + 1)
    end.

start(_) ->
    receive
        Rumor ->
            getNeighbours ! self(),
            receive
                ConnectedNodes -> 
                    spawn(gossip, spreadRumor, [ConnectedNodes, Rumor]),
                    listenToRumor(Rumor, ConnectedNodes, 2)
            end
    end.