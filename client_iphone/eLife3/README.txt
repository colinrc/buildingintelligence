Dev README

Messages

Because we are working single threaded on the runloop we are 
firing state change messages on the default notification 
center. We should look to see if it makes sense to alter our
class structure to match the finite state automata pattern
using these messages as the state transisitons.

Settings editing messages, these messages inform we are 
starting editing the settings and that we have finished
editing the settings.

[[NSNotificationCenter defaultCenter] postNotificationName:@"elife_settings_start" object:self];
[[NSNotificationCenter defaultCenter] postNotificationName:@"elife_settings_end" object:self];

The connections also notify their state using down for 
network failure and data whenever data comes available.

[[NSNotificationCenter defaultCenter] postNotificationName:@"network_down" object:self];
[[NSNotificationCenter defaultCenter] postNotificationName:@"network_data" object:self];

Whenever one of the controls is updated from the server 
we notify that there is new data available for that key
using the keyname as the notificatoion name as follows

[[NSNotificationCenter defaultCenter] postNotificationName:tmpCtl.key_ object:self];
[[NSNotificationCenter defaultCenter] postNotificationName:[tmpCtl.key_ stringByAppendingString:@"_status"] object:self];

(NOTE:) not sure that we need the two notifications still, 
they are a relic from the copy paste from elife-b

Finally in the macro code we have notifications for 
the view whenever macros are added and notifications
that the macros have started or stopped.

[[NSNotificationCenter defaultCenter] postNotificationName:@"addMacro" object:self];
[[NSNotificationCenter defaultCenter] postNotificationName:[item objectForKey:@"EXTRA"] object:self];
