module Verify.String exposing (ifBlank)

{-| Functions to verify properties of a String.

@docs ifBlank

-}

import Regex exposing (Regex)
import Verify exposing (Validator)


{-| Fails if a String is blank (empty or only whitespace).

    ifBlank "error" ""
    --> Err [ "error" ]

-}
ifBlank : error -> Validator error String String
ifBlank error input =
    if Regex.contains lacksNonWhitespaceChars input then
        Err [ error ]
    else
        Ok input


lacksNonWhitespaceChars : Regex
lacksNonWhitespaceChars =
    Regex.regex "^\\s*$"
