-module(server_ffi).

-export([silence_tls_handshake_noise/0]).

silence_tls_handshake_noise() ->
    Filter = fun(LogEvent, _) ->
        Text = lists:flatten(logger_formatter:format(LogEvent, #{})),
        case is_noisy(Text) of
            true -> stop;
            false -> LogEvent
        end
    end,
    logger:add_primary_filter(lustre_dev_tools_tls_handshake_noise, {Filter, []}),
    nil.

is_noisy(Text) ->
    has_substring(Text, "Failed to handshake socket") orelse
    has_substring(Text, "CLIENT ALERT: Fatal - Certificate Unknown") orelse
    has_substring(Text, "CLIENT ALERT: Fatal - Bad Certificate").

has_substring(Text, Sub) ->
    string:find(Text, Sub) =/= nomatch.
