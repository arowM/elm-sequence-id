module SequenceId exposing
    ( SequenceId
    , toString
    , init
    , inc
    )

{-|

@docs SequenceId
@docs toString
@docs init
@docs inc

-}


zero : Int
zero =
    0x21


one : Int
one =
    0x22


maxBound : Int
maxBound =
    0xD7FF


{-| Base 55263 representation of a sequential number.
-}
type SequenceId
    = SequenceId String



-- reversed


{-| Convert `SequenceId` to a base 55263 represented string.
-}
toString : SequenceId -> String
toString (SequenceId str) =
    str


{-| Initial ID.
-}
init : SequenceId
init =
    Char.fromCode zero
        |> String.fromChar
        |> SequenceId


{-| Get next `SequenceId`.
-}
inc : SequenceId -> SequenceId
inc (SequenceId str) =
    inc_ True "" str
        |> SequenceId


inc_ : Bool -> String -> String -> String
inc_ carry acc str =
    if carry then
        case String.uncons str of
            Nothing ->
                String.cons (Char.fromCode one) acc
                    |> String.reverse

            Just ( c, next ) ->
                let
                    charCode =
                        Char.toCode c

                    nextCarry =
                        charCode >= maxBound

                    newCharCode =
                        if nextCarry then
                            zero

                        else
                            charCode + 1
                in
                inc_ nextCarry (String.cons (Char.fromCode newCharCode) acc) next

    else
        String.reverse acc ++ str
