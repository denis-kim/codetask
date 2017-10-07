Originally I misinterpreted the spec and made the app show data for all Sets.

Later I realized that I needed to use a specific "Home" set out of all sets and use the content of that for the main screen.

I looked up the data for each of the episodes but I could only see titles (and synopsis, subtitles). Also, only one of the episodes had an image. So when displayed, the view seemed to lack a lot of content.

Not sure how 'Home' was meant to be obtained. Right now I assume that set_type_slug will tell us.

I made the app do roughly what the sketch shows. However there are a number of issues:

- When there's no connectivity - the app will keep retrying, but not show any messages on the screen

- We fetch all content only once. In reality I guess we'd have to re-fetch and update and merge

- I wasn't sure if a placeholder image needed to be used for missing images.

Still not sure if my interpretation of requirements was appropriate.

----

Reference

Home set uid: coll_e8400ca3aebb4f70baf74a81aefd5a78

Sets: http://feature-code-test.skylark-cms.qa.aws.ostmodern.co.uk:8000/api/sets/

Set detail (metadata): http://feature-code-test.skylark-cms.qa.aws.ostmodern.co.uk:8000/api/sets/coll_e8400ca3aebb4f70baf74a81aefd5a78/

Set content: http://feature-code-test.skylark-cms.qa.aws.ostmodern.co.uk:8000/api/sets/coll_e8400ca3aebb4f70baf74a81aefd5a78/items/

Content: http://feature-code-test.skylark-cms.qa.aws.ostmodern.co.uk:8000/api/episodes/uid/
