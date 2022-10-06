-module(pushSumActor).
-export([start/3]).
-import_module(server).

startPush(Master,MySum,MyWeight,ConnectedNodes,Round) when Round == 10->
    Ratio = MySum/MyWeight,
    {Master}!Ratio;

startPush(Master,MySum,MyWeight,ConnectedNodes,Round) when Round < 10->
    NumOfNodes = length(ConnectedNodes),
    receive
        {Sum,Weight} ->
                MySum = Sum/2 + MySum,
                MyWeight = MyWeight + Weight/2 
    end,
        RandomNumber = rand:uniform(NumOfNodes),
        PingPid = lists:nth(RandomNumber, ConnectedNodes),
        {PingPid} ! {MySum/2,MyWeight/2},
        MySum= MySum/2,
        MyWeight = MyWeight/2,
    startPush(Master,MySum,MyWeight,ConnectedNodes,Round +1).

start(Master,MySum,MyWeight)->
    receive
        ConnectedNodes ->
            startPush(Master,MySum,MyWeight,ConnectedNodes,0)
    end.
