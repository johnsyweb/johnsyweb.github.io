---
layout: post
categories:
    - parkrun
    - geek
title: parkrun Events Near Public Transport in Victoria
date: 2026-04-01  7:44:32
---

Last month, when two of Melbourne's larger parkrun events were closed for the [Formula 1 Australian Grand Prix 2026] and associated works in [Albert Park], I was asked, "How many parkruns can you get to in Victoria by public transport?"

I knew, from contributing to projects like the [Running Challenges Chrome Extension], that parkrun's event information is available in [GeoJSON] format. I also suspected that public transport stop locations in Victoria would be available as open data, and indeed they were: [Public Transport Lines and Stops dataset][vic-pt-open-data].


Front-end web development is not one of my core competencies (QED), but I hear delegating to coding agents is a thing these days, so I gave that a whirl and a few minutes later I had something satisfactory up and running at [parkrun by Public Transport][app].

<figure class="caption-centred">
  <a href="https://www.johnsy.com/parkrun-by-public-transport/">
      <img
        src="https://www.johnsy.com/parkrun-by-public-transport/og-image.png"
        alt="Map of Victoria showing parkrun event locations and public transport stops"
        width="578" height="304"
        class="responsive-image"
        loading="lazy"
      />
  </a>
  <figcaption>parkrun Events Near Public Transport in Victoria</figcaption>
</figure>

Rather than trying to build a full Saturday-morning journey planner, I treated this as a neat little data demo: plot Victorian parkrun events, find the nearest public transport stop to each one, and use that distance as a rough proxy for reachability.

There are over a hundred Victorian parkrun events within one kilometer of a public transport stops. That obviously misses things like service frequency, timetables, and whether the walk is actually pleasant or practical, but it is good enough to answer the question.

[Public transport [in Victoria is] now free every day until the end of April][free-transport-april], so I figure this little app may have broader appeal.

Perhaps, as other states and territories introduce free public transport, I can update the data sources.

<!-- Links -->

[Albert Park]: https://en.wikipedia.org/wiki/Albert_Park,_Victoria
[app]: https://www.johnsy.com/parkrun-by-public-transport/
[Formula 1 Australian Grand Prix 2026]: https://www.grandprix.com.au/
[free-transport-april]: https://www.premier.vic.gov.au/public-transport-now-free-every-day-until-end-april
[GeoJSON]: https://geojson.org
[Running Challenges Chrome Extension]: https://running-challenges.co.uk/
[vic-pt-open-data]: https://opendata.transport.vic.gov.au/dataset/public-transport-lines-and-stops/resource/a2cba0b0-bddc-4b87-b495-2b6b7013af6e
