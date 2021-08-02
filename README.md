# provenance-vocabularies

A set of vocabularies to describe provenance according to https://www.w3.org/TR/2013/REC-prov-o-20130430/.

The W3C Prov-O ontology defines binary unqualfied properties (e.g. `prov:wasGeneratedBy`) that can be qualified using a class (e.g. `prov:Generation`).

in OML, the qualfied class (e.g. `prov:Generation`) becomes an OML relation entity class whose 'forward' property corresponds precisely to the Prov-O unqualified property (e.g. `prov:wasGeneratedBy`).

For example:

```oml
	@rdfs:seeAlso "https://www.w3.org/TR/2013/REC-prov-o-20130430/#Generation"
	@rdfs:seeAlso "https://www.w3.org/TR/2013/REC-prov-dm-20130430/Overview.html#term-Generation"
	@rdfs:comment "Generation is the completion of production of a new entity by an activity. This entity did not exist before generation and becomes available for usage after this generation."
	relation entity Generation :> ActivityInfluence, InstantaneousEvent [
		from Entity
		to Activity
		@rdfs:seeAlso "https://www.w3.org/TR/2013/REC-prov-o-20130430/#wasGeneratedBy"
		forward wasGeneratedBy
		@rdfs:seeAlso "https://www.w3.org/TR/2013/REC-prov-o-20130430/#generated"
		reverse generated
		functional
	]
```

In Turtle syntax, the above yields the following, which is logically equivalent to the [Prov-O ontology](https://www.w3.org/ns/prov-o):

```turtle
###  http://www.w3.org/ns/prov#Generation
:Generation rdf:type owl:Class ;
            rdfs:subClassOf :ActivityInfluence ,
                            :InstantaneousEvent ;
            <http://purl.org/dc/elements/1.1/type> <http://opencaesar.io/oml#RelationEntity> ;
            rdfs:comment "Generation is the completion of production of a new entity by an activity. This entity did not exist before generation and becomes available for usage after this generation." ;
            rdfs:seeAlso "https://www.w3.org/TR/2013/REC-prov-dm-20130430/Overview.html#term-Generation" ,
                         "https://www.w3.org/TR/2013/REC-prov-o-20130430/#Generation" .

###  http://www.w3.org/ns/prov#wasGeneratedBy
:wasGeneratedBy rdf:type owl:ObjectProperty ;
                rdfs:subPropertyOf :wasInfluencedByActivity ;
                rdf:type owl:FunctionalProperty ;
                rdfs:domain :Entity ;
                rdfs:range :Activity ;
                <http://purl.org/dc/elements/1.1/type> <http://opencaesar.io/oml#forwardRelation> ;
                rdfs:seeAlso "https://www.w3.org/TR/2013/REC-prov-o-20130430/#wasGeneratedBy" .

###  http://www.w3.org/ns/prov#generated
:generated rdf:type owl:ObjectProperty ;
           owl:inverseOf :wasGeneratedBy ;
           <http://purl.org/dc/elements/1.1/type> <http://opencaesar.io/oml#reverseRelation> ;
           rdfs:seeAlso "https://www.w3.org/TR/2013/REC-prov-o-20130430/#generated" .
```

Most importantly, each OML relation entity has an associated SWRL rule to derive the `forward` property from an instance of the relation entity class.
In this example, the rule derives `prov:wasGeneratedBy` from an instance of `prov:Generation`:

```turtle
[ rdfs:label "wasGeneratedBy derivation" ;
   rdf:type <http://www.w3.org/2003/11/swrl#Imp> ;
   <http://www.w3.org/2003/11/swrl#body> [ rdf:type <http://www.w3.org/2003/11/swrl#AtomList> ;
                                           rdf:first [ rdf:type <http://www.w3.org/2003/11/swrl#IndividualPropertyAtom> ;
                                                       <http://www.w3.org/2003/11/swrl#propertyPredicate> <http://opencaesar.io/oml#hasSource> ;
                                                       <http://www.w3.org/2003/11/swrl#argument1> <urn:swrl#r> ;
                                                       <http://www.w3.org/2003/11/swrl#argument2> <urn:swrl#s>
                                                     ] ;
                                           rdf:rest [ rdf:type <http://www.w3.org/2003/11/swrl#AtomList> ;
                                                      rdf:first [ rdf:type <http://www.w3.org/2003/11/swrl#ClassAtom> ;
                                                                  <http://www.w3.org/2003/11/swrl#classPredicate> :Generation ;
                                                                  <http://www.w3.org/2003/11/swrl#argument1> <urn:swrl#r>
                                                                ] ;
                                                      rdf:rest [ rdf:type <http://www.w3.org/2003/11/swrl#AtomList> ;
                                                                 rdf:first [ rdf:type <http://www.w3.org/2003/11/swrl#IndividualPropertyAtom> ;
                                                                             <http://www.w3.org/2003/11/swrl#propertyPredicate> <http://opencaesar.io/oml#hasTarget> ;
                                                                             <http://www.w3.org/2003/11/swrl#argument1> <urn:swrl#r> ;
                                                                             <http://www.w3.org/2003/11/swrl#argument2> <urn:swrl#t>
                                                                           ] ;
                                                                 rdf:rest rdf:nil
                                                               ]
                                                    ]
                                         ] ;
   <http://www.w3.org/2003/11/swrl#head> [ rdf:type <http://www.w3.org/2003/11/swrl#AtomList> ;
                                           rdf:first [ rdf:type <http://www.w3.org/2003/11/swrl#IndividualPropertyAtom> ;
                                                       <http://www.w3.org/2003/11/swrl#propertyPredicate> :wasGeneratedBy ;
                                                       <http://www.w3.org/2003/11/swrl#argument1> <urn:swrl#s> ;
                                                       <http://www.w3.org/2003/11/swrl#argument2> <urn:swrl#t>
                                                     ] ;
                                           rdf:rest rdf:nil
                                         ]
 ] .
```

In Prov-O, the qualified property is intended to relate an instance of the qualified class.
In OML, this qualified property can be derived via a SWRL rule in OML:

```oml
 	rule qualifiedGeneration_generated [
		Generation(e, g, a) -> qualifiedGeneration(e, g)
	]
```

In Turtle syntax, the above corresponds to the following:

```turtle
[ rdfs:label "qualifiedGeneration_generated" ;
   rdf:type <http://www.w3.org/2003/11/swrl#Imp> ;
   <http://www.w3.org/2003/11/swrl#body> [ rdf:type <http://www.w3.org/2003/11/swrl#AtomList> ;
                                           rdf:first [ rdf:type <http://www.w3.org/2003/11/swrl#ClassAtom> ;
                                                       <http://www.w3.org/2003/11/swrl#classPredicate> :Generation ;
                                                       <http://www.w3.org/2003/11/swrl#argument1> <urn:swrl#g>
                                                     ] ;
                                           rdf:rest [ rdf:type <http://www.w3.org/2003/11/swrl#AtomList> ;
                                                      rdf:first [ rdf:type <http://www.w3.org/2003/11/swrl#IndividualPropertyAtom> ;
                                                                  <http://www.w3.org/2003/11/swrl#propertyPredicate> <http://opencaesar.io/oml#hasSource> ;
                                                                  <http://www.w3.org/2003/11/swrl#argument1> <urn:swrl#g> ;
                                                                  <http://www.w3.org/2003/11/swrl#argument2> <urn:swrl#e>
                                                                ] ;
                                                      rdf:rest [ rdf:type <http://www.w3.org/2003/11/swrl#AtomList> ;
                                                                 rdf:first [ rdf:type <http://www.w3.org/2003/11/swrl#IndividualPropertyAtom> ;
                                                                             <http://www.w3.org/2003/11/swrl#propertyPredicate> <http://opencaesar.io/oml#hasTarget> ;
                                                                             <http://www.w3.org/2003/11/swrl#argument1> <urn:swrl#g> ;
                                                                             <http://www.w3.org/2003/11/swrl#argument2> <urn:swrl#a>
                                                                           ] ;
                                                                 rdf:rest rdf:nil
                                                               ]
                                                    ]
                                         ] ;
   <http://www.w3.org/2003/11/swrl#head> [ rdf:type <http://www.w3.org/2003/11/swrl#AtomList> ;
                                           rdf:first [ rdf:type <http://www.w3.org/2003/11/swrl#IndividualPropertyAtom> ;
                                                       <http://www.w3.org/2003/11/swrl#propertyPredicate> :qualifiedGeneration ;
                                                       <http://www.w3.org/2003/11/swrl#argument1> <urn:swrl#e> ;
                                                       <http://www.w3.org/2003/11/swrl#argument2> <urn:swrl#g>
                                                     ] ;
                                           rdf:rest rdf:nil
                                         ]
 ] .
```

## Examples

The OML Prov-O vocabulary includes the 11 examples from the specification.

In OML, vocabularies are typically closed before using them for modeling instances in OML descriptions. Closing a vocabulary is a decision made at the level of a group of ontologies, in OML terminology, a vocabulary bundle. This closure applies a policy whereby any pair of classes that have no common specialization are asserted to be disjoint from each other. The resulting set of disjointness axioms computed over the taxonomy of all vocabularies in scope of a vocabulary bundle turns out to be very useful and powerful for OWL2-DL+SWRL reasoners to verify instances in OML description ontologies against the semantics of vocabularies in OML vocabulary bundles.

This technique pointed out problems in the examples from the Prov-O ontology.
### [Example 2](https://www.w3.org/TR/prov-o/#narrative-example-expanded-1)

This example includes the following axioms:

```turtle
:derek
  a prov:Person, prov:Agent
.

:publicationActivity1123 
  a prov:Activity;
  prov:wasStartedBy      :derek;
  prov:wasEndedBy        :derek
.
```

Note that the range of [prov:wasStartedBy](https://www.w3.org/TR/2013/REC-prov-o-20130430/#wasStartedBy) and of [prov:wasEndedBy](https://www.w3.org/TR/2013/REC-prov-o-20130430/#wasEndedBy) is [prov:Entity](https://www.w3.org/TR/2013/REC-prov-o-20130430/#Entity), not [prov:Agent](https://www.w3.org/TR/2013/REC-prov-o-20130430/#Agent) as used in the example.

Under the open-world assumption, the example is fine; a reasoner will conclude that `:derek` is classified as both `prov:Agent` (as asserted) and `prov:Entity` (as inferred).

With the OML bundle closure, the disjointness policy generates several sets of disjointness axioms including the following in Turtle syntax:

```turtle
[ rdf:type owl:AllDisjointClasses ;
owl:members ( <http://www.w3.org/ns/prov#Activity>
              <http://www.w3.org/ns/prov#Agent>
              <http://www.w3.org/ns/prov#Alternate>
              <http://www.w3.org/ns/prov#AtLocation>
              <http://www.w3.org/ns/prov#Entity>
              <http://www.w3.org/ns/prov#HadActivity>
              <http://www.w3.org/ns/prov#HadGeneration>
              <http://www.w3.org/ns/prov#HadPlan>
              <http://www.w3.org/ns/prov#HadRole>
              <http://www.w3.org/ns/prov#HadUsage>
              <http://www.w3.org/ns/prov#Influence>
              <http://www.w3.org/ns/prov#Influencer>
              <http://www.w3.org/ns/prov#Location>
              <http://www.w3.org/ns/prov#Member>
              <http://www.w3.org/ns/prov#QualifiedInfluence>
              <http://www.w3.org/ns/prov#Role>
            )
] .
```

With the OML bundle closure, this example becomes inconsistent unless the assertions about `:derek` are removed as is done in the OML [example2.oml](src/examples/oml/example.org/example2.oml).

### [Example 4](https://www.w3.org/TR/prov-o/#narrative-example-expanded-3)

This example includes the following axioms:

```turtle
:publicationActivity1124
   a prov:Activity;
   prov:wasAttributedTo :postEditor,
                        :john
.

:john 
   a prov:Person, prov:Agent
.

:postEditor 
   a prov:SoftwareAgent, prov:Agent  ## from Example 1
.   
```

Note that the domain of [prov:wasAttributedTo](https://www.w3.org/TR/2013/REC-prov-o-20130430/#wasAttributedTo) is [prov:Entity](https://www.w3.org/TR/2013/REC-prov-o-20130430/#Entity), not [prov:Agent](https://www.w3.org/TR/2013/REC-prov-o-20130430/#Agent) as used in the example.

Under the open-world assumption, the example is fine; a reasoner will conclude that `:john` and `:postEditor` are classified as both `prov:Agent` (as asserted) and `prov:Entity` (as inferred).

With the OML bundle closure, the disjointness policy generates several sets of disjointness axioms including the following in Turtle syntax:

```turtle
[ rdf:type owl:AllDisjointClasses ;
owl:members ( <http://www.w3.org/ns/prov#Activity>
              <http://www.w3.org/ns/prov#Agent>
              <http://www.w3.org/ns/prov#Alternate>
              <http://www.w3.org/ns/prov#AtLocation>
              <http://www.w3.org/ns/prov#Entity>
              <http://www.w3.org/ns/prov#HadActivity>
              <http://www.w3.org/ns/prov#HadGeneration>
              <http://www.w3.org/ns/prov#HadPlan>
              <http://www.w3.org/ns/prov#HadRole>
              <http://www.w3.org/ns/prov#HadUsage>
              <http://www.w3.org/ns/prov#Influence>
              <http://www.w3.org/ns/prov#Influencer>
              <http://www.w3.org/ns/prov#Location>
              <http://www.w3.org/ns/prov#Member>
              <http://www.w3.org/ns/prov#QualifiedInfluence>
              <http://www.w3.org/ns/prov#Role>
            )
] .
```

With OML bundle closure, this example becomes inconsistent unless the assertions about `:john` and `:postEditor` are removed as is done in the OML [example4.oml](src/examples/oml/example.org/example4.oml).

