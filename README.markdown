# AQAppStateMachine
#### Copyright (c) 2011 Jim Dovey. All Rights Reserved, Until I Update The Headers With My Usual BSD License.

## Simply put:

AQAppStateMachine is designed to assist the development of applications with some fairly intricate state requirements. The idea is that the state itself is stored as an *n*-bit bitfield, and that the application can define certain ranges of this bitfield to refer to state flags. These flags can be combinatory or mutually exclusive, or hell, they could just be integers. The state machine itself is designed for an app which needs to, say, do *Task A*, but only if *B* has been initialized, *C* has failed to initialize, and *D* is not currently happening, along with *E*, *F*, and *G* each being in one or more of a number of states. It makes no guarantees that your states will be mutually exclusive-- it won't hold your hand, and can 'deadlock' at will if you don't pay attention.

## Now, the magic:

The state is implemented as a bitfield which supports various means of querying the state of certain ranges of bits. Moreover, this bitfield can optionally run a block whenever a bit in a particular range is modified (or set/unset, regardless of prior state). The AQAppStateMachine uses this to find out when ranges of bits have changed, and through this it can  offer to API clients the ability to run a given block whenever one or more specific bits have changed. Even bits in a range *with a supplied mask*. For instance, you could have an eight-bit bitfield, where each bit represents a combinatory state. You want to trigger an action whenever bits 0, 3, or 4 are modified. The AQAppStateMachine lets you simply attach a block with some range/mask qualifiers, and *boom* when one of those bits gets touched, the block runs. You can also do so only when the masked bits match a particular set of values (i.e. bit 0 on, bits 3 and 4 off) while still ignoring all other bits.

## Why?

The Kobo app has a lot of fiddly state code which has grown organically. It pissed me off, so I wrote this. This looks like it'll be useful outside Kobo, so it's being open-sourced. **QED**