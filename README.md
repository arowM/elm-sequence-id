# elm-sequence-id

[![test](https://github.com/arowM/elm-sequence-id/actions/workflows/test.yaml/badge.svg)](https://github.com/arowM/elm-sequence-id/actions/workflows/test.yaml) [![Elm package](https://img.shields.io/elm-package/v/arowM/elm-sequence-id)](https://package.elm-lang.org/packages/arowM/elm-sequence-id/latest/)

Pure, conflict-free, JSON-friendly, arbitrary size, sequential ID string.

This library provides a pure way to generate a unique ID that can be sent as a JSON value to the server or ports.

# Use case

Sample to use with port:

```elm
import SequenceId exposing (SequenceId)


type alias Model =
    { portId : SequenceId
    }


type Msg
    = RequestPort
    | ReceivePort
        { id : String
        , body : Value
        }

{-| Request a task that takes some time for JavaScript.
-}
port request :
    { id : SequenceId
    , body : Value
    }
    -> Cmd msg

{-| Receive the result of processing the task requested by `request`.
Note that the order in which the `request` is called and the order in which the results are received are not necessarily the same.
You can identify which request the response is for by checking the SequenceId.
-}
port response :
    ( { id : SequenceId
      , body : Value
      }
      -> msg
    )
    -> Sub msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        RequestPort ->
            ( { model | portId = SequenceId.inc model.portId }
            , request
                { id = model.portId
                , body = Debug.todo "Request body"
                }
            )

        ReceivePort response ->
            Debug.todo
```

```js
app.ports.request.subscribe(({ id, body }) => {
    // TODO: Do some task.
    app.ports.response.send({ id, body: result });
});
```

Thus, you can map a request to a port to its response by SequenceId.

# Why not use `Int`?

You can think about using `Int` value. It is not the bad way, but has defeats that it has upper bounds.
The `SequenceId` here is string represented of the sequence, so in practice it has no maximum limits.

# Why not use Arbitrary-precision of Decimal libraries?

Several people have published Elm libraries that deal with numbers in arbitrary precisions.
Using these as sequences is not a bad idea, but they do not provide an efficient way to pass the values to JS. The simplest way would be to convert the number to a string in decimal notation. This would allow JS to compare the two IDs to make sure they are the same, but would require the string to be as large as the number of digits.
Hexadecimal notation would be more efficient, but there is still room for improvement.

The main reason for adopting SequenceId is to make this string representation more efficient. Since JS (and Elm) strings are UTF-16 encoded, characters in the code point range U+0020 to U+D7FF are relatively safe to include; SequenceId can use these characters to generate strings in, say, base 55264 number representation.
