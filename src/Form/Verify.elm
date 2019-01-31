module Form.Verify exposing (Validator, validate, at, field, accept)

{-| Verify allows you to validate a form into a structure that makes forbidden states impossible.

@docs Validator, validate, at, field, accept

    import Maybe.Verify

    type alias Form =
        { age : Int
        , firstName : Field.Field String (Maybe String)
        }

    type alias Final =
        { age : Int
        , firstName : String
        }

    validator : Form.Validator Form Form Final
    validator =
        Form.validate Form Final
            |> Form.at .age Form.accept
            |> Form.at .firstName validateFirstName

    validateFirstName : Form.Validator (Field.Field String (Maybe String)) (Field.Field String (Maybe String)) String
    validateFirstName =
        Maybe.Verify.isJust "You need to provide a first name."
            |> Form.field

-}

import Form.Field as Field
import Verify


{-| -}
type alias Validator input form verified =
    input -> Result form ( form, verified )


{-| Validates a form.
-}
validate : form -> finally -> Validator input form finally
validate form finally _ =
    Ok ( form, finally )


{-| Doesn't validate, just returns the value!
-}
accept : Validator value value value
accept verified =
    Ok ( verified, verified )


{-| Map into a form field.
-}
at : (form -> field) -> Validator field error verified -> Validator form (error -> failed) (verified -> finally) -> Validator form failed finally
at f v1 v2 =
    v2 |> custom (f >> v1)


{-| Turn a normal validator into a field validator.
-}
field : Verify.Validator error value verified -> Validator (Field.Field error value) (Field.Field error value) verified
field validator field_ =
    case validator (Field.value field_) of
        Ok verified ->
            Ok ( Field.init (Field.value field_), verified )

        Err ( e, es ) ->
            Err (Field.fail e es (Field.value field_))


custom : Validator input error verified -> Validator input (error -> form) (verified -> finally) -> Validator input form finally
custom v2 v1 input =
    case ( v1 input, v2 input ) of
        ( Ok ( toFailed, toVerified ), Ok ( error, verified ) ) ->
            Ok ( toFailed error, toVerified verified )

        ( Err toFailed, Err error ) ->
            Err (toFailed error)

        ( Err toFailed, Ok ( error, _ ) ) ->
            Err (toFailed error)

        ( Ok ( toFailed, toVerified ), Err error ) ->
            Err (toFailed error)
