module Config exposing
    ( contactEmail
    , postmarkApiKey
    , secretKey
    )

import Env
import Postmark


contactEmail : String
contactEmail =
    "foo@bar.com"


postmarkApiKey : Postmark.ApiKey
postmarkApiKey =
    Postmark.apiKey "32498b6f-9422-4413-811b-fc8926da2a82"


secretKey =
    case Env.mode of
        Env.Development ->
            "devsecret"

        Env.Production ->
            "prodsecret"
