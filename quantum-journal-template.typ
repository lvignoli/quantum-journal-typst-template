// Importing required packages
#import "@preview/physica:0.9.3": *

// Define custom colors for use in the template
#let quantum_violet = rgb("#53257F")
#let quantum_grey = rgb("#555555")

// Define the main template function 'quantum-journal-template'
#let quantum-journal-template(
    title: none,                    // Title of the document
    authors: (),  // Authors. Each entry is a dictionary. Optional keys are "name", "affiliations", "homepage", and "email"
    font-size: 11pt,                // Default font size
    columns: 2,                     // Number of columns in the document
    font: "New Computer Modern",    // Default font
    title_url: none, // The link when you click on the title
    bibliography: bibliography("refs.bib"),
    doc                             // Document content
) = {

  // Set the document meta data
  set document(title: title, author: authors.map(author => author.name))

  // Configure page settings: margins, columns, and page numbering
  set page(
    margin: (top: 2.5cm, bottom: 3cm, left: 2cm, right: 2cm),
    columns: columns,
    numbering: "1",
    footer: {
      rect(
        width: 100%,
        stroke: (top: 0.25pt),
      )[
        #set text(font: "New Computer Modern Sans", fill: quantum_violet)
        Draft for Quantum #h(1fr) #text(size: 13pt, context counter(page).display())
      ]
    }
  )

  // Set paragraph justification for the document
  set par(justify: true)

  // Set equation numbering style
  set math.equation(numbering: "(1)")

  // Set the heading numbering and style
  set heading(numbering: (..nums) => nums.pos().map(str).join(".") )
  show heading: set text(font: "New Computer Modern Sans", weight: "regular", size: 1.0em)
  show heading: it => {
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(1em)
    }
    block(number + it.body, spacing: 1.2em)
  }
  show heading.where(body: [Acknowledgements]): set heading(numbering: none)

  // Set the default text size and font, ensuring consistency
  if font in ("Sans", "sans") {
    font = "New Computer Modern Sans"
  } else if font in ("Serif", "serif","",none) {
    font = "New Computer Modern"
  }
  set text(size: font-size, font: font)

  //Figure formatting

  show figure.where(kind: image): set figure(supplement: [Fig], numbering: "1")
  show figure.caption: set text(size: font-size)
  show figure.caption: set align(start)



  // Style bibliography.
  set std.bibliography(title: "References", style: "ieee")
  show std.bibliography: set heading(numbering: none)


  // Place the title and author block at the top left of the page
  place(
    top + left,
    scope: "parent",
    float: true,
    {
      // Display the title in a larger font with a custom color and font
      {
        set text(size: 2em, fill: quantum_violet, font: "New Computer Modern Sans")

        if title_url == none{
          title
        }
        else{
          link(title_url)[#title]
        }
      }

      linebreak()
      linebreak()

      // Initialize an empty set to collect unique affiliations
      let affiliation_set = ()
      // Get the number of authors
      let author_count = authors.len()

      // Loop over each author to display their information
      for (i, author) in authors.enumerate() {
        // Set the font for the author names
        set text(font: "New Computer Modern Sans", size: 1.3em)
        // Display the author's name with or without a link to their homepage
        if "homepage" in author.keys() {
          link(author.homepage)[#author.name]
        } else {
          author.name
        }

        if "affiliations" in author.keys(){

          // Initialize an empty list to store indices of affiliations for this author
          let affiliation_indices = ()

          // Handle affiliations, ensuring compatibility with different formats
          let affiliations = ()
          if type(author.affiliations) == str {
            affiliations.push(author.affiliations)
          } else {
            affiliations = author.affiliations
          }

          // Loop through affiliations to determine unique indices
          for affiliation in affiliations {
            let affiliation_exists = false
            for (j, aff) in affiliation_set.enumerate() {
              if aff == affiliation {
                affiliation_indices.push(j + 1)
                affiliation_exists = true
                break
              }
            }
            if affiliation_exists == false {
              affiliation_set.push(affiliation)
              affiliation_indices.push(affiliation_set.len())
            }
          }

          // Display the affiliation indices as superscripts
          for (j, index) in affiliation_indices.enumerate() {
            text(super(str(index)))
            if j != affiliation_indices.len() - 1 {
              text(super(","))
            }
          }
        }

        // Add appropriate punctuation between author names
        if i < author_count - 2 {
          text(", ")
        } else if i == author_count - 2 {
          text(" and ")
        }
      }

      if authors.len()>0{
        linebreak()
        linebreak()
      }

      // Display the list of affiliations with their corresponding indices
      for (i, affiliation) in affiliation_set.enumerate() {
        set text(size: 0.9em, font: "New Computer Modern Sans", fill: quantum_grey)
        text(super(str(i + 1)))
        affiliation
        linebreak()
      }
      linebreak()
    }
  )

  // Display emails at the bottom left of the page
  let emails_exist = false
  for author in authors{
    if "email" in author.keys(){
      emails_exist = true
      break
    }
  }

  if emails_exist{
    place(
      bottom + left,
      scope: "column",
      float: true, {
        show link: underline
        set text(size: 0.8em, font: "New Computer Modern Sans")
        text(weight: "bold")[Contact]
        set text(fill: quantum_grey)
        linebreak()
        for author in authors {
          if ("email" in author.keys()) {
            [#author.name: #link("mailto:" + author.email)]
            linebreak()
          }
        }
      }
    )
 }



  // Include the main document content
  doc
}

// Define a macro for the abstract section, setting the text in bold
#let Abstract(body) = {
  set text(weight: "bold")
  body
}

// Define a macro for the appendix section, adding specific heading numbering styles
#let Appendix(body) = {
  show: set heading(numbering: "A")
  show heading.where(level: 2): set heading(numbering: "A1")
  counter(heading).update(0)
  [= Appendix]
  body
}
