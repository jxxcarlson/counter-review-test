module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import Install.TypeVariant
import Install.FieldInTypeAlias
import Install.Initializer
import Install.ClauseInCase
import Review.Rule exposing (Rule)


config : List Rule
config =
    [ Install.TypeVariant.makeRule "Types" "ToBackend" "ResetCounter"
    , Install.ClauseInCase.init "Backend" "updateFromFrontend" "ResetCounter" "( { model | counter = 0 }, broadcast (CounterNewValue 0 clientId) )"
        |> Install.ClauseInCase.makeRule
    -- , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "randomAtmosphericNumbers : Maybe (List Int)"
    -- , Install.Initializer.makeRule "Backend" "init" "randomAtmosphericNumbers" "Nothing"
    ]
