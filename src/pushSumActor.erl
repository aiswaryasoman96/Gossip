-module(pushSumActor).
-export([start/1]).
-import_module(server).

startPush(_,_,_,PrevRatio,ConvergedRounds) when ConvergedRounds == 3->

    io:fwrite("~n Converged at ~w in ~w Actor", [PrevRatio,self()]);

startPush(MySum,MyWeight,ConnectedNodes, PrevRatio,ConvergedRounds) when ConvergedRounds < 3 ->
    NumOfNodes = length(ConnectedNodes),
    receive
        {Sum,Weight} ->
                io:fwrite("~n~w got values : ~w and ~w ", [self(),Sum,Weight]),
                NewSum = Sum + MySum,
                NewWeight = MyWeight + Weight,
                RandomNumber = rand:uniform(NumOfNodes),
                PingPid = lists:nth(RandomNumber, ConnectedNodes),
                PingPid ! {NewSum/2,NewWeight/2},
                CurrentRatio = NewSum/NewWeight,
                Diff = math:pow(10, -10),
                if abs(PrevRatio - CurrentRatio) < Diff ->
                    NewConvergedRounds = ConvergedRounds+1
                ;true ->
                    NewConvergedRounds = 0
                end,
                io:fwrite("~n~w Sent values : ~w and ~w to ~w and now Ratio is ~w and Round is ~w", [self(),NewSum/2,NewWeight/2,PingPid,CurrentRatio,NewConvergedRounds]),
                startPush(NewSum/2,NewWeight/2,ConnectedNodes,CurrentRatio,NewConvergedRounds)
    end.
    

start(MySum) -> 
    MyWeight = 1,
    receive
        {Sum,Weight} ->
            getNeighbours ! self(),
            receive
                ConnectedNodes -> 
                io:fwrite("~n~w got values : ~w and ~w ", [self(),Sum,Weight]),
                NewSum = Sum + MySum,
                NewWeight = MyWeight + Weight,
                NumOfNodes = length(ConnectedNodes),
                RandomNumber = rand:uniform(NumOfNodes),
                PingPid = lists:nth(RandomNumber, ConnectedNodes),
                PingPid ! {NewSum/2,NewWeight/2},
                io:fwrite("~n~w Sent values : ~w and ~w to ~w", [self(),NewSum/2,NewWeight/2,PingPid]),
                CurrentRatio = NewSum/NewWeight,
                % Diff = math:pow(10, -10),
                % if (PrevRatio - CurrentRatio) < Diff ->
                %     NewConvergedRounds = ConvergedRounds+1
                % ;true ->
                %     NewConvergedRounds = 0
                % end,
                startPush(NewSum/2,NewWeight/2,ConnectedNodes,CurrentRatio,0)
            end
    end.
    