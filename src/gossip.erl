-module(gossip).
-export([start/1, spreadRumor/2, getConnectedActors/1]).


spreadRumor(ConnectedNodes, Rumor) ->
    Len = length(ConnectedNodes),
    Nth = rand:uniform(Len),
    ChosenNeighbour = lists:nth(Nth, ConnectedNodes),
    IsProcessAlive = is_process_alive(ChosenNeighbour),
    
    if IsProcessAlive == true ->
        ChosenNeighbour ! Rumor
    ;true ->
        true
    end,

    spreadRumor(ConnectedNodes, Rumor).

listenToRumor(_, RumorCount) when RumorCount > 10->
    % Stop listening and spreading!!!
    io:fwrite("~n~w got 10 Rumors!!!", [self()]);


listenToRumor(Rumor,  RumorCount) when RumorCount =< 10->
    receive
        Rumor ->
            io:fwrite("~n~w Got ~w Rumor", [self(), RumorCount]),        
            listenToRumor(Rumor, RumorCount + 1)
    end.

getConnectedActors(Rumor) ->
    receive
        CallerPID ->
            getNeighbours ! {self(), CallerPID},
        receive
            ConnectedNodes -> 
                spawn(gossip, spreadRumor, [ConnectedNodes, Rumor])
        end
    end.

start(_) ->
    receive
        Rumor ->
            io:fwrite("~n~w Got First Rumor", [self()]),
            GetNeighborPID= spawn(gossip, getConnectedActors, [Rumor]),
            GetNeighborPID ! self(),
            listenToRumor(Rumor, 2)
    end.