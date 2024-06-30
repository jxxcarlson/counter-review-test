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
    Postmark.apiKey "680eaf21-1ec3-4e2f-b567-8c4ff3d6c21f"


postmarkApiKey1 : Postmark.ApiKey
postmarkApiKey1 =
    Postmark.apiKey Env.postmarkApiKey


secretKey =
    case Env.mode of
        Env.Development ->
            "devsecret"

        Env.Production ->
            "prodsecret"
