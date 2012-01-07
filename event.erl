-module(event).

-export([registerEvent/1]).

registerEvent({Pid, Event_key, Descr, Time}) ->
	receive
		{cancel, Pid} -> Pid ! {cancel, Event_key, Descr}, exit(normal)
	after Time ->
		Pid ! {event, Pid, Event_key, Descr}
	end.

