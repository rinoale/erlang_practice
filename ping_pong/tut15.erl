-module(tut15).
-export([start/0, ping/2, pong/0, showMessageQueue/1]).

ping(0, Pong_PID) ->
  Pong_PID ! finished,
  io:format("ping finished~n", []);

ping(N, Pong_PID) ->
  Pong_PID ! {ping, self()},
  io:format("PING::CREATED~n", []),
  receive
    pong ->
      io:format("Ping received pong~n", [])
  end,
  ping(N-1, Pong_PID).

pong() ->
  io:format("PONG::CREATED~n", []),
  receive
    finished->
      io:format("Pong finished~n", []),
      pong();
    {ping, Ping_PID} ->
      io:format("Pong received ping~n", []),
      Ping_PID ! pong,
      wait(2),
      pong()
  after 2000 ->
      pong()
  end.

wait(Sec) ->
  receive
  after (1000*Sec) -> ok
  end.

showMessageQueue(PID) ->
  wait(1),
  erlang:display(erlang:process_info(PID, messages)),
  showMessageQueue(PID).

start() ->
  Pong_PID = spawn(tut15, pong, []),
  Ping_PID = spawn (tut15, ping, [3, Pong_PID]),
  spawn (tut15, showMessageQueue, [Pong_PID]),
  spawn (tut15, showMessageQueue, [Ping_PID]).
