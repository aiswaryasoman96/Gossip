-module(pushSumActor).
-export([start/1]).
-import_module(server).

startPush(_,_,_,PrevRatio,ConvergedRounds) when ConvergedRounds == 3->

    io:fwrite("~n Converged at ~w in ~w Actor", [PrevRatio,self()]);

startPush(MySum,MyWeight,ConnectedNodes, PrevRatio,ConvergedRounds) when ConvergedRounds < 3 ->
    NumOfNodes = length(ConnectedNodes),
    receive
        {Sum,Weight} ->
                NewSum = Sum/2 + MySum,
                NewWeight = MyWeight + Weight/2,
                RandomNumber = rand:uniform(NumOfNodes),
                PingPid = lists:nth(RandomNumber, ConnectedNodes),
                {PingPid} ! {MySum/2,MyWeight/2},
                CurrentRatio = NewSum/NewWeight,
                Diff = math:pow(10, -10),
                if (PrevRatio - CurrentRatio) < Diff ->
                    NewConvergedRounds = ConvergedRounds+1
                ;true ->
                    NewConvergedRounds = 0
                end,
                startPush(NewSum,NewWeight,ConnectedNodes,CurrentRatio,NewConvergedRounds)
    end.
    

start(MySum) -> 
    getNeighbours ! self(),
    receive
        ConnectedNodes -> 
            startPush(MySum,1,ConnectedNodes,MySum/1,0)
    end.
    