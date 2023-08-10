# StatterCRG

A stand alone Swift package that talks with the
CRG Scoreboard (assuming version 2023.0 or newer)

Currently it only supports getting values from
the server - it does not support sending/changing
data.

It is designed to support SwiftUI.  The connection
is an ``ObservableObject`` which will send out
`willChange` notifications when new data arrives
from the server

## Basic usage

###Step 1:
Create a connection

```
let connection = Connection(host:"10.0.0.10")
```

###Step 2:
Connect to the server
```
connection.connect()
```

###Step 3:
Pass that value to your SwiftUI view

```
MyView()
    .environmentObject(connection)
```

###Step 4:
Have that view display the data (if available)

```
struct MyView: View {
    @EnvironmentObject var connection: Connection
    var body: some View {
        HStack {
            Text(connection.game?.teamOne.name ?? "???")
            Text("vs")
            Text(connection.game?.teamTwo.name ?? "???")
        }
    }
}
```



## The Packages

This SPM is composed of multiple parts, for different
uses

### StatterCRG
This is the core library, that includes connecting
to the server, and the data structures used to represent
the game data found on the CRG server (2023.3)

### StatterCRGUI
This is some simple SwiftUI that let you quickly put
together various views from the server

### StatterBook
This is designed to help with processing game data, allowing
you to read/write JSON files from the scoreboard's "export game"

### treemaker
treemaker is an internal command line executable that translates a
tree definition file into typesafe Swift extensions

### GenerateTree
GenerateTree is an SPM plugin build command tool that uses
the treemaker tool to build the tree definitions.  Note that it
must be manually run due to a bug in how Xcode handles multiple
targets using the same SPM where that SPM has a build tool (since
it detects that there are multiple ways of creating the output
file - one for each target's inclusion of the SPM, never mind that
it is the same invocation)

## In Depth
The CRG scoreboard server use a websocket to communicate
with clients.  Normally this is a webpage that it
serves, but a websocket connection can be use from
native apps as well.

Fundamentally, the server has a large "tree" of data
that represents all the parts of the game (and really,
multiple games, plus other data such as asset and
metadata like game rules).  A client "registers" to
various nodes in that tree, and when those values change,
the server sends an update to the client with the
new value.

### `Connection`
The ``Connection`` class manages all that - it wraps
the websocket connection, handles subscribing to the
the parts of the tree, and then uses a publisher to
let anything know that the data changes.

> Note that we use SwiftUI to handle data as "published"
> so the notification is actually a "will change" that
> SwiftUI needs.  What this means is that if you access
> the current value when that notification happens,
> you will get the old value.

The ``Connection`` class also stores all the current
values of the data, allowing anything to access this
via an index into this tree.  That data is stored as
JSON (via a ``JSONValue``).  There is no typing information
stored in the data tree itself (so a ``Connection`` doesn't
know that the current period number is an integer and not
a string).


### `StatePath`
A `StatePath` is a struct that defines an index in
the data tree that a ``Connection`` maintains.  While
this could be represented as a simple `String` that
would be error prone.  Instead, a `StatePath` is
a series of components (`PathComponent`), which
is parsed from the original string value that the
server sends in JSON.  There are multiple types
of path components:
- A `plain` component, such as `Foo.Bar` which is two plain components
- A `number` component.  In `CurrentGame.Period(2).CurrentJamNumber`, `Period(2)` is a `number` component
- A `wild` component.  Similar to a `number` component, but (in theory) represents all values.  This is used by the scoreboard in a few places, but it becomes a problem quickly (since you can get multiple things, but not set them)
- A `name` component.  Similar to a `number` component, but with some sort of enumerated name.  For example `CurrentGame.Clock(Timeout).Time` is the current time on the timeout clock
- An `id` component.  Some items, such as games, have a unique ID associated with them, which is a UUID (and an optional additional value in some cases that aren't supported yet).  So `ScoreBoard.Game(fa604549-2bd9-450b-8506-9e669b83e098).InJam` refers to a specific game.  Note that UUIDs are in lowercase.
- An `compound` component.  For things like settings, the name component actually is composed of multipled dotted parts.  This component allows us to model that as a tree rather than a hard coded list of dotted names

### `PathSpecified`
`PathSpecified` is a protocol that simply represents
something that has a ``Connection`` and a ``StatePath``.
I.E., it can get a value from a specific scoreboard
data tree.  Note that that value it can get is
just raw JSON.  Also note that it doesn't actually store
any data - this is all just a reference of where to
look for the data.

### `PathNode`
A `PathNode` is a `PathSpecified` thing that also lives
inside a parent (which is also `PathSpecified`).  It
uses the same ``Conection`` as its parent does.

### `Leaf`
A `Leaf` is a property wrapper that accesses a single value
from the data tree.  It is `PathSpecified` so it knows
how to get the data (and from where).  It is also typed
so it know that, for example, a `jamNumber` is an integer
and not a string.  It will automatically convert the
`JSONValue` stored in the data tree into whatever type
its `wrappedValue` is.

### `ImmutableLeaf`
A `ImmutableLeaf` is a property wrapper that works just like
`Leaf` except it is read only (used for read only scoreboard
data expressed as a `let` statement in the tree definition file)

### `Stat`
Stat is a property wrapped designed to be used inside views, much
like `@ObservedObject` would be.  It works with values which are
`PathNode` types and ensures that the view is updated when the
server changes those values.

## TreeDefinition/treemaker
There is a fair amount of boiler-plate code that is
needed to make all the values  To this end, a simple
parser takes a definition file and generates the
Swift code that represents that tree definition.  The SPM
then automatically "compiles" that tree defintion
to create the Swift code that is compiled into the
library.


## StatterBook
StatterBook is 
