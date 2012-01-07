-module(event).

%-export([start/0]).
-export_all().

start() ->
	process_flag(trap_exit, true),
	Pid = spawn_link(main({[],[]})),
	receive ->
		{'EXIT', Pid, normal} -> ok;
		{'EXIT', Pid, Reason} -> {'EXIT', Pid, Reason};
		{'EXIT',Pid,_} -> start();
		Undefined -> Undefined
	end.

main({Clients,Events}) when is_list(Clients), is_list(Events)->		
	receive
		{subscribe, Pid} -> 
			case storeClient(Pid) of
				{success, Pid, Ref} -> main({[{Pid,Ref}|Clients],Events});
				{error, Reason -> Pid ! Reason
			end;
		{add, Pid, Event_key, Descr, Time} -> 
			createEvent(), %%spawn some process
			main({[Clients,[createEvent() | Events]});
		{cancel, Pid, Event_key} -> 
			Pid ! stopEvent(Event_key, Events),
			main();
		{event, Pid, Event_key, Descr} -> 
			Pid ! {Event_key, Descr},
			main();
		{terminate, Pid} -> 
			exit(normal);
		{'EXIT', Pid, Reason} -> 
			{'EXIT', Pid, Reason}, 
			main();
		Unknown -> {error, Unknown}
	end.

clientMember(Pid,[{Client_pid,Ref} | Clients]) when Pid == Client_pid ->
	{Client_pid,Ref};
clientMember(Pid,[{Client_pid,Ref} | Clients]) ->
	clientMember(Pid,Clients);
clientMember(Pid,[]) ->
	false.

storeClient(Pid,Clients) when is_pid(Pid),is_list(Clients) ->
	case clientMember(Pid,Clients) of
		false -> 
			{Pid,Ref} = monitor(process,Pid),
			{success,Pid,Ref};
		_ ->
			{error, "client already subscribed"}
	end.
storeClient(Pid,Clients) ->
	{error, "unresolved format"}.
