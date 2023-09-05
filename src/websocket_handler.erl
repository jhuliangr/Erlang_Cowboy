-module(websocket_handler).

-export([init/2]).
-export([websocket_handle/2, websocket_info/2, handle/2, terminate/3]).

-record(state, {auth = false}).

init(Req, Opts) ->
    io:format("Websocket started ~n", []),
    {cowboy_websocket, Req, Opts, #{idle_timeout => 30000}}.

websocket_handle(Message, []) ->
    websocket_handle(Message, #state{});

websocket_handle(Message, State=#state{}) ->
    io:format("Message: ~p, actual state: ~p~n", [Message, State]),
        {text, Mensaje0} = Message,
        case State#state.auth of
            true ->
                case Mensaje0 of
                    <<"close">> ->
                        NewState = State#state{auth=false},
                        {[{text, "Session closed succesfully"}], NewState};
                    _-> 
                        io:format("Incomming message: ~p ~n", [Message]), % Close session 
                        websocket_Authenticated_handle({text, Mensaje0}, State)
                end;
            false ->
                case Message of
                    {text, <<"a">>} ->
                        case check_credentials("a") of
                            true ->
                            % {auth, Username, Password} ->
                            %     case check_credentials(Username, Password) of
                            %         true ->
                            %             NewState = State#state{auth=true},
                            %             {[{text, "Completed"}], NewState};
                            %         false ->
                            %             {[{text, "Wrong Credentials"}], State}
                            %     end;
                                NewState = State#state{auth=true},
                                {[{text, "Authentication Sucessfully"}], NewState};
                            false ->
                                {[{text, "Wrong Credentials"}], State}
                            end;
                    {text, <<"out">>} ->
                        Res = [
                            {text, <<"Connection Closed">>},
                            {close, 1000, <<"Connection closed by peer">>}
                        ],
                        {Res, State};
                    _->
                        {[{text, "Authentication required to continue"}], State}
                end
        end;

websocket_handle(Param1, State) ->
    io:format("P1: ~p, P2: ~p~n", [Param1, State]),
    {[{text, "It is not matching the function"}], State}.

% enviar mensaje json
websocket_Authenticated_handle({text, <<"json">>}, State) ->
    io:format("JSON received~n", []),
    Json = [{<<"name">>, <<"Alberto">>}, {<<"age">>, 21}],
    {
        [
            {text, jsx:encode(Json)}
        ],
        State
    };
% enviar mensaje json usando maps
websocket_Authenticated_handle({text, <<"jsonM">>}, State) ->
    io:format("Receiving JSON Maps~n", []),
    Json = maps:new(),
    NewJson = maps:put(name, alberto, Json),
    % [{<<"name">>,<<"Alberto">>}, {<<"edad">>, 21}],
    {
        [
            {text, jsx:encode(NewJson)}
        ],
        State
    };
websocket_Authenticated_handle({text, <<"close">>}, State) ->
    io:format("Closing websocket~n", []),
    {
        [
            {text, <<"Connection Closed">>},
            % It is possible to send binary data too
            {binary, <<0:8000>>},
            {close, 1000, <<"Connection closed by peer">>}
        ],
        State
    };
websocket_Authenticated_handle(Frame = {text, Txt}, State) ->
    io:format("Handle called, frame is: ~p and state is: ~p~n", [Frame, State]),
    {[{text, <<"Youe message has benn received succesfully, it is: ", Txt/binary>>}], State};
websocket_Authenticated_handle(_Frame, State) ->
    {ok, State}.

websocket_info({log, Text}, State) ->
    io:format("Info Called"),
    {[{text, Text}], State};
websocket_info(_Info, State) ->
    {ok, State}.

handle(Req, State = #state{}) ->
    {ok, Req, State}.

terminate(_Reason, _Req, State) ->
    {stop, State}.

% function de chequeo
check_credentials(Str) ->
    % case (Username == "123") and (Password == "123") of
    %     true -> true;
    %     false -> false
    % end.
    case Str == "a" of
        true -> true;
        false -> false
    end.
