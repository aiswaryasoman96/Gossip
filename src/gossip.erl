-module(gossip).
-export([start/1, spreadRumor/2, getConnectedActors/1, listenToRumor/3]).


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

listenToRumor(_, SpreadPID, RumorCount) when RumorCount > 10->
    % Stop listening and spreading!!!
    {WallClock1,WallClock2} = statistics(wall_clock),
    exit(SpreadPID, normal),
    io:fwrite("~n~w got 10 Rumors!!!Time Converged ~w and ~w", [self(),WallClock1,WallClock2]);


listenToRumor(Rumor, SpreadPID, RumorCount) when RumorCount =< 10->
    receive
        Rumor ->
            % io:fwrite("~n~w Got ~w Rumor", [self(), RumorCount]),        
            listenToRumor(Rumor, SpreadPID, RumorCount + 1)
    end.

getConnectedActors(Rumor) ->
    receive
        CallerPID ->
            getNeighbours ! {self(), CallerPID},
        receive
            ConnectedNodes -> 
                SpreadPID = spawn(gossip, spreadRumor, [ConnectedNodes, Rumor]),
                CallerPID ! {SpreadPID, CallerPID}
        end
    end.

start(_) ->
    receive
        Rumor ->
            % io:fwrite("~n~w Got First Rumor", [self()]),
            GetNeighborPID= spawn(gossip, getConnectedActors, [Rumor]),
            GetNeighborPID ! self(),
            receive
                {SpreadPID, _} ->
                    listenToRumor(Rumor, SpreadPID, 2)
            end
    end.