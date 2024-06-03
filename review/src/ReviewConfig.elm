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
import Install.Function
import Review.Rule exposing (Rule)



config : List Rule
config =
    [
       Install.TypeVariant.makeRule "Types" "ToBackend" "CounterReset"
     , Install.TypeVariant.makeRule "Types" "FrontendMsg" "Reset"
     , Install.ClauseInCase.init "Frontend" "update" "Reset" "( { model | counter = 0 }, sendToBackend CounterReset )"
        |> Install.ClauseInCase.withInsertAfter "Increment"
        |> Install.ClauseInCase.makeRule
     , Install.ClauseInCase.init "Backend" "updateFromFrontend" "CounterReset" "( { model | counter = 0 }, broadcast (CounterNewValue 0 clientId) )"
        |> Install.ClauseInCase.makeRule
     , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "randomAtmosphericNumbers : Maybe (List Int)"
     , Install.Initializer.makeRule "Backend" "init" "randomAtmosphericNumbers" "Nothing"
     , Install.Function.init "Frontend" "view" viewFunction |>Install.Function.makeRule
     -- , Install.Function.init "Frontend" "foo" "foo model = ()" |>Install.Function.makeRule
    ]



viewFunction1 = """view model =
     Html.div [ style "padding" "30px" ]
         [ Html.button [ onClick Increment ] [ text "+" ]
         , Html.text (String.fromInt model.counter)
         , Html.button [ onClick Decrement ] [ text "-" ]
         , Html.div [] [ Html.text "Click me then refresh me!" ]
         ]"""

         
viewFunction = """view model =
      Html.div [ style "padding" "50px" ]
          [ Html.button [ onClick Increment ] [ text "+" ]
          , Html.div [ style "padding" "10px" ] [ Html.text (String.fromInt model.counter) ]
          , Html.button [ onClick Decrement ] [ text "-" ]
          , Html.div [ style "padding-top" "15px", style "padding-bottom" "15px" ] [ Html.text "Click me then refresh me!" ]
          , Html.button [ onClick Reset ] [ text "Reset" ]
          ]"""