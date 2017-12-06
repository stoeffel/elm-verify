module Verify.String exposing (maxLength, minLength, notBlank)

{-| Functions to verify properties of a String.

@docs notBlank, minLength, maxLength

-}

import Regex exposing (Regex)
import Verify exposing (Validator)


{-| Fails if a String is blank (empty or only whitespace).

    notBlank "error" ""
    --> Err [ "error" ]

-}
notBlank : error -> Validator error String String
notBlank error input =
    if Regex.contains lacksNonWhitespaceChars input then
        Err [ error ]
    else
        Ok input


lacksNonWhitespaceChars : Regex
lacksNonWhitespaceChars =
    Regex.regex "^\\s*$"


{-| Fails if a String is smaller than a given minimum.

    minLength 3 "error" "ab"
    --> Err [ "error" ]

    minLength 3 "error" "abc"
    --> Ok "abc"

-}
minLength : Int -> error -> Validator error String String
minLength min error input =
    if String.length input >= min then
        Ok input
    else
        Err [ error ]


{-| Fails if a String is smaller than a given maximum.

    maxLength 3 "error" "abc"
    --> Ok "abc"

    maxLength 3 "error" "abcd"
    --> Err [ "error" ]

-}
maxLength : Int -> error -> Validator error String String
maxLength max error input =
    if String.length input <= max then
        Ok input
    else
        Err [ error ]
