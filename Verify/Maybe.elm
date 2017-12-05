module Verify.Maybe exposing (ifNothing)

{-| Functions to verify properties of a Maybe.

@docs ifNothing

-}

import Verify exposing (Validator)


{-| Fails if a Maybe is Nothing.

    ifNothing "error" Nothing
    --> Err [ "error" ]


    ifNothing "error" (Just 42)
    --> Ok 42 -- It removes the wrapper as well!

-}
ifNothing : error -> Validator error (Maybe a) a
ifNothing error =
    Result.fromMaybe [ error ]
