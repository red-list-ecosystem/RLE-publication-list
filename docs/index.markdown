---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults
title: Collection of References
layout: home
---

This site includes a commented and curated list of publications related to IUCN Red List of Ecosystem (IUCN RLE) assessments (and other formal assessment of threats to ecosystem).

## Lists of publications

Our main focus and priority is to summarize the state of progress of IUCN RLE asssessments of risk of collapse, but we also include references to other equivalent formal assessment of risk of elimination, loss or 'extinction' of ecosystem. In these cases we try to document the definition and use of categories and criteria as well as their outcomes.

<ul>
  {% for post in site.listas %}
    <li>
      <h4><a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></h4>
      {{ post.excerpt }}
    </li>
  {% endfor %}
</ul>


## Summary of publications

Here we will place links to updated summaries of progress and impact
