-module(learn_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

-define(NO_OPTIONS, []).
-define(ANY_HOST,'_').

start(_StartType, _StartArgs) ->

    Paths = [
        % Simple Http handler
        {"/main", learn_http_handler, ?NO_OPTIONS}, 
        % Websocket handler
        {"/websocket", websocket_handler, ?NO_OPTIONS},
        % Static HTML file with js to test the websocket
        {"/WsTestPage", cowboy_static, {priv_file, learn, "static/ws.html"}},
        % serve static file
        {"/", cowboy_static, {priv_file, learn, "static/main.html"}}, 
        % serve every file from priv/static directory
        {"/[...]", cowboy_static, {priv_dir, learn, "static"}} 
    ],

    Routes = [{?ANY_HOST, Paths},
              {"[...]", [{"/hpi/[...]", host_path_info_handler, ?NO_OPTIONS}]}],

    Dispatch = cowboy_router:compile(Routes),
        _ = cowboy:start_clear(http, 
            [{port, 3000}], 
        #{env => #{dispatch => Dispatch}}
    ),
    learn_sup:start_link().

stop(_State) ->
    ok.