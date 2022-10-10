-module(gossip).
-export([start/1, spreadRumor/2, listenToRumor/4]).


spreadRumor(ConnectedNodes, Rumor) ->
    receive
        {PID, true} -> 
            Len = length(ConnectedNodes),
            Nth = rand:uniform(Len),
            ChosenNeighbour = lists:nth(Nth, ConnectedNodes),
            IsProcessAlive = is_process_alive(ChosenNeighbour),

            if IsProcessAlive == true ->
                ChosenNeighbour ! Rumor
            ;true ->
                self() ! {PID, true},
                spreadRumor(ConnectedNodes, Rumor)
            end,

            spreadRumor(ConnectedNodes, Rumor);
        {PID, false} -> 
            io:fwrite("~n~w stopped spreading", [PID])
    end.

listenToRumor(_, _, SpreadPID, RumorCount) when RumorCount > 10->
    % Stop listening and spreading!!!
    SpreadPID ! {self(), false},
    io:fwrite("~n~w got 10 Rumors!!!", [self()]);


listenToRumor(Rumor, ConnectedNodes, SpreadPID,RumorCount) when RumorCount =< 10->
    receive
        Rumor ->
            io:fwrite("~n~w Got ~w Rumor", [self(), RumorCount]),
            SpreadPID ! {self(), true},
            listenToRumor(Rumor, ConnectedNodes, SpreadPID, RumorCount + 1)
    end.

start(_) ->
    receive
        Rumor ->
            io:fwrite("~n~w Got First Rumor", [self()]),
            getNeighbours ! self(),
            receive
                ConnectedNodes -> 
                    SpreadPID = spawn(gossip, spreadRumor, [ConnectedNodes, Rumor]),
                    SpreadPID ! {self(), true},
                    listenToRumor(Rumor, ConnectedNodes, SpreadPID,  2)
            end
    end.