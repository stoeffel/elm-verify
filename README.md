# elm-verify

> Verify allows you to validate a model into a structure that makes forbidden states impossible.

## Example Use-Case

Your model is unvalidated, but on submit you want to verify your model and allow your function to submit that model to only take a verified model.

Your model would maybe look like this:

```elm
    type alias Model =
        { firstName : Maybe String
        , lastName : Maybe String

        -- ...
        }
```

Your submit function would be: `submit : ValidatedModel -> Cmd msg -- not Model`

So you define `ValidatedModel` like this:

```elm
    type alias ValidatedModel =
        { firstName : String
        , lastName : String

        -- ...
        }
```

and you can verify this by using a `Json.Decode.Pipeline`-like api.

```elm
     Verify.ok ValidatedModel
         |> verify .firstName (Maybe.Verify.isJust "error")
         |> verify .lastName (Maybe.Verify.isJust"error")
```
