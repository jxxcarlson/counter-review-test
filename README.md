 # Magic Link

This repo shows how to install magic link authentication in an existing Lamdera app.
It is still a work-in-progress.

The app is at https://elm-magic-test.lamdera.app/, It was built by applying rules 
from [jxxcarlson/elm-review-codeinstaller](https://package.elm-lang.org/packages/jxxcarlson/elm-review-codeinstaller/latest/) to a bare-bones Lamdera counter app.
This package is joint work with Matteus Leite.  The review rules that install authentication are in `review/src/ReviewConfig.elm`.  They rely on 
code and ideas from Martin Stewart, Ambue, and Mario Rogic:

- `vendor/elm-email` and `vendor/magic-link`(Martin and Ambue)
- `vendor/lamdera-auth`(Mario)

If you go to [the app](https://elm-magic-test.lamdera.app/), you should be able to sign up, sign in, and have at it.  The administrator
page is only visible to the the adminstrator.  At the moment, that is me. I will make that role configuable.

The code is here, at https://github.com/jxxcarlson/counter-review-test.

- The bare-bones counter app is in `counter-original-src/`
- The review rule is in `review/src/ReviewConfig.elm`
- The result of applying the review rule to the bare-bones code is in `src`

You can use the `Makefile` to manage things:

- `Make install`: install magic-link authentication on a copy the bare-bones app.
- `Make uninstall`: the inverse of the previous step
- Use 'lamdera live` to see the results

If you run `make install`, you will get an elm-review error message.  So far,
for me, this is a false positive.  Somethng to be fixed.  Also, I recommend
running `make install` with lamdera live in the off position.

_You will have to manage the Postmark secret youself to make this work.
See `src/Config.elm` for details._

I'm not happy about the number of rules that are applied.  Ninety-two! (This is the atomic number of uranium, not a good sign).  I would like to reduce the surface area of the auth package.

Part of the reason for the large surface area is that the auth code includes not just authentication, but the batteries needed to make it operational: seeding with atmospheric random numbers (the real deal, never fake), registration of users, a page to sign in and sign up, and an admin page so the administrator can see the user data.

More work to do, but I am getting there.  Once I am a bit more happy about the
code, I will ask you to look at it so I as to make it better.


